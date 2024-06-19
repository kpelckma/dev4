

from setPowerSupply import *
import doFFT

from tqdm import tqdm
import tkinter as tk
import numpy as np
from scipy.fft import fft, fftfreq 
from scipy.signal import *
import time

from tkinter import ttk
from tkinter.filedialog import askopenfilename, asksaveasfilename


from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2Tk
from matplotlib.figure import Figure
from dev4 import dev4

from PIL import ImageTk, Image


#
#
#
class SweepClass:

  def __init__(self, start, stop, step, dc, fc, ps):
    self.start = start
    self.stop  = stop
    self.step  = step
    self.dc    = dc
    self.fc    = fc
    self.ps    = ps
    self.nmax = 100
    self.filename ="results/sweep.npz"
  
  def setSSS(self, start, stop, step):
    self.start = start
    self.stop  = stop
    self.step  = step
  

  ###########################################################################################
  def run_sweep(self):
    ts = 8e-9  # sampling constant: a sample every 8ns
    f = doFFT.doFFTClass(ts)
    if self.start<self.stop:
      _list = []
      _nmax = int((self.stop - self.start)/self.step)+1
      print("Sweep from", self.start, "to", self.stop, "in steps of", self.step)
      

      #### set ranges for voltages
      ## TODO: fields in GUI

      # set ranges for the sweep
      _vdds = np.array([32]) 
      #_vdds = np.linspace(7,32,num=5) 
      _vgg1s = np.array([2.2]) 
      #_vgg1s = np.linspace(1.5, 2.2,num=3) 
      _vgg2s = np.array([1.8]) 
      #_vgg2s = np.linspace(1.0, 1.8,num=3)

      X = np.zeros((len(_vdds)*len(_vgg1s)*len(_vgg2s)*_nmax, 5+2+2+2) )
      t = 0
      # main loops
      for i1 in tqdm(range(len(_vdds))):
        for i2 in range(len(_vgg1s)):
          for i3 in range(len(_vgg2s)):
            for i in range(_nmax):
              #self.ps.setVddVgg(_vdds[i1],_vggs[i2])
              self.ps.setVddVgg1Vgg2(Vdd=_vdds[i1],Vgg1=_vgg1s[i2], Vgg2 = _vgg2s[i3])
              _level = self.start + self.step*i
              self.fc.setLevel(_level)
              self.fc.update()
              alldata = self.dc.update()
              # gather data
              # Ch1,  Ch2/Output,  Ch3/Input,  Ch7.VM, Ch8/reference
              _data = (alldata[:1200,0], alldata[0:1200,1], alldata[0:1200,2], alldata[0:1200,6], alldata[0:1200, 7])  
              # csvfilename = "results/csv/s"+str(_level)+ "_Vdd=" + str(np.round(_vdds[i1], decimals=2) + "_Vgg="+str(np.round(_vggs[i2], decimals=2))+".csv"
              # np.savetxt(csvfilename,_data, delimiter=",")
              i_freq,i_amplitude,i_phase = f.getAP(alldata[100:800,2]) # read channel 3
              o_freq,o_amplitude,o_phase = f.getAP(alldata[100:800,1]) # read channel 2
              _list.append({'Vdd': _vdds[i1], 'Vgg1':_vgg1s[i2], 'Vgg2':_vgg2s[i3], 'Powerlevel':_level, 'i_amp': i_amplitude, 'i_pha': i_phase, 'o_amp': o_amplitude, 'o_pha': o_phase})
              print("Power level:", _level, "Vdd:", _vdds[i1], "Vgg1:", _vgg1s[i2], 'Vgg2:',_vgg2s[i3], 'diff:',o_amplitude-i_amplitude, o_phase-i_phase)
              ad = o_amplitude - i_amplitude
              pd = o_phase - i_phase
              if pd <0:
                 pd +=360 
              X[t, :] = [t, _level, _vdds[i1], _vgg1s[i2], _vgg2s[i3], i_amplitude, i_phase, o_amplitude, o_phase, ad, pd]
              t += 1
            try:
              np.savez_compressed(self.filename,a=_list)
              np.savetxt('result.csv',X,delimiter=",")
            except:
              print("An error occured while saving.")
      self.ps.off() # switch supply unit off after sweep to avoid overheating
      print("Sweep finished;")
      print("---------------")
     ###########################################################################################
  
  def test_sweep(self, nmax):
    ts = 8e-9  # sampling constant: a sample every 8ns
    f = doFFT.doFFTClass(ts)
    # set voltages
    _level = 20811
    _vdd = 32.0
    _vgg1 = 2.2
    _vgg2 = 1.8
    self.ps.setVddVgg1Vgg2(Vdd=_vdd,Vgg1=_vgg1, Vgg2 = _vgg2)
    self.fc.setLevel(_level)
    self.fc.update()

    time.sleep(1)

    # nmax = 10
    X = np.zeros((nmax, 1+2+2+2) )
    _list = []
    try:
      for t in tqdm(range(nmax)):
        alldata = self.dc.update()
        i_freq,i_amplitude,i_phase = f.getAP(alldata[100:800,2]) # read channel 3
        o_freq,o_amplitude,o_phase = f.getAP(alldata[100:800,1]) # read channel 2
        _list.append({'t': t, 'i_amp': i_amplitude, 'i_pha': i_phase, 'o_amp': o_amplitude, 'o_pha': o_phase})
        ad = o_amplitude - i_amplitude
        pd = o_phase - i_phase
        if pd <0: pd +=360 
        X[t, :] = [t, i_amplitude, i_phase, o_amplitude, o_phase, ad, pd]
        # print(t, ad, pd)
    except:
      print('test aborted')
    np.savetxt('results/results_fixed_pl'+str(_level)+'.csv',X,delimiter=",")
    print("Power level:", _level)
    print("amp diff (mean, STD):",np.mean(X[:,5]), np.std(X[:,5]))
    print("pha diff (mean, STD):",np.mean(X[:,6]), np.std(X[:,6]))
    self.ps.off() # switch supply unit off after sweep to avoid overheating










