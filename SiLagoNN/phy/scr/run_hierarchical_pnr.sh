#!/bin/bash
################################################################################
# Script to run Hierarchical Physical Synthesis (Task 5 & 6)
################################################################################
#
# Usage: ./run_hierarchical_pnr.sh
# Or: bash run_hierarchical_pnr.sh
#
# This script runs the complete hierarchical physical synthesis flow:
# 1. Create partitions with floorplan
# 2. Place and route each partition
# 3. Top-level place and route
# 4. Assemble design
################################################################################

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "${SCRIPT_DIR}/../.." && pwd )"

# Change to exe directory
cd "${PROJECT_ROOT}/exe" || {
    echo "Error: Cannot change to exe directory"
    exit 1
}

# Check if Innovus is available
if ! command -v innovus &> /dev/null; then
    echo "Error: innovus command not found. Please check your PATH."
    exit 1
fi

echo "=========================================="
echo "Running Hierarchical Physical Synthesis"
echo "=========================================="
echo "Project root: ${PROJECT_ROOT}"
echo "Working directory: $(pwd)"
echo ""

# Create log directory if it doesn't exist
mkdir -p ../log
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Step 1: Create partitions
echo "=========================================="
echo "Step 1: Creating partitions with floorplan"
echo "=========================================="
if [ ! -f "../phy/scr/create_partitions.tcl" ]; then
    echo "Error: create_partitions.tcl not found"
    exit 1
fi

innovus -stylus -batch -files ../phy/scr/create_partitions.tcl \
    -log "../log/create_partitions_${TIMESTAMP}"

if [ $? -ne 0 ]; then
    echo "Error: Failed to create partitions"
    exit 1
fi

echo "Partitions created successfully"
echo ""

# Step 2: Place and route partitions
echo "=========================================="
echo "Step 2: Place and route partitions"
echo "=========================================="
echo "This step can be automated using pnr_partition.sh"
echo "Or run manually for each partition"
echo ""

read -p "Do you want to run partition P&R automatically? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "../phy/scr/pnr_partition.sh" ]; then
        cd ../phy/db/part
        bash ../../../phy/scr/pnr_partition.sh
        cd ../../../../exe
    else
        echo "Warning: pnr_partition.sh not found. Please run partition P&R manually."
    fi
else
    echo "Skipping automatic partition P&R. Please run manually."
fi

echo ""

# Step 3: Top-level place and route
echo "=========================================="
echo "Step 3: Top-level place and route"
echo "=========================================="
if [ ! -f "../phy/scr/pnr_top.tcl" ]; then
    echo "Error: pnr_top.tcl not found"
    exit 1
fi

innovus -stylus -batch -files ../phy/scr/pnr_top.tcl \
    -log "../log/pnr_top_${TIMESTAMP}"

if [ $? -ne 0 ]; then
    echo "Error: Failed to run top-level P&R"
    exit 1
fi

echo "Top-level P&R completed successfully"
echo ""

# Step 4: Assemble design
echo "=========================================="
echo "Step 4: Assembling design"
echo "=========================================="
if [ ! -f "../phy/scr/assemble_design.tcl" ]; then
    echo "Error: assemble_design.tcl not found"
    exit 1
fi

innovus -stylus -batch -files ../phy/scr/assemble_design.tcl \
    -log "../log/assemble_design_${TIMESTAMP}"

if [ $? -ne 0 ]; then
    echo "Error: Failed to assemble design"
    exit 1
fi

echo ""
echo "=========================================="
echo "Hierarchical Physical Synthesis Complete!"
echo "=========================================="
echo "Reports: ../phy/rpt/"
echo "Outputs: ../phy/db/part/"
echo "Logs: ../log/*_${TIMESTAMP}.*"
echo ""

