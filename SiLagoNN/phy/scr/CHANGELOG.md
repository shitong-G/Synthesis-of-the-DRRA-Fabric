# Physical Synthesis Scripts - Changelog

## Recent Updates

### 2025-01-XX - Library Configuration Updates

#### Added Files
- `mmmc_gf22fdx.tcl` - MMMC setup for GF22FDX technology (matches logic synthesis)
- `global_variables_hrchy.tcl` - Variables for hierarchical synthesis
- `design_variables.tcl` - Design-specific parameters
- `powerplan.tcl` - Power planning script
- `pnr_flat.tcl` - Flat physical synthesis script (Task 4)
- `run_flat_pnr.sh` - Automation script for flat P&R
- `run_hierarchical_pnr.sh` - Automation script for hierarchical P&R
- `README.md` - Complete usage guide
- `ANALYSIS_REPORT.md` - Problem analysis report

#### Modified Files
- `global_variables.tcl` - Updated to use GF22FDX LEF and MMMC files
- `global_variables_hrchy.tcl` - Updated to use GF22FDX LEF and MMMC files
- `read_design.tcl` - Cleaned up and fixed initialization
- `create_partitions.tcl` - Added necessary initialization steps

#### Key Changes
1. **Library Configuration**
   - Changed from TSMC90 to GF22FDX to match logic synthesis
   - Updated LEF file path: `/opt/pdk/gfip/22FDX-EXT/.../GF22FDX_SC8T_104CPP_BASE_CSC28L.lef`
   - Created `mmmc_gf22fdx.tcl` with proper corner setup:
     - TT (Typical) corner for typical analysis
     - FF (Fast) corner for hold time analysis
     - SS (Slow) corner for setup time analysis

2. **Missing Files Fixed**
   - All referenced files now exist
   - Proper variable initialization
   - Correct file paths and dependencies

3. **Task 4 Implementation**
   - Complete flat physical synthesis flow
   - No partitioning, single flat design
   - Proper power planning and routing

4. **Automation Scripts**
   - Easy-to-use shell scripts for running synthesis
   - Proper error handling and logging
   - Timestamped log files

## Configuration Notes

### Technology Library
- **Current**: GF22FDX (matches logic synthesis)
- **Alternative**: TSMC90 (if needed, change `MMMC_FILE` in variable files)

### Source Directory
- Flat synthesis: `syn/db/task2` (flat synthesis results)
- Hierarchical synthesis: `syn/db/task3` (bottom-up synthesis results)

### Partition Configuration
- Update `all_partition_hinst_list` in `global_variables_hrchy.tcl` with actual instance names
- Update `master_partition_module_list` with unique module names

## Known Issues

1. **Innovus .db File Support**
   - GF22FDX libraries are in .db format (CCS)
   - Some Innovus versions may require .lib files
   - If issues occur, check Innovus version compatibility

2. **Partition Instance Names**
   - Example names provided in `global_variables_hrchy.tcl`
   - Must be updated based on actual design hierarchy

3. **Floorplan Dimensions**
   - Current values are placeholders
   - Adjust based on actual design size and utilization

## Future Improvements

1. Automatic partition instance name detection
2. Dynamic floorplan size calculation
3. Better error handling and validation
4. Support for multiple technology libraries

