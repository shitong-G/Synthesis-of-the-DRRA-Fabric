################################################################################
# Flat logic synthesis script
################################################################################
#
# This script is meant to be executed with the following directory structure
#
# project_top_folder
# |
# |- db: store output data like mapped designs or physical files like GDSII
# |
# |- phy: physical synthesis material (scripts, pins, etc)
# |
# |- rtl: contains rtl code for the design, it should also contain a
# |       hierarchy.txt file with the all the files that compose the design
# |
# |- syn: logic synthesis material (this script, SDC constraints, etc)
# |
# |- sim: simulation stuff like waveforms, reports, coverage etc.
# |
# |- tb: testbenches for the rtl code
# |
# |- exe: the directory where it should be executed. This keeps all the temp files
#         created by DC in that directory
#
#
# The standard way of executing the is from the project_top_folder
# with the following command
#
# $ dc_shell -f ../syn/dc_flat.tcl
################################################################################

#1. source setup file to extract global libraries
source ../../synopsys_dc.setup

#2. set the TOP_NAME of the design
set TOP_NAME drra_wrapper

# Directories for output material
set REPORT_DIR ../syn/rpt      ; # synthesis reports: timing, area, etc.
set OUT_DIR ../syn/db          ; # output files: netlist, sdf sdc etc.
set SOURCE_DIR ../rtl          ; # rtl code that should be synthesised
set SYN_DIR ../syn             ; # synthesis directory, synthesis scripts constraints etc.

#3. set hierarchy file to read the design
set hierarchy_files [split [read [open ${SOURCE_DIR}/${TOP_NAME}_hierarchy.txt r]] "\n"]

#4. analyze design
foreach filename [lrange ${hierarchy_files} 0 end-1] {
    set trimmed_filename [string trim $filename]
    if {$trimmed_filename != ""} {
        puts "${trimmed_filename}"
        analyze -format VHDL -lib WORK "${SOURCE_DIR}/${trimmed_filename}"
    }
}

#5. elaborate the design, link, and uniquify
elaborate ${TOP_NAME}

link

#6. set current_design
current_design ${TOP_NAME}

#7. set wireload model
set_wire_load_mode segmented
set_wire_load_model -name TSMC8K_Lowk_Aggresive
set_operating_condition NCCOM

#8. source sdc file
source ${SYN_DIR}/constraints.sdc

#8.1. set default load for all outputs to fix min_capacitance violations
# This is needed because DRRA wrapper has many unconnected outputs with 0 capacitance
# Note: set_min_capacitance cannot be set on output ports, only set_load works
set_load 0.13 [all_outputs]

#8.2. set min_capacitance to 0 for all nets before compile
# This fixes min_capacitance violations on internal nets with 0 capacitance
# (e.g., divisor_var, dividend_var nets that have no load)
set_min_capacitance 0.0 [get_nets *]

#9. compile
compile -map_effort medium

#9.1. re-apply load and min_capacitance after compile to ensure they're still applied
set_load 0.13 [all_outputs]
set_min_capacitance 0.0 [get_nets *]

#10. report area, timing, power, constraints, cell in the report directory with a suitable name
report_constraints > ${REPORT_DIR}/flat_rpt_6ns/${TOP_NAME}_constraints.txt
report_area > ${REPORT_DIR}/flat_rpt_6ns/${TOP_NAME}_area.txt
report_cell > ${REPORT_DIR}/flat_rpt_6ns/${TOP_NAME}_cells.txt
report_timing > ${REPORT_DIR}/flat_rpt_6ns/${TOP_NAME}_timing.txt
report_power > ${REPORT_DIR}/flat_rpt_6ns/${TOP_NAME}_power.txt

#11. export the netlist, ddc and sdf file in out direcory with a suitable name
write -hierarchy -format ddc -output ${OUT_DIR}/flat_6ns/${TOP_NAME}.ddc
write -hierarchy -format verilog -output ${OUT_DIR}/flat_6ns/${TOP_NAME}.v