#
#
#
class DataClass:
  def __init__(self,device):
    self.device = device
    self.data = device.read_daq()
    self.envelope = self.data.copy()
    for i in range(8):
      for t in range(1,len(self.data[:,i])):  
        self.envelope[t,i] = max(self.data[max(0,t-100):t,i])
    self.offi = 0
    self.offq =0


  def update(self):
    self.data = self.device.read_daq()
    self.envelope = self.data.copy()
    for i in range(8):
      for t in range(1, len(self.data[:,i])):  
        self.envelope[t,i] = max(self.data[max(0,t-100):t,i])
    return self.data







#
#
#
class RefClass:
  def __init__(self,device):
    self.device = device
    self.n = 1024
    self.t = np.arange(self.n)
    self.i = np.zeros(self.n)
    self.q = np.zeros(self.n)
    self.start= 1
    self.stop = 800
    self.level = 500
    self.switch = 795
    self.i[self.start: self.switch] = self.level
    self.i[self.switch: self.stop] = -self.level
    device.update_ref_table(ref_i=self.i, ref_q=self.q)

  def updateRef(self, start, stop, level, switch):
    self.i = np.zeros(self.n)
    self.q = np.zeros(self.n)
    self.start  = start
    self.stop   = stop
    self.level  = level
    self.switch = switch
    self.i[self.start: self.switch] = self.level
    self.i[self.switch: self.stop] =  -self.level
    self.device.update_ref_table(ref_i=self.i, ref_q=self.q)

  def update(self):
    self.i = np.zeros(self.n)
    self.q = np.zeros(self.n)
    self.i[self.start: self.switch] = self.level
    self.i[self.switch: self.stop] = -self.level
    self.device.update_ref_table(ref_i=self.i, ref_q=self.q)


  def setStart(self, start):
    self.start = start

  def setStop(self, stop):
    self.stop = stop

  def setLevel(self, level):
    self.level = level

  def setSwitch(self, switch):
    self.switch = switch




