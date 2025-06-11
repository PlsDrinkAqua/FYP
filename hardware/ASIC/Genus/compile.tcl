set_db common_ui false
set_attribute hdl_search_path {../picorv32/rtl/core};
set_attribute lib_search_path {/home/ol521/mintNeuroCPU/library/gsclib045_svt_v4.7/gsclib045/lib};
set_attribute library [list slow_vdd1v0_basicCells.lib];
set_attribute lef_library [list gsclib045_tech.lef gsclib045_macro.lef];

set_attribute information_level 9;
set_attribute auto_partition true;

set_attribute super_thread_debug_directory ./

set_attribute delete_unloaded_insts false 
set_attribute hdl_preserve_unused_registers true 
set_attribute optimize_constant_1_flops false 
set_attribute optimize_constant_0_flops false
set_attribute auto_ungroup none /
set_attribute lp_insert_clock_gating true



set myFiles {picorv32.v}
set basename picorv32; 
set myClk clk;
set myPeriod_ps 20000;
set myInDelay_ps 3000;
set myOutDelay_ps 3000;
set runname synth;


# set period_clk27 37037
# 250MHz
# set period_clk27 4000
# 200MHz
# set period_clk27 5000
# 150MHz
# set period_clk27 6667
# 100MHz
set period_clk27 10000
# 50MHz 
# set period_clk27 20000
# 10MHz
# set period_clk27 100000


set clk27_port [find / -port {clk}]






# Analyze and Elaborate the HDL files
read_hdl ${myFiles}
elaborate ${basename}

# Apply Constraints and generate clocks 
set clock1 [define_clock -period $period_clk27 -name clk $clk27_port]
external_delay -input $myInDelay_ps -clock clk [find / -port ports_in/*]
external_delay -output $myOutDelay_ps -clock clk [find / -port ports_out/*]
# set clock [define_clock -period ${myPeriod_ps} -name ${myClk} [clock_ports]]
# external_delay -input $myInDelay_ps -clock ${myClk} [find / -port ports_in/*]
# external_delay -output $myOutDelay_ps -clock ${myClk} [find / -port ports_out/*]

# Set external pin cap
set_attribute external_pin_cap 500 [find / -port ports_out/*]
set_attribute external_wire_cap 100 [find / -port ports_in/*]

# Set input constraint
set_attribute external_driver_input_slew {100 100} [find / -port ports_in/*]
set_attribute fixed_slew 100 [find / -port ports_in/*]

# Set transition to default values for Synopsys SDC format, fall/rise 400ps
# dc::set_clock_transition .4 $myClk

dc::set_clock_transition .4 clk

# check that the design is OK so far
check_design -unresolved
report timing -lint

# Synthesize the design to the target library
synthesize -to_mapped
insert_tiehilo_cells -hi TIEHI -lo TIELO ${basename}
#edit_netlist group -group_name pixelarray [find / -instance *.Pixel_i] pixel_0
#change_names -instance -restricted {[} -replace_str "l["
#change_names -instance -restricted {].} -replace_str "]_"
# Write out the reports
report timing > ${basename}_${runname}_timing.rep 
report gates  > ${basename}_${runname}_cell.rep 
report area   > ${basename}_${runname}_area.rep 
report power  > ${basename}_${runname}_power.rep 
report_clock_gating > ${basename}_${runname}_clockgating.txt

# Write out the structural Verilog and sdc files
write_hdl -mapped > ${basename}_${runname}.v
write_sdc > ${basename}_${runname}.sdc
write_sdf > ${basename}_${runname}.sdf
write_design -base_name ${basename}_${runname} -innovus
