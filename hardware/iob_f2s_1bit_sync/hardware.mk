
ifeq ($(filter iob_f2s_1bit_sync, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_f2s_1bit_sync

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_f2s_1bit_sync.v

# Copy the sources to the build directory
$(BUILD_SRC_DIR)/iob_f2s_1bit_sync.v:hardware/iob_f2s_1bit_sync/iob_f2s_1bit_sync.v
	cp $< $(BUILD_SRC_DIR)

endif
