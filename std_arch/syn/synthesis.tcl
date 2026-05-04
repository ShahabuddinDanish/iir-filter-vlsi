# analyze source files

analyze -format VHDL -library WORK ../src/filter_param_pkg.vhd
analyze -format VHDL -library WORK ../src/reg.vhd
analyze -format VHDL -library WORK ../src/logic_reg.vhd
analyze -format VHDL -library WORK ../src/filter.vhd

# preserve rtl names in netlist
set power_preserve_rtl_hier_name true

# elaborate top entity
elaborate iirfilter -architecture Behavioral -lib work
uniquify
link

# applying constraints
set WCP 2.77
create_clock -name "MY_CLK" -period $WCP CLK
set_dont_touch_network MY_CLK

# simulate clock jitter
set_clock_uncertainty 0.07 [get_clocks MY_CLK]

# verify the clock
report_clock > ./reports/gatedclock_fmax.rpt

# max output delay
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] CLK]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]

# output load
set OUTPUT_LOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OUTPUT_LOAD [all_outputs]
check_design

# compile
compile -gate_clock

# timing, area and power report
report_timing > ./reports/gatedtiming_fmax.rpt
report_area > ./reports/gatedarea_fmax.rpt
#report_power > ./reports/power_fmax.rpt 

# export netlist
ungroup -all -flatten
change_names -hierarchy -rules verilog
write_sdf ../netlist/iirfilter.sdf
write -f verilog -hierarchy -output ../netlist/iirfilter.v
write_sdc ../netlist/iirfilter.sdc
exit
