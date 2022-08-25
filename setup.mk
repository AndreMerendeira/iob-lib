
# core info
include $(CORE_DIR)/info.mk
ifneq ($(wildcard $(CORE_DIR)/config_setup.mk),)
include $(CORE_DIR)/config_setup.mk
endif

# enable all flows in setup by default
SETUP_SW ?=1
SETUP_SIM ?=1
SETUP_FPGA ?=1
SETUP_DOC ?=1

# core internal paths
CORE_SW_DIR=$(CORE_DIR)/software
CORE_EMB_DIR=$(CORE_SW_DIR)/embedded
CORE_PC_DIR=$(CORE_SW_DIR)/pc-emul
CORE_HW_DIR=$(CORE_DIR)/hardware
CORE_SIM_DIR=$(CORE_HW_DIR)/simulation
CORE_FPGA_DIR=$(CORE_HW_DIR)/fpga
CORE_DOC_DIR=$(CORE_DIR)/document


# make version header
VERSION_STR:=$(shell software/python/version.py $(NAME) $(VERSION))

# establish build dir paths
BUILD_DIR := $(CORE_DIR)/$(NAME)_$(VERSION_STR)
BUILD_SW_DIR:=$(BUILD_DIR)/sw
BUILD_SW_PYTHON_DIR:=$(BUILD_SW_DIR)/python
BUILD_SW_SRC_DIR:=$(BUILD_DIR)/sw/src
BUILD_SW_PC_DIR:=$(BUILD_SW_DIR)/pc
BUILD_SW_EMB_DIR:=$(BUILD_SW_DIR)/emb
BUILD_VSRC_DIR:=$(BUILD_DIR)/hw/vsrc
BUILD_SIM_DIR:=$(BUILD_DIR)/hw/sim
BUILD_FPGA_DIR:=$(BUILD_DIR)/hw/fpga
BUILD_DOC_DIR:=$(BUILD_DIR)/doc
BUILD_TSRC_DIR:=$(BUILD_DOC_DIR)/tsrc
BUILD_FIG_DIR:=$(BUILD_DOC_DIR)/figures
BUILD_SYN_DIR:=$(BUILD_DIR)/hw/syn

# create build directory
$(BUILD_DIR):
	cp -r -u build $@

# import core hardware and simulation files
include $(CORE_HW_DIR)/hardware.mk
include $(CORE_SIM_DIR)/sim_setup.mk

# import core software files
include $(CORE_SW_DIR)/software.mk

# copy core version header file
SRC+=$(BUILD_VSRC_DIR)/$(NAME)_version.vh
$(BUILD_VSRC_DIR)/$(NAME)_version.vh: $(NAME)_version.vh
	cp -u $< $@

setup: $(BUILD_DIR) $(SRC)
	echo "VERSION_STR=$(VERSION_STR)" > $(BUILD_DIR)/version.mk
	cp -u $(CORE_DIR)/info.mk $(BUILD_DIR)
ifneq ($(wildcard $(CORE_DIR)/config.mk),)
	cp -u $(CORE_DIR)/config.mk $(BUILD_DIR)
endif
ifneq ($(wildcard $(CORE_DIR)/mkregs.conf),)
	cp -u $(CORE_DIR)/mkregs.conf $(BUILD_TSRC_DIR)
endif
ifneq ($(SETUP_SW),0)
ifneq ($(wildcard $(CORE_PC_DIR)/*.expected),)
	cp -u $(CORE_PC_DIR)/*.expected $(BUILD_SW_PC_DIR)
endif
ifneq ($(wildcard $(CORE_PC_DIR)/pc-emul.mk),)
	cp -u $(CORE_PC_DIR)/pc-emul.mk $(BUILD_SW_PC_DIR)
endif
ifneq ($(wildcard $(CORE_EMB_DIR)/embedded.mk),)
	cp -u $(CORE_EMB_DIR)/embedded.mk $(BUILD_SW_EMB_DIR)
endif
endif
ifneq ($(SETUP_SIM),0)
	cp -u $(CORE_SIM_DIR)/*.expected $(BUILD_SIM_DIR)
ifneq ($(wildcard $(CORE_SIM_DIR)/simulation.mk),)
	cp -u $(CORE_SIM_DIR)/simulation.mk $(BUILD_SIM_DIR)
endif
ifneq ($(wildcard $(CORE_SIM_DIR)/*_tb.*),)
	cp -u $(CORE_SIM_DIR)/*_tb.* $(BUILD_SIM_DIR)
endif
endif
ifneq ($(SETUP_FPGA),0)
ifneq ($(wildcard $(CORE_FPGA_DIR)/*.mk),)
	cp -u $(CORE_FPGA_DIR)/*.mk $(BUILD_FPGA_DIR)
endif
	cp -u $(CORE_FPGA_DIR)/*.expected $(BUILD_FPGA_DIR)
ifneq ($(wildcard $(CORE_FPGA_DIR)/*.sdc),)
	cp -u $(CORE_FPGA_DIR)/*.sdc $(BUILD_FPGA_DIR)
endif
ifneq ($(wildcard $(CORE_FPGA_DIR)/*.xdc),)
	cp -u $(CORE_FPGA_DIR)/*.xdc $(BUILD_FPGA_DIR)
endif
endif
ifneq ($(SETUP_DOC),0)
ifneq ($(wildcard $(CORE_DOC_DIR)/*.mk),)
	cp -u $(CORE_DOC_DIR)/*.mk $(BUILD_DOC_DIR)
endif
ifneq ($(wildcard $(CORE_DOC_DIR)/*.tex),)
	cp -f $(CORE_DOC_DIR)/*.tex $(BUILD_TSRC_DIR)
endif
	cp -u $(CORE_DOC_DIR)/figures/* $(BUILD_FIG_DIR)
endif

.PHONY: version setup