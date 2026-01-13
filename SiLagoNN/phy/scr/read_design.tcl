#1. Read MMMC file
read_mmmc ${MMMC_FILE}

#2. Read LEF file
read_physical -lef ${LEF_FILE}

#3. Read logic synthesis netlist
read_netlist ${NETLIST_FILE}

#4. Initialize design
init_design

#5. Read SDC constraints (if available)
if {[file exists ${SDC_FILES}]} {
    read_sdc ${SDC_FILES}
} else {
    puts "Warning: SDC file not found: ${SDC_FILES}"
}