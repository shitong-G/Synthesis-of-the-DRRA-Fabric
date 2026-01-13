# Physical Synthesis Scripts - Usage Guide

## Overview

This directory contains scripts for three physical synthesis tasks:
- **Task 4**: Flat Physical Synthesis (no partitioning)
- **Task 5**: Floorplanning
- **Task 6**: Hierarchical Physical Synthesis

## File Structure

### Core Scripts
- `global_variables.tcl` - Variables for flat synthesis
- `global_variables_hrchy.tcl` - Variables for hierarchical synthesis
- `design_variables.tcl` - Design-specific parameters
- `mmmc.tcl` - Multi-mode multi-corner timing setup
- `read_design.tcl` - Design reading (LEF, netlist, SDC)

### Task 4 - Flat Physical Synthesis
- `pnr_flat.tcl` - Complete flat P&R flow (no partitioning)
- `run_flat_pnr.sh` - Automation script

**Usage (Method 1 - Script):**
```bash
cd phy/scr
./run_flat_pnr.sh
```

**Usage (Method 2 - Direct):**
```bash
cd exe
innovus -stylus -batch -files ../phy/scr/pnr_flat.tcl
```

### Task 5 - Floorplanning
- `floorplan.tcl` - Creates floorplan and boundary constraints
- `powerplan.tcl` - Power/ground mesh creation
- `create_partitions.tcl` - Main script for creating partitions with floorplan

**Usage:**
```bash
cd exe
innovus -stylus -batch -files ../phy/scr/create_partitions.tcl
```

### Task 6 - Hierarchical Physical Synthesis
- `create_partitions.tcl` - Creates partitions (also used for Task 5)
- `pnr_partition.tcl` - P&R for individual partitions
- `pnr_partition.sh` - Automation script for running all partitions
- `pnr_top.tcl` - Top-level P&R with ILM flattening
- `assemble_design.tcl` - Assembles design from partitions

**Usage (Method 1 - Automation Script):**
```bash
cd phy/scr
./run_hierarchical_pnr.sh
```

**Usage (Method 2 - Manual Steps):**
```bash
# Step 1: Create partitions
cd exe
innovus -stylus -batch -files ../phy/scr/create_partitions.tcl

# Step 2: P&R each partition (can use automation script)
cd ../phy/db/part
# For each partition directory:
innovus -stylus -batch -files ../../../scr/pnr_partition.tcl

# Or use automation:
cd ../../exe
bash ../phy/scr/pnr_partition.sh

# Step 3: Top-level P&R
cd exe
innovus -stylus -batch -files ../phy/scr/pnr_top.tcl

# Step 4: Assemble design
innovus -stylus -batch -files ../phy/scr/assemble_design.tcl
```

## Important Notes

### 1. Library Configuration
- Logic synthesis uses **GF22FDX** library
- Physical synthesis scripts are now configured for **GF22FDX** by default
- Files updated:
  - `mmmc_gf22fdx.tcl` - MMMC setup for GF22FDX
  - `global_variables.tcl` - Updated LEF and MMMC paths
  - `global_variables_hrchy.tcl` - Updated LEF and MMMC paths
- If you need to use TSMC90, change `MMMC_FILE` to `mmmc.tcl` in the variable files

### 2. Source Directory
- `global_variables.tcl` points to `task2` (flat synthesis results)
- `global_variables_hrchy.tcl` points to `task3` (bottom-up synthesis results)
- Adjust `SRC_DIR` based on which synthesis results you want to use

### 3. Partition Instance Names
- `global_variables_hrchy.tcl` contains example partition instance names
- **You need to update `all_partition_hinst_list` with actual instance names from your design**

### 4. Master Partition Modules
- `master_partition_module_list` should contain unique module names
- Clones will reference these masters

## Output Directories

- **Flat synthesis**: `phy/db/flat/` and `phy/rpt/flat/`
- **Hierarchical synthesis**: `phy/db/part/` and `phy/rpt/`

## Troubleshooting

### Missing Files Error
If you get errors about missing files:
1. Check that all variable files exist
2. Verify paths are correct relative to execution directory
3. Ensure synthesis netlist files exist in `syn/db/task2/` or `syn/db/task3/`

### Library Errors
- Verify LEF file path is correct
- Check that library files in MMMC match your technology
- Ensure library files are readable

### Partition Errors
- Verify partition instance names match your design hierarchy
- Check that master partition modules are correctly identified
- Ensure floorplan dimensions are appropriate for your design

