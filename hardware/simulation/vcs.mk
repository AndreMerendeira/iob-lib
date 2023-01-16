SIM_SERVER=$(SYNOPSYS_SERVER)
SIM_USER=$(SYNOPSYS_USER)
SIM_SSH_FLAGS=$(SYNOPSYS_SSH_FLAGS)
SIM_SCP_FLAGS=$(SYNOPSYS_SCP_FLAGS)
SIM_SYNC_FLAGS=$(SYNOPSYS_SYNC_FLAGS)

SFLAGS=-nc -sverilog +incdir+. +incdir+../src  +incdir+src
ifeq ($(VCD),1)
SFLAGS+=+define+VCD
endif

EFLAGS=-debug_access+nomemcbk+dmptf -licqueue -debug_region+cell -notice +bidir+1

#+lint=all +print+bidir+warn


comp: $(VHDR) $(VSRC)
	vlogan $(SFLAGS) $(VSRC) && vcs $(EFLAGS) $(NAME)_tb

exec:
	./simv

clean: gen-clean
	@rm -f simv *.raw

very-clean:


.PHONY: comp exec clean very-clean