#
# class with the feedforward signals 
#  
class FfdClass:
  def __init__(self,device):
    self.device = device
    self.n = 1024
    self.t = np.arange(self.n)
    self.i = np.zeros(self.n)
    self.q = np.zeros(self.n)
    self.start  = 1
    self.stop   = 800
    self.level  = 1024
    self.switch = 790
    self.i[self.start: self.switch] = self.level
    self.i[self.switch: self.stop]  = - self.level
    device.update_ffd_table(ffd_i=self.i,  ffd_q=self.q)


  def updateFfd(self, start, stop, level, switch):
    self.i = np.zeros(self.n)
    self.q = np.zeros(self.n)
    self.start  = start
    self.stop   = stop
    self.level  = level
    self.switch = switch
    self.i[self.start: self.switch] = self.level
    self.i[self.switch: self.stop] = -self.level
    self.device.update_ffd_table(ffd_i=self.i, ffd_q=self.q)

  def update(self):
    self.i = np.zeros(self.n)
    self.q = np.zeros(self.n)
    self.i[self.start: self.switch] = self.level
    self.i[self.switch: self.stop] =  -self.level
    self.device.update_ffd_table(ffd_i=self.i, ffd_q=self.q)


  def setStart(self, start):
    self.start = start

  def setStop(self, stop):
    self.stop = stop

  def setLevel(self, level):
    self.level = level

  def setSwitch(self, switch):
    self.switch = switch





###############################################################################
###############################################################################

def update_window():
    dc.update();
    for i in range(8): 
      ax1[i].clear()
      ax1[i].plot(dc.data[:,i])
      ax1[i].grid()
      ax1[i].set_ylabel("Raw")

      ax2[i].clear()
      #ax2[i].plot(10*np.log10(1+dc.envelope[:,i]),'k-')
      ax2[i].plot(dc.envelope[:,i],'k-')
      ax2[i].grid()
      ax2[i].set_ylabel("Envelope")

      if i==7 or i==6: 
        ax2[i].clear()
        ax2[i].plot(dc.data[:100,i],'xk-')
        ax2[i].grid()
        ax2[i].set_ylabel("Zoom")

      canvas[i].draw_idle()
    for i in range(8):
      axc[i].clear()
      axc[i].plot(dc.data[:1250,8+i])
      axc[i].set_title(titles[i])
      axc[i].grid()
      if i<6: axc[i].set_xticklabels([])
    canvasc.draw_idle()
    label2c.config(text="Canvas panel (Updated:"+time.ctime(time.time())+")")













#async def update1hz_window():
#    update_window()
#    await asyncio.sleep(1)

