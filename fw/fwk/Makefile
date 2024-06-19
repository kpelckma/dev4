# -------------------------------------------------------------------------------
# --          ____  _____________  __                                          --
# --         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
# --        / / / / __/  \__ \  \  /                 / \ / \ / \               --
# --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
# --      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
# --                                                                           --
# -------------------------------------------------------------------------------
# main MSK FPGA Firmware Framework Make-file


SHELL = /bin/bash -c
COLORTERM = 1

# FWK_TOPDIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
FWK_TOPDIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: config install install_dev env env_dev

export FWK_TOPDIR

# ----------------------------------------------------------------------------
# check if there is xtclsh in path
define NOXTCLSH_MSG
No 'xtclsh' in PATH
Consider running Xilinx settings script: source $${XILINX_PATH}/settings64.sh

endef

define WRONGPATH_MSG
Running Makefile from framwork location, run it from 1 level up project

endef


# use xtclsh if available, else tclsh
ifneq (, $(shell which xtclsh))
TCLSH := $(shell which xtclsh)
else
TCLSH := $(shell which tclsh)
endif
$(info TCL shell: $(TCLSH))

ifneq (,$(wildcard ./src/main.tcl))
$(error $(WRONGPATH_MSG))
endif

# ------------------------------------------------------------------------------
# check and set VENV
VENV_NAME=.venv
VIRTUAL_ENV=$(PWD)/${VENV_NAME}
PYTHON=${VENV_NAME}/bin/python

define NOVIRT_ENV
WARNING
No virtual enviroment '$(VIRTUAL_ENV)' found.
Trying to use globally installed tools.
Please run 'make env' first to have all needed tools intalled locally in virtual env.

endef
# ------------------------------------------------------------------------------
# HELP
define HELPMSG0
#tag::adocHelp[]
Makefile for Firmware Framework projects.
  make <target>
  make <target> cfg=config
  make <target> cfgFile=cfg/config.cfg

  Target :
    -- generic
    make project            - generate project based on the configuration
    make gui                - open generated project based on the configuration
    make build              - build generated project based on the configuration
    make sim                - run simlation of generated project based on the configuration
    make csim               - run C simlation of generated project based on the configuration
    make clean              - cleans project build folder
    make info               - prints configuration
    -- Tool Depended
    make <ToolType>         - generates Tool project
    make <ToolType>_gui     - open generated project with Tool GUI
    make <ToolType>_build   - build tool project (implementation + bit)
#end::adocHelp[]
endef

