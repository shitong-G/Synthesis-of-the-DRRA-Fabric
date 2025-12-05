#!/bin/bash
################################################################################
# Quick synthesis script for DRRA_wrapper
# Usage: ./run_synthesis.sh [clock_period]
# Example: ./run_synthesis.sh 20.0
################################################################################

# Get clock period from argument or use default
CLOCK_PERIOD=${1:-20.0}

echo "=========================================="
echo "DRRA_wrapper Synthesis"
echo "Clock Period: ${CLOCK_PERIOD}ns"
echo "=========================================="

# Check if we're in the right directory
if [ ! -f "rtl/drra_wrapper_hierarchy.txt" ] && [ ! -f "../rtl/drra_wrapper_hierarchy.txt" ]; then
    echo "Error: Please run from project root directory"
    exit 1
fi

# Set clock period environment variable
export CLOCK_PERIOD=$CLOCK_PERIOD

# Run synthesis
if [ -f "syn/scr/dc_drra_wrapper.tcl" ]; then
    dc_shell -f syn/scr/dc_drra_wrapper.tcl
elif [ -f "../syn/scr/dc_drra_wrapper.tcl" ]; then
    dc_shell -f ../syn/scr/dc_drra_wrapper.tcl
else
    echo "Error: Synthesis script not found"
    exit 1
fi

echo "Synthesis complete!"