def sweep_window():
    #askopenfilename(title='Open script')
    Twindow = tk.Toplevel(window)
    Twindow.title("Configure sweep")
    #Twindow.geometry("200x200")
    lfrm_cfg = tk.Frame(master=Twindow, relief=tk.RAISED, bd=2, highlightbackground="white", highlightthickness=2)
    lfrm_fig = tk.Frame(master=Twindow, relief=tk.RAISED, bd=2)
    lfrm_cfg.grid(column=0, row=0)
    lfrm_fig.grid(column=1, row=0)

    #  label
    llabel1 = tk.Label(master=lfrm_cfg, text="Sweep configuration panel", fg="#555")
    llabel1.grid(column=0, row=0)
    llabel2 = tk.Label(master=lfrm_fig, text="Canvas panel", fg="#555")
    llabel2.grid(column=0, row=0)

    # figure
    global swax, swcanvas
    _fig = Figure(figsize=(6,4), dpi=100)
    swax =  _fig.add_subplot(111)
    swax.plot(dc.envelope[:,6],'k-')
    swax.set_ylabel("Envelope")
    swax.grid()
    swcanvas = FigureCanvasTkAgg(_fig, master=lfrm_fig)
    swcanvas.draw()
    swcanvas.get_tk_widget().grid(column=0, row=1)

    # cfg
    global sw_start, sw_stop, sw_step, sw_pl, sw_nmax
    sw_start_lbl = tk.Label(lfrm_cfg, text="Start Power:")
    sw_start_lbl.grid(row=2, column=0, sticky="ew", padx=5)
    sw_start = tk.Entry(lfrm_cfg, text="Start:", width="10")
    sw_start.delete(0, tk.END)
    sw_start.insert(0,str(sw.start))
    sw_start.grid(row=2, column=1, sticky="ew", padx=5)

    sw_stop_lbl = tk.Label(lfrm_cfg, text="Stop Power:")
    sw_stop_lbl.grid(row=3, column=0, sticky="ew", padx=5)
    sw_stop = tk.Entry(lfrm_cfg, text="Stop:", width="10")
    sw_stop.delete(0,tk.END)
    sw_stop.insert(0,str(sw.stop))
    sw_stop.grid(row=3, column=1, sticky="ew", padx=5)

    sw_step_lbl = tk.Label(lfrm_cfg, text="Step Power:")
    sw_step_lbl.grid(row=4, column=0, sticky="ew", padx=5)
    sw_step = tk.Entry(lfrm_cfg, text="Step:", width="10")
    sw_step.delete(0,tk.END)
    sw_step.insert(0,str(sw.step))
    sw_step.grid(row=4, column=1, sticky="ew", padx=5)

    sw_pl_lbl = tk.Label(lfrm_cfg, text="Fixed Power level:")
    sw_pl_lbl.grid(row=5, column=0, sticky="ew", padx=5)
    sw_pl = tk.Entry(lfrm_cfg, text="Fixed power level:", width="10")
    sw_pl.delete(0,tk.END)
    sw_pl.insert(0,str(sw.step))
    sw_pl.grid(row=5, column=1, sticky="ew", padx=5)

    sw_nmax_lbl = tk.Label(lfrm_cfg, text="Iterations:")
    sw_nmax_lbl.grid(row=6, column=0, sticky="ew", padx=5)
    sw_nmax = tk.Entry(lfrm_cfg, text="Iterations:", width="10")
    sw_nmax.delete(0,tk.END)
    sw_nmax.insert(0,str(sw.nmax))
    sw_nmax.grid(row=6, column=1, sticky="ew", padx=5)

    global sw_update_time_lbl
    sw_update_time_lbl = tk.Label(lfrm_cfg, text="Not run yet",fg="#555" )
    sw_update_time_lbl.grid(row=400, column=1, sticky="ew", padx=5)
    lbtn_update = tk.Button(master=lfrm_cfg, text="Run sweep",  command=lambda:runsweep() )
    lbtn_update.grid(row=100, column=1, sticky="ew", padx=5)
    lbtn_update = tk.Button(master=lfrm_cfg, text="Test sweep (fixed V,A)",  command=lambda:test_sweep() )
    lbtn_update.grid(row=101, column=1, sticky="ew", padx=5)
    save_button = tk.Button(master=lfrm_cfg, text="Save as ...", command=lambda:saveas_sweep() )
    save_button.grid(row=10, column=1, sticky="ew", padx=5)

def runsweep():
    sw.setSSS(int(sw_start.get()), int(sw_stop.get()), int(sw_step.get()) )
    sw.run_sweep()
    sw_update_time_lbl.config(text="Last Updated:\n" + time.ctime(time.time()) )

def test_sweep():
    sw.test_sweep(int(sw_nmax.get()))
    sw_update_time_lbl.config(text="Last Updated:\n" + time.ctime(time.time()) )


def saveas_sweep():
    sw.filename = asksaveasfilename(initialfile="results/sweep.npz")

def saveas_all():
    filename = asksaveasfilename(initialfile="results/ch.npz")
    alldata  = dc.update()
    print("Save all channels")
    try: 
      np.savez_compressed(filename, a=alldata)
    except:
      print('saveas failed (unknown reason).')





def info_window():
    Twindow = tk.Toplevel(window)
    Twindow.title("Setup Information")
    Twindow.geometry("500x200")
    txt = tk.Text(master=Twindow)
    txt.insert(tk.INSERT, "Slot 6 \n\n")
    txt.insert(tk.END, "sis8300ku + DWC8VM1")
    txt.pack()


def trigger_window():
    Twindow = tk.Toplevel(window)
    Twindow.title("Configure triggers")
    Twindow.geometry("200x200") 


def clock_window():
    Twindow = tk.Toplevel(window)
    Twindow.title("Configure Clocks")
    Twindow.geometry("200x200") 


def ilk_window():
    Twindow = tk.Toplevel(window)
    Twindow.title("Configure Clocks")
    Twindow.geometry("200x500") 


def calli_window():
    Twindow = tk.Toplevel(window)
    Twindow.title("Callibration")
    Twindow.geometry("500x500") 