# filter out adoc tags
HELPMSG1=$(subst \#tag::adocHelp[],,$(HELPMSG0))
HELPMSG=$(subst \#end::adocHelp[],,$(HELPMSG1))

# ----------------------------------------------------------------------------
# default message
default:
	$(info $(HELPMSG))


set_venv:
  ifeq (,$(wildcard $(VIRTUAL_ENV)/bin/activate))
  $(warning ${NOVIRT_ENV})
  else
  $(info VIRTUAL ENVIRONMENT: $(VIRTUAL_ENV))
  export BASH_ENV=$(VIRTUAL_ENV)/bin/activate
  endif


# ----------------------------------------------------------------------------
# default variables
cfg=default

ifeq (,$(wildcard cfg/$(cfg).cfg))
$(error Configuration file: cfg/$(cfg).cfg :do not exist)
else
cfgFile=cfg/$(cfg).cfg
endif

# ----------------------------------------------------------------------------
# load configuration from files
include cfg/default.cfg
$(info Including config file: $(cfgFile) )
include $(cfgFile)
ProjectFolder=prj/${ProjectName}_${ProjectConf}

# Detect MS Windows (only Windows should have $OS set)
# https://stackoverflow.com/a/4511164
ifdef OS
	MKDIR_P=mkdir
	FixPath=$(subst /,\,$1)
else
	MKDIR_P=mkdir -p
	FixPath=$1
endif

# ----------------------------------------------------------------------------
# YOCTO - include always to have auto completion in bash
#ifeq ($(ToolType),yocto)
include fwk/yocto.mk
#endif

ifeq ($(ToolType),vitis_hls)
hls_target=none
# Check if Vitis_HLS root directory set
ifdef XILINX_HLS
$(info XILINX_HLS is defined as $(XILINX_HLS))
else
$(error XILINX_HLS is not defined! Please consider adding the path to "../Xilinx/Vitis_HLS/<version>/" to enviroment variables)
endif
endif



# ----------------------------------------------------------------------------
# export all makefile variables to child processes
export

# ----------------------------------------------------------------------------
# TARGETS
# ----------------------------------------------------------------------------
# load config files
config: $(ProjectFolder) set_venv

${ProjectFolder}:
	$(MKDIR_P) $(call FixPath,${ProjectFolder})

# ----------------------------------------------------------------------------
# Install all dependencies in local environment
$(VIRTUAL_ENV):
	python3 -m venv $(VIRTUAL_ENV)
  export BASH_ENV=$(VIRTUAL_ENV)/bin/activate

install: env
install_dev: env_dev

env: $(VIRTUAL_ENV)
	pip install pip --upgrade
	pip install jinja2-cli
	pip install -e fwk/tls/desyrdl


# ----------------------------------------------------------------------------
# Install development tools. Not required to build firmware projects
env_dev: env
	pip install cocotb
	pip install pyuvm
	pip install pytest
	pip install numpy
	pip install scipy
	pip install matplotlib

# ----------------------------------------------------------------------------
# Tool independent generic commands
# generate project with the tool based on configuration
project: config $(ToolType)

# open project GUI with the tool based on configuration
gui: config $(ToolType)_gui

build: config $(ToolType)_build

sim: config $(ToolType)_sim

csim: config $(ToolType)_csim

clean: config $(ToolType)_clean

synth: config $(ToolType)_synth

info: config
	$(TCLSH) ./fwk/src/main.tcl info -c ${cfgFile} --colorterm ${COLORTERM}

init: config
	$(TCLSH) ./fwk/src/main.tcl init -c ${cfgFile} --colorterm ${COLORTERM}

map: config
	$(TCLSH) ./fwk/src/main.tcl init addr -c ${cfgFile} -a map -t shell --colorterm ${COLORTERM}

rdl: config
	$(TCLSH) ./fwk/src/main.tcl init addr -c ${cfgFile} -a rdl -t shell --colorterm ${COLORTERM}

# ----------------------------------------------------------------------------
# Xilinx ISE
xise: config
	xtclsh ./fwk/src/main.tcl init create -c ${cfgFile} -t xise --exit --colorterm ${COLORTERM}

xise_build: config
	xtclsh ./fwk/src/main.tcl init build -c ${cfgFile} -t xise --exit --colorterm ${COLORTERM}

xise_clean:
	xtclsh ./fwk/src/main.tcl clean -c ${cfgFile} -t xise --exit --colorterm ${COLORTERM}

xise_gui:
	@cd prj/${ProjectName}_${ProjectConf} ; ise ${ProjectName}_${ProjectConf}.xise

# ----------------------------------------------------------------------------
# Xilinx planahead
planahead: config
	planAhead -mode tcl -source ./fwk/src/main.tcl \
	-notrace -journal prj/${ProjectName}_${ProjectConf}/${ProjectName}_${ProjectConf}.jou \
	-log prj/${ProjectName}_${ProjectConf}/${ProjectName}_${ProjectConf}.log \
	-tclargs "init create -c ${cfgFile} -t planahead --exit --colorterm ${COLORTERM}"

planahead_build: config
	planAhead -mode tcl -source ./fwk/src/main.tcl \
	-notrace -journal prj/${ProjectName}_${ProjectConf}/${ProjectName}_${ProjectConf}.jou \
	-log prj/${ProjectName}_${ProjectConf}/${ProjectName}_${ProjectConf}.log \
	-tclargs "init build -c ${cfgFile} -t planahead --exit --colorterm ${COLORTERM}"

planahead_gui: config
	@cd prj/${ProjectName}_${ProjectConf} ; \
	planAhead ${ProjectName}_${ProjectConf}.ppr \
	-journal ${ProjectName}_${ProjectConf}.jou \
	-log ${ProjectName}_${ProjectConf}.log \
	-source ../../fwk/src/main.tcl -notrace  -tclargs "init gui -c ../../${cfgFile} -t planahead"

planahead_clean:
	$(TCLSH) ./fwk/src/main.tcl clean -c ${cfgFile} -t planahead  --colorterm ${COLORTERM}

# ----------------------------------------------------------------------------
# Xilinx Vivado
vivado: config
	vivado -mode tcl -source ./fwk/src/main.tcl \
	-notrace -journal prj/${ProjectName}_${ProjectConf}/${ProjectName}_${ProjectConf}.jou \
	-log prj/${ProjectName}_${ProjectConf}/${ProjectName}_${ProjectConf}.log \
	-tclargs init create -c ${cfgFile} -t vivado --exit --colorterm ${COLORTERM}

vivado_build: config
	vivado -mode tcl -source ./fwk/src/main.tcl \
	-notrace -journal prj/${ProjectName}_${ProjectConf}/${ProjectName}_${ProjectConf}.jou \
	-log prj/${ProjectName}_${ProjectConf}/${ProjectName}_${ProjectConf}.log \
	-tclargs init build -c ${cfgFile} -t vivado --exit --colorterm ${COLORTERM}

vivado_sim: config
	vivado -mode tcl -source ./fwk/src/main.tcl \
	-notrace -journal prj/${ProjectName}_${ProjectConf}/${ProjectName}_${ProjectConf}.jou \
	-log prj/${ProjectName}_${ProjectConf}/${ProjectName}_${ProjectConf}.log \
	-tclargs init simulate -c ${cfgFile} -t vivado --exit --colorterm ${COLORTERM}

vivado_gui: config
	vivado -mode tcl -source ./fwk/src/main.tcl \
	-notrace -journal prj/${ProjectName}_${ProjectConf}/${ProjectName}_${ProjectConf}.jou \
	-log prj/${ProjectName}_${ProjectConf}/${ProjectName}_${ProjectConf}.log \
	-tclargs init gui -c ${cfgFile} -t vivado

vivado_map: config
	vivado -mode tcl -source ./fwk/src/main.tcl \
	-notrace -journal prj/${ProjectName}_${ProjectConf}/${ProjectName}_${ProjectConf}.jou \
	-log prj/${ProjectName}_${ProjectConf}/${ProjectName}_${ProjectConf}.log \
	-tclargs init addr -c ${cfgFile} -t vivado -a $(AddrType) --exit --colorterm ${COLORTERM}

vivado_clean:
	$(TCLSH) ./fwk/src/main.tcl clean -c ${cfgFile} -t vivado --colorterm ${COLORTERM}

# ----------------------------------------------------------------------------
# xsdk
xsdk: config
	xsct -eval source ./fwk/src/main.tcl init create -c ${cfgFile} -t xsdk --exit --colorterm ${COLORTERM}

xsdk_build:
	xsct -eval source ./fwk/src/main.tcl init build -c ${cfgFile} -t xsdk --exit --colorterm ${COLORTERM}

xsdk_clean:
	xsct -eval source ./fwk/src/main.tcl init clean -c ${cfgFile} -t xsdk --exit

xsdk_gui:
	xsdk -workspace prj

# ----------------------------------------------------------------------------
# rust_hdl
rust_hdl: config
	$(TCLSH) ./fwk/src/main.tcl init create -c ${cfgFile} -t rust_hdl --exit --colorterm ${COLORTERM}
# ----------------------------------------------------------------------------
# vhd tool
vhdl_tool: config
	$(TCLSH) ./fwk/src/main.tcl init create -c ${cfgFile} -t vhdl_tool --exit --colorterm ${COLORTERM}

# ----------------------------------------------------------------------------
# ghdl
ghdl : config
	$(TCLSH) ./fwk/src/main.tcl init create -c ${cfgFile} -t ghdl --exit --colorterm ${COLORTERM}
	@echo -e "\033[1;36m== CMAKE ==\033[0m"
	@cd prj/${ProjectName}_${ProjectConf}/ && cmake ./

ghdl_sim : config
	@echo -e "\n\033[1;36m== GHDL SIM ==\033[0m"
  # @env CTEST_OUTPUT_ON_FAILURE=TRUE # not needed when -V flag is active, will duplicate log
	$(MAKE) -C prj/${ProjectName}_${ProjectConf} -s elab test ARGS="-V"

ghdl_build : config
	@echo -e "\n\033[1;36m== GHDL SYNTH ==\033[0m"
	$(MAKE) -C prj/${ProjectName}_${ProjectConf} -s synth

# ----------------------------------------------------------------------------
# modelsim
modelsim : config
	vsim -c -logfile prj/${ProjectName}_${ProjectConf}/modelsim.log -do "do ./fwk/src/main.tcl init create -c ${cfgFile} -t modelsim --exit --colorterm ${COLORTERM}"

modelsim_gui : config
	vsim -appendlog -logfile prj/${ProjectName}_${ProjectConf}/modelsim.log -do "do ./fwk/src/main.tcl init simulate -c ${cfgFile} -t modelsim --colorterm ${COLORTERM}"

modelsim_sim : config
	@echo -e "\n\033[1;36m== MODELSIM SIM ==\033[0m"
	vsim -c -appendlog -logfile prj/${ProjectName}_${ProjectConf}/modelsim.log -do "do ./fwk/src/main.tcl init simulate -c ${cfgFile} -t modelsim --exit --colorterm ${COLORTERM}"

modelsim_clean:
	$(TCLSH) ./fwk/src/main.tcl clean -c ${cfgFile} -t modelsim

# ----------------------------------------------------------------------------
# cocotb
cocotb : config
	$(TCLSH) ./fwk/src/main.tcl init create -c ${cfgFile} -t cocotb --exit --colorterm ${COLORTERM}

cocotb_sim : config
	$(TCLSH) ./fwk/src/main.tcl init simulate -c ${cfgFile} -t cocotb --exit --colorterm ${COLORTERM}

cocotb_gui : config
	gtkwave prj/${ProjectName}_${ProjectConf}/dump.vcd

# ----------------------------------------------------------------------------
# vitis
vitis:
	xsct -eval source ./fwk/src/main.tcl init create -c ${cfgFile} -t vitis --exit  --colorterm ${COLORTERM}

vitis_build:
	xsct -eval source ./fwk/src/main.tcl init build -c ${cfgFile} -t vitis --exit  --colorterm ${COLORTERM}

vitis_gui:
	@cd prj/${ProjectName}_${ProjectConf} ; \
	vitis -workspace .

# ----------------------------------------------------------------------------
# vitis hls
vitis_hls:
	$(MKDIR_P) prj/${ProjectName}_${ProjectConf}/csim
	export hls_target=vitis_hls; \
	vitis_hls ./fwk/src/fwfwk_load_hls.tcl
	@echo -e "\n\033[1;36m== cmake (csim) project ==\033[0m"
	@cd prj/${ProjectName}_${ProjectConf}/csim && cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ../
	@ln -fs prj/${ProjectName}_${ProjectConf}/csim/compile_commands.json .

vitis_hls_sim:
	export hls_target=vitis_hls_sim; \
	$(TCLSH) ./fwk/src/fwfwk_load_hls.tcl

vitis_hls_csim:
	@echo -e "\n\033[1;36m== Compile ==\033[0m"
	$(MAKE) -C prj/${ProjectName}_${ProjectConf}/csim -s
	@echo -e "\n\033[1;36m== CTest ==\033[0m"
	$(MAKE) -C prj/${ProjectName}_${ProjectConf}/csim -s test ARGS="-V"

vitis_hls_synth:
	export hls_target=vitis_hls_synth; \
	vitis_hls ./fwk/src/fwfwk_load_hls.tcl

vitis_hls_build:
	export hls_target=vitis_hls_build; \
	vitis_hls ./fwk/src/fwfwk_load_hls.tcl

vitis_hls_gui:
	@cd prj ; \
	vitis_hls -p ${ProjectName}_${ProjectConf}

# ----------------------------------------------------------------------------
# appguru
appguru: config
	$(TCLSH) ./fwk/src/main.tcl init create -c ${cfgFile} -t appguru --exit --colorterm ${COLORTERM}

appguru_build: config
	$(TCLSH) ./fwk/src/main.tcl init build -c ${cfgFile} -t appguru --exit --colorterm ${COLORTERM}

# ----------------------------------------------------------------------------
# documentation targets
doc: config
	$(TCLSH) ./fwk/src/main.tcl init doc -dt "adoc pdf antora" -t doc -c ${cfgFile} --exit --colorterm ${COLORTERM}

doc_antora: config
	$(TCLSH) ./fwk/src/main.tcl init doc -dt antora -t doc -c ${cfgFile} --exit --colorterm ${COLORTERM}

doc_pdf: config
	$(TCLSH) ./fwk/src/main.tcl init doc -dt pdf -t doc -c ${cfgFile} --exit --colorterm ${COLORTERM}

doc_adoc: config
	$(TCLSH) ./fwk/src/main.tcl init doc -dt adoc -t doc -c ${cfgFile} --exit --colorterm ${COLORTERM}

# asciidoctor-pdf -a ProjectConf=${ProjectConf} \
# -o out/${ProjectName}_${ProjectConf}.pdf \
# doc/main.adoc
