#1. Source global variables for hierarchical synthesis
source ../phy/scr/global_variables_hrchy.tcl

#2. Source design variables
source ../phy/scr/design_variables.tcl

#3. Set multi-CPU usage (needed before reading design)
set_multi_cpu_usage -local_cpu ${NUM_CPUS} -cpu_per_remote_host 1 -remote_host 0 -keep_license true
set_distributed_hosts -local

#4. Set power and ground nets
set_db init_power_nets {VDD}
set_db init_ground_nets {VSS}

#5. Read design and create partitions
source ../phy/scr/read_design.tcl
source ../phy/scr/floorplan.tcl
source ../phy/scr/powerplan.tcl
source ../phy/scr/partition.tcl