def pulse_window():
    Twindow = tk.Toplevel(window)
    Twindow.title("Configure reference pulse")
    #Twindow.geometry("200x200")
    lfrm_cfg = tk.Frame(master=Twindow, relief=tk.RAISED, bd=2, highlightbackground="white", highlightthickness=2)
    lfrm_fig = tk.Frame(master=Twindow, relief=tk.RAISED, bd=2)
    lfrm_cfg.grid(column=0, row=0)
    lfrm_fig.grid(column=1, row=0)
    lfrm_cfg_ref = tk.Frame(master=lfrm_cfg, relief=tk.RAISED, bd=2, highlightbackground="white", highlightthickness=2)
    lfrm_cfg_ffd = tk.Frame(master=lfrm_cfg, relief=tk.RAISED, bd=2, highlightbackground="white", highlightthickness=2)
    lfrm_cfg_ref.grid(column=0, row=1)
    lfrm_cfg_ffd.grid(column=0, row=2)

    #  labels
    llabel1 = tk.Label(master=lfrm_cfg, text="REF/FFD configuration panel", fg="#555")
    llabel1.grid(column=0, row=0)
    llabel2 = tk.Label(master=lfrm_fig, text="Canvas panel", fg="#555")
    llabel2.grid(column=0, row=0)

    # cfg
    # ref
    global lentry_switch, lentry_level, lentry_start, lentry_stop
    lentry_start_lbl = tk.Label(lfrm_cfg_ref, text="Start REF:")
    lentry_start_lbl.grid(row=2, column=0, sticky="ew", padx=5)
    lentry_start = tk.Entry(lfrm_cfg_ref, text="Start REF:", width="10")
    lentry_start.delete(0, tk.END)
    lentry_start.insert(0,str(rc.start))
    lentry_start.grid(row=2, column=1, sticky="ew", padx=5)

    lentry_stop_lbl = tk.Label(lfrm_cfg_ref, text="Stop REF:")
    lentry_stop_lbl.grid(row=3, column=0, sticky="ew", padx=5)
    lentry_stop = tk.Entry(lfrm_cfg_ref, text="Stop REF:", width="10")
    lentry_stop.delete(0,tk.END)
    lentry_stop.insert(0,str(rc.stop))
    lentry_stop.grid(row=3, column=1, sticky="ew", padx=5)

    lentry_level_lbl = tk.Label(lfrm_cfg_ref, text="Level REF:")
    lentry_level_lbl.grid(row=4, column=0, sticky="ew", padx=5)
    lentry_level = tk.Entry(lfrm_cfg_ref, text="Level REF:", width="10")
    lentry_level.delete(0,tk.END)
    lentry_level.insert(0,str(rc.level))
    lentry_level.grid(row=4, column=1, sticky="ew", padx=5)

    lentry_switch_lbl = tk.Label(lfrm_cfg_ref, text="Switch REF:")
    lentry_switch_lbl.grid(row=5, column=0, sticky="ew", padx=5)
    lentry_switch = tk.Entry(lfrm_cfg_ref, text="Switch REF:", width="10")
    lentry_switch.delete(0, tk.END)
    lentry_switch.insert(0,str(rc.switch))
    lentry_switch.grid(row=5, column=1, sticky="ew", padx=5)

    # feedfoward
    global fentry_switch, fentry_level, fentry_start, fentry_stop
    fentry_start_lbl = tk.Label(lfrm_cfg_ffd, text="Start FFD:")
    fentry_start_lbl.grid(row=12, column=0, sticky="ew", padx=5)
    fentry_start = tk.Entry(lfrm_cfg_ffd, text="Start FFD:", width="10")
    fentry_start.delete(0, tk.END)
    fentry_start.insert(0,str(fc.start))
    fentry_start.grid(row=12, column=1, sticky="ew", padx=5)

    fentry_stop_lbl = tk.Label(lfrm_cfg_ffd, text="Stop FFD:")
    fentry_stop_lbl.grid(row=13, column=0, sticky="ew", padx=5)
    fentry_stop = tk.Entry(lfrm_cfg_ffd, text="Stop FFD:", width="10")
    fentry_stop.delete(0,tk.END)
    fentry_stop.insert(0,str(fc.stop))
    fentry_stop.grid(row=13, column=1, sticky="ew", padx=5)

    fentry_level_lbl = tk.Label(lfrm_cfg_ffd, text="Level FFD:")
    fentry_level_lbl.grid(row=14, column=0, sticky="ew", padx=5)
    fentry_level = tk.Entry(lfrm_cfg_ffd, text="Level FFD:", width="10")
    fentry_level.delete(0,tk.END)
    fentry_level.insert(0,str(fc.level))
    fentry_level.grid(row=14, column=1, sticky="ew", padx=5)

    fentry_switch_lbl = tk.Label(lfrm_cfg_ffd, text="Switch FFD:")
    fentry_switch_lbl.grid(row=15, column=0, sticky="ew", padx=5)
    fentry_switch = tk.Entry(lfrm_cfg_ffd, text="Switch FFD:", width="10")
    fentry_switch.delete(0, tk.END)
    fentry_switch.insert(0,str(fc.switch))
    fentry_switch.grid(row=15, column=1, sticky="ew", padx=5)

    # fig
    global lax, lcanvas
    lfig = Figure(figsize=(8,9), dpi=100)
    lax  = lfig.add_subplot(111)

    lax.plot(rc.t, rc.i, 'b-', label="I ref")
    lax.plot(rc.t, rc.q, 'r-', label="Q ref")
    lax.plot(fc.t, fc.i, 'b-.', label="I ffd")
    lax.plot(fc.t, fc.q, 'r-.', label="Q ffd")

    lax.legend()
    lax.grid()
    lax.set_xlabel("Sample")
    lcanvas = FigureCanvasTkAgg(lfig, master=lfrm_fig)
    lcanvas.draw()
    lcanvas.get_tk_widget().grid(column=0, row=1)

    lbtn_update = tk.Button(master=lfrm_cfg, text="Update REF/FFDpulse", command=getSSLS )
    lbtn_update.grid(row=3, column=0, sticky="ew", padx=5)


