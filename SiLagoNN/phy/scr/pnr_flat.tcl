################################################################################
# Task 4 - Flat Physical Synthesis Script
################################################################################
#
# This script performs flat physical synthesis without partitioning
# The design is placed and routed as a single flat design
#
# Usage: innovus -stylus -files pnr_flat.tcl
# Or: innovus -stylus -batch -files pnr_flat.tcl
################################################################################

#1. Source global variables
source ../phy/scr/global_variables.tcl

#2. Set multi-CPU usage
set_multi_cpu_usage -local_cpu ${NUM_CPUS} -cpu_per_remote_host 1 -remote_host 0 -keep_license true
set_distributed_hosts -local

#3. Set power and ground nets
set_db init_power_nets {VDD}
set_db init_ground_nets {VSS}

#4. Read MMMC file
read_mmmc ${MMMC_FILE}

#5. Read LEF file
read_physical -lef ${LEF_FILE}

#6. Read logic synthesis netlist
# Check if netlist file exists
if {[file exists ${NETLIST_FILE}]} {
    read_netlist ${NETLIST_FILE}
    puts "Read netlist file: ${NETLIST_FILE}"
} else {
    puts "Error: Netlist file not found: ${NETLIST_FILE}"
    puts "Please check that the netlist file exists in: ${SRC_DIR}/"
    puts "Or update SRC_DIR in global_variables.tcl"
    exit 1
}

#7. Initialize design
init_design

# Note: SDC constraints are already read in MMMC file via create_constraint_mode
# No need to read SDC again here - it's already loaded during read_mmmc
puts "SDC constraints loaded from MMMC configuration"

#9. Create floorplan (for flat synthesis, we still need a floorplan)
# Using site name from GF22FDX technology
# Adjust core_density_size based on your design size and utilization target
# Format: -core_density_size <utilization> <aspect_ratio> <margin_left> <margin_bottom> <margin_right> <margin_top>
puts "Creating floorplan with density-based sizing..."
create_floorplan -site SC8T_104CPP_CMOS22FDX -core_density_size 0.7 0.7 10.0 10.0 10.0 10.0

#10. Power planning
# Note: Power planning can be done manually via GUI or using scripts
# For automated power planning, uncomment and adjust the following:
# Create power rings (use highest metal layers)
# create_power_ring -nets {VDD} -width 5 -spacing 2 -layer {top M9 bottom M9 left M8 right M8}
# create_power_ring -nets {VSS} -width 5 -spacing 2 -layer {top M9 bottom M9 left M8 right M8}
# 
# Create power stripes (adjust spacing based on design)
# create_power_straps -nets {VDD} -layer M8 -width 5 -spacing 20 -direction vertical
# create_power_straps -nets {VSS} -layer M8 -width 5 -spacing 20 -direction vertical
# create_power_straps -nets {VDD} -layer M9 -width 5 -spacing 20 -direction horizontal
# create_power_straps -nets {VSS} -layer M9 -width 5 -spacing 20 -direction horizontal
#
# Connect power (use Route > SpecialRoute in GUI or uncomment below)
# sroute -connect { blockPin padPin padRing corePin floatingStripe } \
#     -layerChangeRange { M1 M9 } \
#     -nets { VDD VSS } \
#     -allowLayerChange 1

puts "Power planning: Please use GUI (Power > Power Planning) or uncomment power planning commands above"

#11. Place design (FLAT - no partitioning)
puts "\n=========================================="
puts "Starting Flat Placement"
puts "=========================================="
place_design

# Assign IO pins after placement
assign_io_pins

#12. Optimize design (pre-CTS optimization)
# Note: place_design already includes optimization, but we can do additional pre-CTS optimization
puts "\n=========================================="
puts "Pre-CTS Optimization"
puts "=========================================="
opt_design -pre_cts

#13. Clock tree synthesis
puts "\n=========================================="
puts "Clock Tree Synthesis"
puts "=========================================="
ccopt_design

