################################################################################
# Task 4 - Flat Physical Synthesis Script
################################################################################
# Usage: innovus -stylus -batch -files pnr_flat.tcl
################################################################################

#1. Source global variables
source ../phy/scr/global_variables.tcl

#2. Reading the design
source ../phy/scr/read_design.tcl

#5. Floorplan
create_floorplan -site SC8T_104CPP_CMOS22FDX -core_density_size 0.7 0.7 10.0 10.0 10.0 10.0

#6. Power planning
source ../phy/scr/powerplan.tcl

#7. Place
place_design
assign_io_pins

#8. Clock Tree Synthesis
ccopt_design

#9. Route design
assign_io_pins
route_design

#10. Write design
exec mkdir -p ${OUTPUT_DIR}/flat
write_db ${OUTPUT_DIR}/flat/${TOP_NAME}.dat

#11. Write netlist
write_netlist ${OUTPUT_DIR}/flat/${TOP_NAME}.v

#12. Generate reports
exec mkdir -p ${RPT_DIR}/flat
report_timing -max_paths 10 > ${RPT_DIR}/flat/${TOP_NAME}_timing_setup.rpt
report_timing -max_paths 10 -delay_type min > ${RPT_DIR}/flat/${TOP_NAME}_timing_hold.rpt
report_area > ${RPT_DIR}/flat/${TOP_NAME}_area.rpt
report_power > ${RPT_DIR}/flat/${TOP_NAME}_power.rpt
report_drc > ${RPT_DIR}/flat/${TOP_NAME}_drc.rpt

puts "\n=========================================="
puts "Flat Physical Synthesis Complete!"
puts "Reports: ${RPT_DIR}/flat/"
puts "Outputs: ${OUTPUT_DIR}/flat/"
puts "=========================================="