def getSSLS():
    rc.setStart(int(lentry_start.get()))
    rc.setStop(int(lentry_stop.get()))
    rc.setLevel(int(lentry_level.get()))
    rc.setSwitch(int(lentry_switch.get()))
    rc.update()

    fc.setStart(int(fentry_start.get()))
    fc.setStop(int(fentry_stop.get()))
    fc.setLevel(int(fentry_level.get()))
    fc.setSwitch(int(fentry_switch.get()))
    fc.update()

    lax.clear()
    lax.plot(rc.t, rc.i, 'b-', label="I ref" )
    lax.plot(rc.t, rc.q, 'r-', label="Q ref")
    lax.plot(fc.t, fc.i, 'b-.', label="I ffd")
    lax.plot(fc.t, fc.q, 'r-.', label="Q ffd")
    lax.legend()
    lax.grid()
    lax.set_xlabel("Sample")
    lcanvas.draw_idle()









####### main ###########################################################################
#
# initialisation
#
#########################################################################################
print('... initialisation ...')
d = dev4()
d.init_board()

dc = DataClass(d)
ps = setPowerSupplyClass()
ps.setVddVgg1Vgg2(Vdd=0.0, Vgg1=0.0, Vgg2=0.0)

rc = RefClass(d)
fc = FfdClass(d)
sw = SweepClass(1000,30_000,10000, dc, fc, ps)

window = tk.Tk()
window.title("dev4")



# layout configuration
window.rowconfigure(0, minsize=800, weight=1)
window.columnconfigure(1, minsize=800, weight=1)

# create widgets
frm_main    = tk.Frame(master=window, relief=tk.RAISED, bd=2)
frm_cfg = tk.Frame(master=window, relief=tk.RAISED, bd=2)

# toolbar Menu
menu = tk.Menu(master=window)

fileMenu = tk.Menu(master=menu)
fileMenu.add_command(label="Exit", command=window.destroy)
menu.add_cascade(label="File", menu=fileMenu)

editMenu = tk.Menu(master=menu)
#editMenu.add_command(label="Undo")
#editMenu.add_command(label="Redo")
menu.add_cascade(label="Edit", menu=editMenu)



