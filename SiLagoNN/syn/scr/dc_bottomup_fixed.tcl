################################################################################
# Design Compiler bottom-up logic synthesis script
################################################################################
#
# This script is meant to be executed from the exe directory with:
# $ dc_shell -f ../syn/scr/dc_bottomup_fixed.tcl
################################################################################

#1. source setup file to extract global libraries
# Note: Path depends on execution directory. If from exe/, use ../syn/synopsys_dc.setup
# If from project root, use syn/synopsys_dc.setup
# Check which path works for your setup
if {[file exists ../syn/synopsys_dc.setup]} {
    source ../syn/synopsys_dc.setup
} elseif {[file exists ../../synopsys_dc.setup]} {
    source ../../synopsys_dc.setup
} elseif {[file exists syn/synopsys_dc.setup]} {
    source syn/synopsys_dc.setup
} else {
    puts "Error: Cannot find synopsys_dc.setup file"
    puts "Searched in: ../syn/synopsys_dc.setup, ../../synopsys_dc.setup, syn/synopsys_dc.setup"
    exit 1
}

# Debug: Print library settings to verify they're correct
puts "\n=========================================="
puts "Library Configuration:"
puts "=========================================="
if {[info exists target_library]} {
    puts "target_library: $target_library"
} else {
    puts "Warning: target_library not set"
}
if {[info exists link_library]} {
    puts "link_library: $link_library"
} else {
    puts "Warning: link_library not set"
}
if {[info exists search_path]} {
    puts "search_path: $search_path"
} else {
    puts "Warning: search_path not set"
}
puts "==========================================\n"

# Explicitly set link_library to avoid conflicts with system defaults
# This ensures we use the correct libraries from the setup file
if {[info exists target_library] && [info exists synthetic_library]} {
    set link_library "* ${target_library} ${synthetic_library}"
    puts "Explicitly set link_library: $link_library"
} elseif {[info exists target_library]} {
    set link_library "* ${target_library} standard.sldb dw_foundation.sldb"
    puts "Explicitly set link_library (with default synthetic): $link_library"
}

# Verify that library files exist in search_path
if {[info exists target_library] && [info exists search_path]} {
    set lib_found 0
    foreach path $search_path {
        set lib_path "${path}/${target_library}"
        if {[file exists ${lib_path}]} {
            puts "Found target library: ${lib_path}"
            set lib_found 1
            break
        }
    }
    if {!${lib_found}} {
        puts "Warning: Target library ${target_library} not found in search_path"
        puts "Please check your synopsys_dc.setup file"
    }
}

#2. set the TOP_NAME of the design
set TOP_NAME drra_wrapper

# Directories for output material
set REPORT_DIR  ../syn/rpt/task3      ; # synthesis reports: timing, area, etc.
set OUT_DIR ../syn/db/task3           ; # output files: netlist, sdf sdc etc.
set SOURCE_DIR ../rtl                 ; # rtl code that should be synthesised
set SYN_DIR ../syn                    ; # synthesis directory, synthesis scripts constraints etc.

# Ensure output directories exist
exec mkdir -p ${REPORT_DIR}
exec mkdir -p ${OUT_DIR}

