gui_set_ui main -geometry "1480x870+0+0"

set design(TOPLEVEL) "soc"
set runtype "pnr"
set debug_file "debug.txt"

# Set script+report directories
set LAYOUT_SCRIPTS ./layout
set LAYOUT_REPORTS ./layout-reports

set_db init_power_nets VDD
set_db init_ground_nets VSS

read_mmmc ./mmmc.tcl

read_physical -lef {
  /home/ol521/mintNeuroCPU/library/gsclib045_svt_v4.7/gsclib045/lef/gsclib045_tech.lef \
  /home/ol521/mintNeuroCPU/library/gsclib045_svt_v4.7/gsclib045/lef/gsclib045_macro.lef
}

read_netlist {../Genus/picorv32_synth.v}

init_design

connect_global_net vdd -pin VDD -all -verbose
connect_global_net gnd -pin VSS -all -verbose

connect_global_net vdd -type TIEHI -all -verbose
connect_global_net gnd -type TIELO -all -verbose

set design(floorplan_ratio) 1
set design(floorplan_utilization) 0.75
set design(floorplan_space_to_core) "15 15 15 15" ;

create_floorplan -core_density_size $design(floorplan_ratio) $design(floorplan_utilization) {*}$design(floorplan_space_to_core)
gui_fit

# Set up PDN
add_rings -nets {VDD VSS} -type core_rings -follow core \
 -layer {top Metal11 bottom Metal11 left Metal10 right Metal10} \
 -width {top 3 bottom 3 left 3 right 3} \
 -spacing {top 3 bottom 3 left 3 right 3} \
 -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} \
 -center 1 -threshold 0

# Create power stripes (VDD, VSS)
add_stripes -nets {VDD VSS} -layer Metal10 \
 -direction vertical \
 -width 3 -spacing 3 -number_of_sets 3

# Connect global nets VDD and VSS
connect_global_net VDD -type pg_pin -pin_base_name VDD -all
connect_global_net VDD -type tie_hi -inst_base_name *
connect_global_net VSS -type pg_pin -pin_base_name VSS -all
connect_global_net VSS -type tie_lo -inst_base_name *

# Create power+ground pins and connect with rings
create_pg_pin -name VDD -net VDD -geom Metal11 0 13 12 19
create_pg_pin -name VSS -net VSS -geom Metal11 0 181 6 187
update_power_vias -add_vias 1 -top_layer Metal11 -bottom_layer Metal10 -area {9 13 12 19}
update_power_vias -add_vias 1 -top_layer Metal11 -bottom_layer Metal10 -area {3 181 6 187}

# Create follow pins (logic-to-power connections)
set_db route_special_via_connect_to_shape { stripe }
route_special -connect core_pin \
 -layer_change_range { Metal1(1) Metal11(11) } \
 -block_pin_target nearest_target \
 -core_pin_target first_after_row_end \
 -allow_jogging 1 \
 -crossover_via_layer_range { Metal1(1) Metal11(11) } \
 -nets { VSS VDD } -allow_layer_change 1 \
 -target_via_layer_range { Metal1(1) Metal11(11) }



# Placement Settings
set_db place_design_floorplan_mode false

# Whether to perform legal
set_db place_design_refine_place true

# Control congestion effort (low/med/high/auto)
set_db place_global_cong_effort auto

# whether to place i/o pins based on placement inst
set_db place_global_place_io_pins true


# Effort (timing+power)
set_db opt_effort high 
set_db opt_power_effort none 

# Simplify netlist
set_db opt_remove_redundant_insts true

set_db opt_area_recovery default

# Leakage to dynamic ratio
set_db opt_leakage_to_dynamic_ratio 1.0

# Place design 
place_design
opt_design -pre_cts

# Check placement
check_place