# tab layout
tabControl = ttk.Notebook(frm_main)

tab1 = ttk.Frame(tabControl)
tab2 = ttk.Frame(tabControl)
tab3 = ttk.Frame(tabControl)
tab4 = ttk.Frame(tabControl)
tab5 = ttk.Frame(tabControl)
tab6 = ttk.Frame(tabControl)
tab7 = ttk.Frame(tabControl)
tab8 = ttk.Frame(tabControl)
tab0 = ttk.Frame(tabControl)
tabc = ttk.Frame(tabControl)

tabControl.add(tab0, text ='  Overview  ')
tabControl.add(tabc, text ='  Controller  ')
tabControl.add(tab1, text ='  Ch.1  ')
tabControl.add(tab2, text ='  Ch.2  ')
tabControl.add(tab3, text ='  Ch.3  ')
tabControl.add(tab4, text ='  Ch.4  ')
tabControl.add(tab5, text ='  Ch.5  ')
tabControl.add(tab6, text ='  Ch.6  ')
tabControl.add(tab7, text ='  Ch.7=VM  ')
tabControl.add(tab8, text ='  Ch.8=REF  ')
tabControl.pack(expand = 1, fill ="both")
tabs=[tab1,tab2,tab3,tab4,tab5,tab6,tab7,tab8]

# overview tab tab0
img = ImageTk.PhotoImage(Image.open("im/loop1.jpg"))
labelov = tk.Label(master=tab0, image=img)
labelov.grid(column=0, row=0)


# embed Matplotlib
fig = [None]*8
ax1 = [None]*8
ax2 = [None]*8
canvas = [None]*9
toolbar = [ None]*8

for i in range(8):
    frm_tab_cfg = tk.Frame(master=tabs[i], relief=tk.RAISED, bd=2, highlightbackground="white", highlightthickness=2)
    frm_tab_fig = tk.Frame(master=tabs[i], relief=tk.RAISED, bd=2)
    frm_tab_cfg.grid(column=0, row=0)
    frm_tab_fig.grid(column=1, row=0)

    #  label
    label1 = tk.Label(master=frm_tab_cfg, text=" Ch."+str(i+1) + " configuration panel", fg="#555")
    label1.grid(column=0, row=0)
    label2 = tk.Label(master=frm_tab_fig, text="Canvas panel", fg="#555")
    label2.grid(column=0, row=0)

    # cfg
    names = ["Attenuation","Delay","Trigger", "option","option","option","option","option","option", "option","option","option","option","option","option","option","option","option","option"]
    for j in range(3):
      Combo5 = ttk.Combobox(frm_tab_cfg, values = ["1", "2", "3"])
      Combo5.set(names[j])
      Combo5.grid(column=0, row=1+j, padx=10, pady=5)


    # fig
    fig[i] = Figure(figsize=(9,8), dpi=100)
    ax1[i] = fig[i].add_subplot(211)

    ax1[i].plot(dc.data[:,i])
    ax1[i].grid()
    ax1[i].set_ylabel("Raw")

    ax2[i] = fig[i].add_subplot(212)
    #ax2[i].plot(10*np.log10(1+dc.envelope[:,i]),'k-')
    ax2[i].plot(dc.envelope[:,i],'k-')
    ax2[i].set_ylabel("Envelope")
    ax2[i].grid()

    if i==7 or i==6:
      ax2[i].clear()
      ax2[i].plot(dc.data[:100,i],'kx-')
      ax2[i].grid()
      ax2[i].set_ylabel("Zoom")

    # make plots
    canvas[i] = FigureCanvasTkAgg(fig[i], master=frm_tab_fig)
    canvas[i].draw()
    canvas[i].get_tk_widget().grid(column=0, row=1)

    # interactive buttons
    toolbar[i] = NavigationToolbar2Tk(canvas[i], frm_tab_fig, pack_toolbar=False)
    toolbar[i].update()
    toolbar[i].grid(row=2, column=0)