#define the process
proc nth_pass {n} {
    #3. import the global variables for the process
    global SOURCE_DIR SYN_DIR OUT_DIR TOP_NAME REPORT_DIR

    set prev_n [expr {$n - 1}]
    exec rm -rf ${OUT_DIR}/pass${n}
    exec mkdir -p ${OUT_DIR}/pass${n}
    remove_design -all
    
    #4. Analyze the files in ${SOURCE_DIR}/pkg_hierarchy.txt. These files only contain variable definitions so you don't need to elaborate them
    set hierarchy_files [split [read [open ${SOURCE_DIR}/pkg_hierarchy.txt r]] "\n"]
    foreach filename [lrange ${hierarchy_files} 0 end-1] {
        set trimmed_filename [string trim $filename]
        if {$trimmed_filename != ""} {
            analyze -format vhdl -lib WORK "${SOURCE_DIR}/${trimmed_filename}"
        }
    }
    
    #Next we will compile divider_pipe first, ${SOURCE_DIR}/mtrf/DPU/divider_pipe.vhd. As the divider is a big structure We would like to import constraints in the next pass over divider pipe
    #5. analyze divider_pipe
    analyze -format vhdl -lib WORK "${SOURCE_DIR}/mtrf/DPU/divider_pipe.vhd"
    #6. elaborate divider_pipe
    elaborate divider_pipe
    #7. set the current design to divider_pipe
    current_design divider_pipe
    #8. link
    link
    #9. uniquify
    uniquify
    
    # Set wireload model and operating condition (CRITICAL - was missing!)
    set_wire_load_mode segmented
    set_wire_load_model -name TSMC8K_Lowk_Aggresive
    set_operating_condition NCCOM
    
    #10 source the top constraints file
    source ${SYN_DIR}/constraints.sdc
    
    # Set load and min_capacitance (CRITICAL - was missing!)
    if {[llength [all_outputs]] > 0} {
        set_load 0.13 [all_outputs]
    }
    set_min_capacitance 0.0 [get_nets *]
    
    if  {$n > 1} {
        #11. source constraints of divider pipe from previous pass
        source ${OUT_DIR}/pass${prev_n}/divider_pipe.wscr
    }
    #12. compile
    compile
    
    # Re-apply constraints after compile
    if {[llength [all_outputs]] > 0} {
        set_load 0.13 [all_outputs]
    }
    set_min_capacitance 0.0 [get_nets *]

    # We will compile the "silego" entity, which is identical for all the tiles. We will also import its constraints for the next pass.
    #13. analyze silego, use silego_hierarchy.
    set hierarchy_files [split [read [open ${SOURCE_DIR}/silego_hierarchy.txt r]] "\n"]
    foreach filename [lrange ${hierarchy_files} 0 end-1] {
        set trimmed_filename [string trim $filename]
        if {$trimmed_filename != ""} {
            analyze -format vhdl -lib WORK "${SOURCE_DIR}/${trimmed_filename}"
        }
    }
    #14. elaborate silego
    elaborate silego
    #15. set the current design to silego
    current_design silego
    #16. link
    link
    #17. uniquify
    uniquify
    
    # Set wireload model and operating condition (CRITICAL - was missing!)
    set_wire_load_mode segmented
    set_wire_load_model -name TSMC8K_Lowk_Aggresive
    set_operating_condition NCCOM
    
    #18. source the top constraints file
    source ${SYN_DIR}/constraints.sdc
    
    # Set load and min_capacitance (CRITICAL - was missing!)
    if {[llength [all_outputs]] > 0} {
        set_load 0.13 [all_outputs]
    }
    set_min_capacitance 0.0 [get_nets *]
    
    if {$n > 1} {
        #19. source the silego constraints file from the previous pass
        source ${OUT_DIR}/pass${prev_n}/silego.wscr
    }
    #20. set dont touch attribute for divider_pipe
    dont_touch divider_pipe true
    #21. compile
    compile
    
    # Re-apply constraints after compile
    if {[llength [all_outputs]] > 0} {
        set_load 0.13 [all_outputs]
    }
    set_min_capacitance 0.0 [get_nets *]

    #22. analyze Silago_top
    analyze -format vhdl -lib WORK "${SOURCE_DIR}/mtrf/Silago_top.vhd"
    #23. elaborate Silago_top
    elaborate Silago_top
    #24. set current design to Silago_top
    current_design Silago_top
    #25. link
    link
    #26. uniquify
    uniquify
    
    # Set wireload model and operating condition (CRITICAL - was missing!)
    set_wire_load_mode segmented
    set_wire_load_model -name TSMC8K_Lowk_Aggresive
    set_operating_condition NCCOM
    
    #27. source the top constraints
    source ${SYN_DIR}/constraints.sdc
    
    # Set load and min_capacitance (CRITICAL - was missing!)
    if {[llength [all_outputs]] > 0} {
        set_load 0.13 [all_outputs]
    }
    set_min_capacitance 0.0 [get_nets *]
    
    #28. set dont touch for silego and divider pipe
    dont_touch silego true
    dont_touch divider_pipe true
    #29. compile
    compile
    
    # Re-apply constraints after compile
    if {[llength [all_outputs]] > 0} {
        set_load 0.13 [all_outputs]
    }
    set_min_capacitance 0.0 [get_nets *]

    # Repeat for the remaining unique tile designs: Silago_bot, Silago_top_left_corner, Silago_top_right_corner, Silago_bot_left_corner, Silago_bot_right_corner
    foreach tile {Silago_bot Silago_top_left_corner Silago_top_right_corner Silago_bot_left_corner Silago_bot_right_corner} {
        #30. analyze $tile
        analyze -format vhdl -lib WORK "${SOURCE_DIR}/mtrf/${tile}.vhd"
        #31. elaborate $tile
        elaborate $tile
        #32. set current design to $tile
        current_design $tile
        #33. link
        link
        #34. uniquify
        uniquify
        
        # Set wireload model and operating condition (CRITICAL - was missing!)
        set_wire_load_mode segmented
        set_wire_load_model -name TSMC8K_Lowk_Aggresive
        set_operating_condition NCCOM
        
        #35. source the top constraints
        source ${SYN_DIR}/constraints.sdc
        
        # Set load and min_capacitance (CRITICAL - was missing!)
        if {[llength [all_outputs]] > 0} {
            set_load 0.13 [all_outputs]
        }
        set_min_capacitance 0.0 [get_nets *]
        
        #36. set dont touch for silego and divider pipe
        dont_touch silego true
        dont_touch divider_pipe true
        #37. compile
        compile
        
        # Re-apply constraints after compile
        if {[llength [all_outputs]] > 0} {
            set_load 0.13 [all_outputs]
        }
        set_min_capacitance 0.0 [get_nets *]
    }
    
    #38. analyze drra_wrapper
    analyze -format vhdl -lib WORK "${SOURCE_DIR}/mtrf/drra_wrapper.vhd"
    #39. elaborate drra_wrapper
    elaborate drra_wrapper
    #40. set current design to drra_wrapper
    current_design drra_wrapper

    link
    
    # CRITICAL: Add uniquify for drra_wrapper (was missing!)
    uniquify

    # Set wireload model and operating condition (CRITICAL - was missing!)
    set_wire_load_mode segmented
    set_wire_load_model -name TSMC8K_Lowk_Aggresive
    set_operating_condition NCCOM

    #41. set dont touch for divider pipe and ALL tiles (including Silago_top!)
    dont_touch divider_pipe true
    dont_touch silego true
    dont_touch Silago_top true
    foreach tile {Silago_bot Silago_top_left_corner Silago_top_right_corner Silago_bot_left_corner Silago_bot_right_corner} {
        dont_touch $tile true
    }
    
    #42. source constraints
    source ${SYN_DIR}/constraints.sdc
    
    # Set load and min_capacitance (CRITICAL - was missing!)
    set_load 0.13 [all_outputs]
    set_min_capacitance 0.0 [get_nets *]
    
    #43. report timing of drra wrapper in the current pass
    report_timing
    
    # CRITICAL: According to instructions, if top-level has additional logic (not just mapping),
    # we need to compile it. drra_wrapper likely has additional logic, so compile it.
    compile
    
    # Re-apply constraints after compile
    set_load 0.13 [all_outputs]
    set_min_capacitance 0.0 [get_nets *]
    
    #44. write_ddc from the current pass
    write_file -format ddc -output ${OUT_DIR}/pass${n}/drra_wrapper.ddc

    #45. characterize constraints of silego and divider_pipe
    # Note: You may need to adjust instance names based on actual hierarchy
    # Get actual instance names first
    set silego_instances [get_cells -hier -filter "ref_name == silego"]
    set divider_instances [get_cells -hier -filter "ref_name == divider_pipe"]
    
    set instance_list {}
    if {[sizeof_collection ${silego_instances}] > 0} {
        set first_silego [lindex [get_object_name ${silego_instances}] 0]
        lappend instance_list ${first_silego}
    }
    if {[sizeof_collection ${divider_instances}] > 0} {
        set first_divider [lindex [get_object_name ${divider_instances}] 0]
        lappend instance_list ${first_divider}
    }
    
    if {[llength ${instance_list}] > 0} {
        characterize -constraint ${instance_list}
    } else {
        puts "Warning: Could not find instances to characterize"
        # Fallback to hardcoded names if automatic detection fails
        characterize -constraint {Silago_top_inst_1_0/SILEGO_cell \
            Silago_top_inst_1_0/SILEGO_cell/MTRF_cell/dpu_gen/U_NACU_0/U_divider}
    }

    current_design silego
    write_script > ${OUT_DIR}/pass${n}/silego.wscr
    current_design divider_pipe
    write_script > ${OUT_DIR}/pass${n}/divider_pipe.wscr
}

