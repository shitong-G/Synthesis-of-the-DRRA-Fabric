#!/bin/bash
################################################################################
# Script to run Hierarchical Physical Synthesis (Task 6)
################################################################################
#
# Usage: ./run_hierarchical_pnr.sh
# Or: bash run_hierarchical_pnr.sh
#
# This script runs the complete hierarchical P&R flow:
#   Step 1: Create partitions (Task 5)
#   Step 2: P&R each partition (can run in parallel)
#   Step 3: Top-level P&R
#   Step 4: Assemble design
################################################################################

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "${SCRIPT_DIR}/../.." && pwd )"

# Set variables
export TOP_NAME="drra_wrapper"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
export TIMESTAMP

# Change to exe directory (where Innovus should be run from)
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
echo "Running Hierarchical Physical Synthesis (Task 6)"
echo "=========================================="
echo "Project root: ${PROJECT_ROOT}"
echo "Working directory: $(pwd)"
echo "Timestamp: ${TIMESTAMP}"
echo ""

# Create log directory if it doesn't exist
mkdir -p ../log

# Step 1: Create partitions (Task 5)
echo "=========================================="
echo "Step 1: Creating partitions (Task 5)"
echo "=========================================="
echo "Log files will be saved to: ../log/create_partitions_${TIMESTAMP}.*"
echo ""

innovus -stylus -batch -files ../phy/scr/create_partitions.tcl \
    -log "../log/create_partitions_${TIMESTAMP}"

EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: Step 1 (Create partitions) failed"
    exit $EXIT_CODE
fi

echo "Step 1 completed successfully"
echo ""

# Step 2: P&R each partition
echo "=========================================="
echo "Step 2: P&R each partition"
echo "=========================================="
echo "Running pnr_partition.sh..."
echo ""

# pnr_partition.sh expects to be run from project root or exe directory
# It uses relative paths: ../phy/db/part
# Note: pnr_partition.sh may change directory, so we ensure we're back in exe after it
bash "${PROJECT_ROOT}/phy/scr/pnr_partition.sh"

EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: Step 2 (Partition P&R) failed"
    exit $EXIT_CODE
fi

# Ensure we're back in exe directory (pnr_partition.sh may have changed it)
cd "${PROJECT_ROOT}/exe" || {
    echo "Error: Cannot return to exe directory after Step 2"
    exit 1
}

echo "Step 2 completed successfully"
echo ""

# Step 3: Top-level P&R
echo "=========================================="
echo "Step 3: Top-level P&R"
echo "=========================================="
echo "Log files will be saved to: ../log/pnr_top_${TIMESTAMP}.*"
echo ""

innovus -stylus -batch -files ../phy/scr/pnr_top.tcl \
    -log "../log/pnr_top_${TIMESTAMP}"

EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: Step 3 (Top-level P&R) failed"
    exit $EXIT_CODE
fi

echo "Step 3 completed successfully"
echo ""

# Step 4: Assemble design
echo "=========================================="
echo "Step 4: Assemble design"
echo "=========================================="
echo "Log files will be saved to: ../log/assemble_design_${TIMESTAMP}.*"
echo ""

innovus -stylus -batch -files ../phy/scr/assemble_design.tcl \
    -log "../log/assemble_design_${TIMESTAMP}"

EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: Step 4 (Assemble design) failed"
    exit $EXIT_CODE
fi

echo "Step 4 completed successfully"
echo ""

# Final summary
echo "=========================================="
echo "Hierarchical Physical Synthesis Complete!"
echo "=========================================="
echo "Reports: ../phy/rpt/"
echo "Outputs: ../phy/db/part/"
echo "Logs: ../log/"
echo ""