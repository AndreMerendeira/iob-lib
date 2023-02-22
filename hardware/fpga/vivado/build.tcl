#extract cli args
set NAME [lindex $argv 0]
set BOARD [lindex $argv 1]
set VSRC [lindex $argv 2]
set IS_FPGA [lindex $argv 3]
set CUSTOM_ARGS [lindex $argv 4]

puts $NAME
puts $BOARD
puts $VSRC
puts $IS_FPGA
puts $CUSTOM_ARGS


#verilog sources
foreach file [split $VSRC \ ] {
    puts $file
    if {$file != "" && $file != " " && $file != "\n"} {
        read_verilog -sv $file
    }
}

#device data
source vivado/$BOARD/device.tcl

if { $IS_FPGA == "1" } {
    read_xdc vivado/$BOARD/$NAME.xdc
} else {
    read_xdc vivado/$NAME.xdc
}

if {[file exists "vivado/custom_build.tcl"]} {
    source "vivado/custom_build.tcl"
}

if { $IS_FPGA == "1" } {
    synth_design -include_dirs ../src -part $PART -top $NAME -verbose
    place_design
    route_design -timing
} else {
    synth_design -include_dirs ../src -part $PART -top $NAME -mode out_of_context -flatten_hierarchy none -verbose
}

opt_design


report_utilization

report_timing

report_clocks
report_clock_interaction
report_cdc -details

file mkdir reports
report_timing -file reports/timing.txt -from clk -to btxclk -max_paths 5
report_clocks -file reports/clocks.txt
report_clock_interaction -file reports/clock_interaction.txt
report_cdc -details -file reports/cdc.txt
report_synchronizer_mtbf -file reports/synchronizer_mtbf.txt
report_utilization -hierarchical -file reports/utilization.txt

if { $IS_FPGA == "1" } {
    write_bitstream -force $NAME.bit
} else {
    write_edif -force $NAME.edif
    write_verilog -force -mode synth_stub ${NAME}_stub.v
}
