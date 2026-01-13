################################################################################
# MMMC Setup for GF22FDX Technology
# This file sets up multi-mode multi-corner timing for Innovus
# Matches the library used in logic synthesis (GF22FDX)
# Based on tutorial format with proper .lib.gz files and QRC corners
################################################################################

# Library sets for different corners
# Using .lib.gz files (compressed liberty files) which Innovus can read directly
create_library_set \
    -name LIBSET_BC \
    -timing [list $LIB_FILES_BC]

create_library_set \
    -name LIBSET_TC \
    -timing [list $LIB_FILES_TC]

create_library_set \
    -name LIBSET_WC \
    -timing [list $LIB_FILES_WC]

# RC corners with QRC technology files
create_rc_corner \
    -name rc_best \
    -pre_route_res 1 \
    -post_route_res 1 \
    -pre_route_cap 1 \
    -post_route_cap 1 \
    -post_route_cross_cap 1 \
    -post_route_clock_res 0 \
    -post_route_clock_cap 0 \
    -qrc_tech $QRC_FILE_BC

create_rc_corner \
    -name rc_typ \
    -pre_route_res 1 \
    -post_route_res 1 \
    -pre_route_cap 1 \
    -post_route_cap 1 \
    -post_route_cross_cap 1 \
    -post_route_clock_res 0 \
    -post_route_clock_cap 0 \
    -qrc_tech $QRC_FILE_TC

create_rc_corner \
    -name rc_worst \
    -pre_route_res 1 \
    -post_route_res 1 \
    -pre_route_cap 1 \
    -post_route_cap 1 \
    -post_route_cross_cap 1 \
    -post_route_clock_res 0 \
    -post_route_clock_cap 0 \
    -qrc_tech $QRC_FILE_WC

# Timing conditions with operating conditions
create_timing_condition \
    -name cond_best \
    -library_set LIBSET_BC \
    -opcond $OP_COD_BC \
    -opcond_library $OP_COD_LIB_BC

create_timing_condition \
    -name cond_typ \
    -library_set LIBSET_TC \
    -opcond $OP_COD_TC \
    -opcond_library $OP_COD_LIB_TC

create_timing_condition \
    -name cond_worst \
    -library_set LIBSET_WC \
    -opcond $OP_COD_WC \
    -opcond_library $OP_COD_LIB_WC

# Delay corners
create_delay_corner \
    -name WC_dc \
    -rc_corner rc_worst \
    -timing_condition {cond_worst}

create_delay_corner \
    -name TC_dc \
    -rc_corner rc_typ \
    -timing_condition {cond_typ}

create_delay_corner \
    -name BC_dc \
    -rc_corner rc_best \
    -timing_condition {cond_best}

# Constraint mode
# Check if SDC file exists, if not use alternative path
# Note: Paths are relative to execution directory (exe/)
set sdc_file_to_use $SDC_FILES
if {![file exists $SDC_FILES]} {
    puts "Warning: SDC file not found: $SDC_FILES"
    # Try alternative paths relative to exe/ directory
    set alt_paths [list "../syn/constraints.sdc" "../../syn/constraints.sdc"]
    set found 0
    foreach alt_sdc $alt_paths {
        if {[file exists $alt_sdc]} {
            set sdc_file_to_use $alt_sdc
            puts "Using alternative SDC file: $alt_sdc"
            set found 1
            break
        }
    }
    if {!$found} {
        puts "Error: No SDC file found. Please check your setup."
        puts "Searched for: $SDC_FILES"
        foreach alt_sdc $alt_paths {
            puts "Also searched for: $alt_sdc"
        }
        # Use the original path anyway (will fail but with clear error)
        set sdc_file_to_use $SDC_FILES
    }
}
create_constraint_mode -name functional -sdc_files [list $sdc_file_to_use]

# Analysis views
create_analysis_view -name AVF_RCWORST -constraint_mode functional -delay_corner WC_dc
create_analysis_view -name AVF_RCBEST  -constraint_mode functional -delay_corner BC_dc
create_analysis_view -name AVF_RCTYP   -constraint_mode functional -delay_corner TC_dc

# Set active analysis views
# Setup: Worst case (SS) with worst RC
# Hold: Best case (FF) with best RC, and Typical for additional checks
set_analysis_view -setup "AVF_RCWORST" -hold "AVF_RCBEST AVF_RCTYP"

puts "MMMC setup complete for GF22FDX technology"
puts "Setup view: AVF_RCWORST (SS corner, worst RC)"
puts "Hold views: AVF_RCBEST (FF corner, best RC), AVF_RCTYP (TT corner, typical RC)"
puts "Note: OCV mode will be enabled in post-route optimization step"
