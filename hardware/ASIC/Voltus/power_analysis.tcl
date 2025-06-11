read_db "../Genus/"

set_db power_method static
set_db power_report_missing_nets true

read_activity_file -reset
read_activity_file -format TCF -scope cpu ../Xcelium/tcf.tcf

report_power -rail_analysis_format VS -out_file ./power/rpt 