# Generate reports
report_area > $LAYOUT_REPORTS/area_prects.txt
# report_power > $LAYOUT_REPORTS/power_prects.txt
time_design -pre_cts -slack_report > $LAYOUT_REPORTS/timing_setup_prects.txt
time_design -pre_cts -hold -slack_report > $LAYOUT_REPORTS/timing_hold_prects.txt
report_gate_count -out_file $LAYOUT_REPORTS/gates_prects.txt
report_qor -file $LAYOUT_REPORTS/qor_prects.txt
report_route -summary > $LAYOUT_REPORTS/route_prects.txt


set_db route_early_global_bottom_routing_layer 1
set_db route_early_global_top_routing_layer 11

# Run early global route
route_early_global

# NDR for clock tree tracks (double spacing+width)
create_route_rule -name NDR_ClockTree \
 -width {Metal1 0.12 Metal2 0.16 Metal3 0.16 Metal4 0.16 Metal5 0.16 Metal6 0.16 Metal7 0.16 Metal8 0.16 Metal9 0.16 Metal10 0.44 Metal11 0.44 } \
 -spacing {Metal1 0.12 Metal2 0.14 Metal3 0.14 Metal4 0.14 Metal5 0.14 Metal6 0.14 Metal7 0.14 Metal8 0.14 Metal9 0.14 Metal10 0.4 Metal11 0.4 } \

# Clock tree configuration:
# Routing on layers 9-5 and in between
create_route_type -name ClockTrack -top_preferred_layer 9 -bottom_preferred_layer 5 -route_rule NDR_ClockTree

# Timing targets and track types
# max skew 100 ps (0.1 TU), max transition time 150 ps (0.15 TU)
set_db cts_route_type_leaf ClockTrack
set_db cts_route_type_trunk ClockTrack
set_db cts_target_skew 0.1
set_db cts_target_max_transition_time 0.15

# Save all constraints (above + SDC)
create_clock_tree_spec -out_file interm/layout/clocktree.spec

# Design clock tree
ccopt_design


report_clock_trees > $LAYOUT_REPORTS/clocktree.txt
report_skew_groups > $LAYOUT_REPORTS/clocktree_skew.txt

# Optimize again after CTS
opt_design -post_cts


report_area > $LAYOUT_REPORTS/area_postcts.txt
time_design -post_cts -slack_report > $LAYOUT_REPORTS/timing_setup_postcts.txt
time_design -post_cts -hold -slack_report > $LAYOUT_REPORTS/timing_hold_postcts.txt
report_gate_count -out_file $LAYOUT_REPORTS/gates_postcts.txt
report_qor -file $LAYOUT_REPORTS/qor_postcts.txt
report_route -summary > $LAYOUT_REPORTS/route_postcts.txt

set_db route_design_top_routing_layer 11
set_db route_design_bottom_routing_layer 1

set_db route_design_concurrent_minimize_via_count_effort high
set_db route_design_detail_fix_antenna true
set_db route_design_with_timing_driven true
set_db route_design_with_si_driven true

route_design -global_detail -via_opt

set_db timing_analysis_type ocv

opt_design -post_route

report_area > $LAYOUT_REPORTS/area_postroute.txt
report_gate_count -out_file $LAYOUT_REPORTS/gates_postroute.txt
report_qor -file $LAYOUT_REPORTS/qor_postroute.txt
report_route -summary > $LAYOUT_REPORTS/route_postroute.txt

time_design -post_route -slack_report > $LAYOUT_REPORTS/timing_setup_postroute.txt
time_design -post_route -hold -slack_report > $LAYOUT_REPORTS/timing_hold_postroute.txt
set_db timing_analysis_type single


check_drc
check_connectivity -type all

# Fill unused space with metal
set_metal_fill -layer { Metal1 Metal2 Metal3 Metal4 Metal5 Metal6 Metal7 Metal8 Metal9 Metal10 Metal11 } -opc_active_spacing 0.200 -min_density 10.00
add_metal_fill -layer { Metal1 Metal2 Metal3 Metal4 Metal5 Metal6 Metal7 Metal8 Metal9 Metal10 Metal11 } -nets { VSS VDD }
