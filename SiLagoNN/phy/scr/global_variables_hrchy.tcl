set NUM_CPUS 8
#set the top name of the design
set TOP_NAME drra_wrapper

# Directories
set OUTPUT_DIR "../phy/db"
set RPT_DIR    "../phy/rpt"
set SCR_DIR    "../phy/scr"
#we need a part directory where partitions are created
set PART_DIR   "../phy/db/part"
# For hierarchical synthesis, use task3 (bottom-up) results
# For flat synthesis, use task2 (flat) results
# Adjust this based on which synthesis results you want to use
set SRC_DIR    "../syn/db/flat_db_10ns"

# Library directories for GF22FDX
set STDC_CCS_DIR "/opt/pdk/gfip/22FDX-EXT/GF22FDX_SC8T_104CPP_BASE_CSC28L_FDK_RELV06R60/model/timing/ccs"
set TECH_LEF_DIR  "/opt/pdk/gf22/V1.0_4.1/PlaceRoute/Innovus/Techfiles/10M_2Mx_4Cx_2Bx_2Jx_LB"
set STDC_LEF_DIR  "/opt/pdk/gfip/22FDX-EXT/GF22FDX_SC8T_104CPP_BASE_CSC28L_FDK_RELV06R60/lef"
set STDC_QRC_DIR  "/opt/pdk/gf22/V1.0_4.1/PEX/QRC/10M_2Mx_4Cx_2Bx_2Jx_LBthick"

# Operating condition library names
set OP_COD_LIB_BC "GF22FDX_SC8T_104CPP_BASE_CSC28L_FFG_0P72V_0P00V_0P00V_0P00V_M40C"
set OP_COD_LIB_TC "GF22FDX_SC8T_104CPP_BASE_CSC28L_TT_0P80V_0P00V_0P00V_0P00V_25C"
set OP_COD_LIB_WC "GF22FDX_SC8T_104CPP_BASE_CSC28L_SSG_0P72V_0P00V_0P00V_0P00V_125C"

# Library files (.lib.gz format for Innovus)
set LIB_FILES_BC "${STDC_CCS_DIR}/${OP_COD_LIB_BC}_ccs.lib.gz"
set LIB_FILES_TC "${STDC_CCS_DIR}/${OP_COD_LIB_TC}_ccs.lib.gz"
set LIB_FILES_WC "${STDC_CCS_DIR}/${OP_COD_LIB_WC}_ccs.lib.gz"

# Operating conditions
set OP_COD_BC "FFG_0P72V_0P00V_0P00V_0P00V_M40C"
set OP_COD_TC "TT_0P80V_0P00V_0P00V_0P00V_25C"
set OP_COD_WC "SSG_0P72V_0P00V_0P00V_0P00V_125C"

# QRC technology files
set QRC_FILE_BC "${STDC_QRC_DIR}/FuncRCminDP/qrcTechFile"
set QRC_FILE_TC "${STDC_QRC_DIR}/nominal/qrcTechFile"
set QRC_FILE_WC "${STDC_QRC_DIR}/FuncRCmaxDP/qrcTechFile"

# LEF files - Tech LEF and Std Cell LEF
set LEF_FILE "${TECH_LEF_DIR}/22FDSOI_10M_2Mx_4Cx_2Bx_2Jx_LB_104cpp_tech.lef \
        ${STDC_LEF_DIR}/GF22FDX_SC8T_104CPP_BASE_CSC28L.lef"

# MMMC file
set MMMC_FILE         "${SCR_DIR}/mmmc_gf22fdx.tcl"
set NETLIST_FILE      "${SRC_DIR}/${TOP_NAME}.v"
set SDC_FILES         "${SRC_DIR}/${TOP_NAME}.sdc"

# Partition-related variables
# List of all partition hierarchical instances
# These should match the actual hierarchy in your design
# Example: if you have Silago_top_inst_1_0, Silago_bot_inst_1_1, etc.
# You need to populate this list based on your actual design hierarchy
set all_partition_hinst_list {
    # Top row (8 instances)
    Silago_top_left_corner_inst_0_0
    Silago_top_inst_1_0
    Silago_top_inst_2_0
    Silago_top_inst_3_0
    Silago_top_inst_4_0
    Silago_top_inst_5_0
    Silago_top_inst_6_0
    Silago_top_right_corner_inst_7_0
    # Bottom row (8 instances)
    Silago_bot_left_corner_inst_0_1
    Silago_bot_inst_1_1
    Silago_bot_inst_2_1
    Silago_bot_inst_3_1
    Silago_bot_inst_4_1
    Silago_bot_inst_5_1
    Silago_bot_inst_6_1
    Silago_bot_right_corner_inst_7_1
}

# Master partition modules - unique modules that will be compiled once
# Clones will reference these masters
set master_partition_module_list {
    Silago_top_left_corner
    Silago_top
    Silago_top_right_corner
    Silago_bot_left_corner
    Silago_bot
    Silago_bot_right_corner
}