#14. Post-CTS optimization
puts "\n=========================================="
puts "Post-CTS Optimization"
puts "=========================================="
opt_design -post_cts

#15. Route design
puts "\n=========================================="
puts "Routing Design"
puts "=========================================="
# Re-assign IO pins before routing
assign_io_pins
route_design

#16. Post-route optimization
puts "\n=========================================="
puts "Post-Route Optimization"
puts "=========================================="

# Enable OCV mode for post-route optimization (required for SI-aware optimization)
# OCV (On-Chip Variation) accounts for process variations
puts "Enabling OCV mode for post-route optimization..."
set_analysis_mode -analysisType onChipVariation

# Enable SI-aware optimization for better signal integrity
set_db opt_design_enable_si_aware true

# Run post-route optimization
if {[catch {opt_design -post_route} result]} {
    puts "Warning: Post-route optimization encountered issues: $result"
    puts "Trying without SI-aware optimization..."
    set_db opt_design_enable_si_aware false
    if {[catch {opt_design -post_route} result2]} {
        puts "Error: Post-route optimization failed: $result2"
        puts "Continuing without post-route optimization..."
    } else {
        puts "Post-route optimization completed (without SI-aware)"
    }
} else {
    puts "Post-route optimization completed successfully"
}

#17. Generate reports
puts "\n=========================================="
puts "Generating Reports"
puts "=========================================="

# Ensure report directory exists
exec mkdir -p ${RPT_DIR}/flat

# Timing reports
report_timing -max_paths 10 > ${RPT_DIR}/flat/${TOP_NAME}_timing_setup.rpt
report_timing -max_paths 10 -delay_type min > ${RPT_DIR}/flat/${TOP_NAME}_timing_hold.rpt

# Area report
report_area > ${RPT_DIR}/flat/${TOP_NAME}_area.rpt

# Power report
report_power > ${RPT_DIR}/flat/${TOP_NAME}_power.rpt

# DRC report
report_drc > ${RPT_DIR}/flat/${TOP_NAME}_drc.rpt

# Congestion report
report_congestion > ${RPT_DIR}/flat/${TOP_NAME}_congestion.rpt

#18. Save design
puts "\n=========================================="
puts "Saving Design"
puts "=========================================="

# Ensure output directory exists
exec mkdir -p ${OUTPUT_DIR}/flat

# Save design database (with error handling)
if {[catch {write_db ${OUTPUT_DIR}/flat/${TOP_NAME}} result]} {
    puts "Warning: Error writing database: $result"
    puts "Trying alternative path..."
    write_db "${OUTPUT_DIR}/flat/${TOP_NAME}.enc.dat"
} else {
    puts "Database written successfully"
}

# Export design files (with error handling)
if {[catch {write_verilog -no_physical_only_cells ${OUTPUT_DIR}/flat/${TOP_NAME}.v} result]} {
    puts "Warning: Error writing Verilog netlist: $result"
} else {
    puts "Verilog netlist written successfully"
}

if {[catch {write_def -routing ${OUTPUT_DIR}/flat/${TOP_NAME}.def} result]} {
    puts "Warning: Error writing DEF file: $result"
} else {
    puts "DEF file written successfully"
}

if {[catch {write_sdf ${OUTPUT_DIR}/flat/${TOP_NAME}.sdf} result]} {
    puts "Warning: Error writing SDF file: $result"
} else {
    puts "SDF file written successfully"
}

if {[catch {write_sdc ${OUTPUT_DIR}/flat/${TOP_NAME}.sdc} result]} {
    puts "Warning: Error writing SDC file: $result"
} else {
    puts "SDC file written successfully"
}

puts "\n=========================================="
puts "Flat Physical Synthesis Complete!"
puts "Reports: ${RPT_DIR}/flat/"
puts "Outputs: ${OUTPUT_DIR}/flat/"
puts "=========================================="