####################
## controller tab ##
####################
frm_tabc_cfg = tk.Frame(master=tabc, relief=tk.RAISED, bd=2, highlightbackground="white", highlightthickness=2)
frm_tabc_fig = tk.Frame(master=tabc, relief=tk.RAISED, bd=2)
frm_tabc_cfg.grid(column=0, row=0)
frm_tabc_fig.grid(column=1, row=0)
#  label
labelc = tk.Label(master=frm_tabc_cfg, text=" Control configuration panel", fg="#555")
labelc.grid(column=0, row=0)
label2c = tk.Label(master=frm_tabc_fig, text="Canvas panel (Updated:"+time.ctime(time.time())+")", fg="#555")
label2c.grid(column=0, row=0)
# cfg
names = ["Feedforward (P2P)","Feedback (PI)","LP filter", "I/Q conversion", "Rotation table", "Continuous Poll"]
for j in range(len(names)):
  Combo5 = ttk.Combobox(frm_tabc_cfg, values = ["OFF", "ON"])
  Combo5.set(names[j])
  Combo5.grid(column=0, row=1+j, padx=10, pady=5)
# plot figures in matplotlib
titles=["reference I(r)","measured y", "I(y)", "Q(y)", "error (I(r) - I(y))", "error (Q(r) - Q(y))", "I(u)","Q(u)"]
figc = Figure(figsize=(9,8), dpi=100)
axc = [None]*8
for i in range(8):
  axc[i] = figc.add_subplot(4,2,i+1)
  axc[i].plot(dc.data[:100,8+i],'-x')
  axc[i].set_title(titles[i])
  axc[i].grid()
  if i<6: axc[i].set_xticklabels([])
  #axc.set_ylabel("(Weighted) Input signal")
# plot controller tab on GUI
canvasc = FigureCanvasTkAgg(figc, master=frm_tabc_fig)
canvasc.draw()
canvasc.get_tk_widget().grid(column=0, row=1)

# interactive buttons
toolbarc = NavigationToolbar2Tk(canvasc, frm_tabc_fig, pack_toolbar=False)
toolbarc.update()
toolbarc.grid(row=2, column=0)


# buttons
btn_info = tk.Button(master=frm_cfg, text="Info ...",     command=info_window)
btn_info.grid(row=1, column=0, sticky="ew", padx=5)

btn_update = tk.Button(master=frm_cfg, text="Update!",     command=update_window)
btn_update.grid(row=20, column=0, sticky="ew", padx=5)

btn_saveall = tk.Button(master=frm_cfg, text="Save Signals now ...",     command=lambda:saveas_all())
btn_saveall.grid(row=3, column=0, sticky="ew", padx=5)

#btn_reboot = tk.Button(master=frm_cfg, text="Update 1Hz",     command=update_window )
#btn_reboot.grid(row=2, column=0, sticky="ew", padx=5)

btn_script = tk.Button(master=frm_cfg, text="Sweep ...",     command=sweep_window)
btn_script.grid(row=4, column=0, sticky="ew", padx=5)

btn_trigger = tk.Button(master=frm_cfg, text="Triggers ...",     command=trigger_window)
btn_trigger.grid(row=5, column=0, sticky="ew", padx=5)

btn_clock = tk.Button(master=frm_cfg, text="Clocks ...",     command=clock_window)
btn_clock.grid(row=6, column=0, sticky="ew", padx=5)

btn_ilk = tk.Button(master=frm_cfg, text="Interlock ...",     command=ilk_window)
btn_ilk.grid(row=7, column=0, sticky="ew", padx=5)

btn_calli = tk.Button(master=frm_cfg, text="Callibration ...",     command=calli_window)
btn_calli.grid(row=8, column=0, sticky="ew", padx=5)

btn_pulse = tk.Button(master=frm_cfg, text="REF/FFD ...",     command=pulse_window)
btn_pulse.grid(row=9, column=0, sticky="ew", padx=5)

label_time = tk.Label(master=frm_cfg, text="Last Updated: \n" + time.ctime(time.time()), fg="#555" )
label_time.grid(column=0, row=100, sticky="ew", padx=5)

label0 = tk.Label(master=frm_cfg, text="Global configuration panel", fg="#555")
label0.grid(column=0, row=0, sticky="ew", padx=5)

frm_cfg.grid(row=0, column=0, sticky="ns")
frm_main.grid(row=0, column=1, sticky="nsew")

window.config(menu=menu)
window.mainloop()





