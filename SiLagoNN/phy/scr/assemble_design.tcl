source ../phy/scr/global_variables_hrchy.tcl
source ../phy/scr/design_variables.tcl

#1. read the top place-and-routed top partition
read_db ../phy/db/part/${TOP_NAME}.enc.dat/pnr
#2. assemble the design from the constituent place and routed partitions
foreach part [glob ../phy/db/part/*.enc.dat/pnr] {
    if {[file normalize $part] == [file normalize "../phy/db/part/drra_wrapper.enc.dat/pnr"]} {
        continue
    }
    assemble_design -encounter_format -block_dir $part
}