#EXECUTE N PASSES OF THE ABOVE FUNCTION. DECIDE ON A REASONABLE N.
for {set i 1} {$i <= 2} {incr i} {
    nth_pass $i
}

#46. Set current design to drra_wrapper 
current_design drra_wrapper

#47. Report the final timing, power, area.
report_area > ${REPORT_DIR}/${TOP_NAME}_area.txt
report_timing > ${REPORT_DIR}/${TOP_NAME}_timing.txt
report_power > ${REPORT_DIR}/${TOP_NAME}_power.txt
report_constraints > ${REPORT_DIR}/${TOP_NAME}_constraints.txt
report_cell > ${REPORT_DIR}/${TOP_NAME}_cell.txt

#48. Write the netlist, ddc, sdc and sdf.
write_file -hierarchy -format ddc -output ${OUT_DIR}/${TOP_NAME}.ddc
write_file -hierarchy -format verilog -output ${OUT_DIR}/${TOP_NAME}.v
write_sdc ${OUT_DIR}/${TOP_NAME}.sdc
write_sdf ${OUT_DIR}/${TOP_NAME}.sdf

puts "\n=========================================="
puts "Bottom-up synthesis complete!"
puts "Reports saved to: ${REPORT_DIR}/"
puts "Outputs saved to: ${OUT_DIR}/"
puts "=========================================="

