import socket
import time


class setPowerSupplyClass:
    def __init__(self):
        #create an INET, STREAMing socket (IPv4, TCP/IP)
        try:
            self.client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            ROBOT_IP= "192.168.30.109"  # IP address power supply (see web interface)
            ROBOT_PORT = 5025           # IP port power supply (see web interface)
            self.client.connect((ROBOT_IP,ROBOT_PORT))
            print('Socket Connected to ' + ROBOT_IP )
        except:
            print('Failed to create socket')
            self.client = None


    def setVddVgg(self, Vdd,Vgg):
        try:
            self.client.send(bytes('INST OUT2\n','ascii'))
            self.client.send(bytes('VOLT '+str(Vdd) +'\n','ascii'))
            self.client.send(bytes('OUTP SEL ON\n','ascii'))

            self.client.send(bytes('INST OUT1\n','ascii'))
            self.client.send(bytes('VOLT '+str(Vgg) +'\n','ascii'))
            self.client.send(bytes('OUTP SEL ON\n','ascii'))

            self.client.send(bytes('OUTP:GEN:STAT ON','ascii')) 
        except socket.error:
            print('Failed to send command')


    def setVddVgg1Vgg2(self, Vdd,Vgg1, Vgg2):
       if self.client != None: 
            self.client.send(bytes('INST OUT1\n','ascii'))
            self.client.send(bytes('VOLT '+str(Vdd) +'\n','ascii'))
            self.client.send(bytes('OUTP SEL ON\n','ascii'))

            self.client.send(bytes('INST OUT2\n','ascii'))
            self.client.send(bytes('VOLT '+str(Vgg1) +'\n','ascii'))
            self.client.send(bytes('OUTP SEL ON\n','ascii'))

            self.client.send(bytes('INST OUT3\n','ascii'))
            self.client.send(bytes('VOLT '+str(Vgg2) +'\n','ascii'))
            self.client.send(bytes('OUTP SEL ON\n','ascii'))

            self.client.send(bytes('OUTP:GEN:STAT ON','ascii')) 
            self.status()
            self.status()


    def test(self):
       self.client.send(bytes('VOLT?\n','ascii'))
       msg = self.client.recv(1024).decode('ascii')
       print("received:", msg)


    # Master switch for all the outputs - switch OFF
    #   OUTPut:GENeral:STATe OFF
    def off(self):
      self.setVddVgg1Vgg2(Vdd=0.0, Vgg1=0.0, Vgg2=0.0)

      self.client.send(bytes('INST OUT1\n','ascii'))
      self.client.send(bytes('OUTP SEL OFF\n','ascii'))

      self.client.send(bytes('INST OUT2\n','ascii'))
      self.client.send(bytes('OUTP SEL OFF\n','ascii'))

      self.client.send(bytes('INST OUT3\n','ascii'))
      self.client.send(bytes('OUTP SEL OFF\n','ascii'))
      
      self.client.send(bytes('OUTP:GEN:STAT OFF','ascii')) 

    def status(self):
      self.client.send(bytes('INST OUT1\n','ascii'))
      self.client.send(bytes('VOLT?\n','ascii'))
      msg = self.client.recv(1024).decode('ascii')
      #print("Ch.1: V received:", msg)

      self.client.send(bytes('INST OUT2\n','ascii'))
      self.client.send(bytes('VOLT?\n','ascii'))
      msg = self.client.recv(1024).decode('ascii')
      #print("Ch.2: V received:", msg)

      self.client.send(bytes('INST OUT3\n','ascii'))
      self.client.send(bytes('VOLT?\n','ascii'))
      msg = self.client.recv(1024).decode('ascii')
      #print("Ch.3: V received:", msg)

