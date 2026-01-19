#!/bin/bash
################################################################################
# Script to run only Task 5 (Create Partitions)
################################################################################
# This script only creates floorplan and partitions, without P&R

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "${SCRIPT_DIR}/../.." && pwd )"

export TOP_NAME="drra_wrapper"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
export TIMESTAMP

cd "${PROJECT_ROOT}/exe" || {
    echo "Error: Cannot change to exe directory"
    exit 1
}

if ! command -v innovus &> /dev/null; then
    echo "Error: innovus command not found. Please check your PATH."
    exit 1
fi

echo "=========================================="
echo "Running Task 5: Create Partitions"
echo "=========================================="
echo "Project root: ${PROJECT_ROOT}"
echo "Working directory: $(pwd)"
echo "Timestamp: ${TIMESTAMP}"
echo ""

mkdir -p ../log

echo "Creating partitions (floorplan + powerplan + partition)..."
innovus -stylus -batch -files ../phy/scr/create_partitions.tcl \
    -log "../log/create_partitions_${TIMESTAMP}"

EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: Task 5 (Create partitions) failed"
    exit $EXIT_CODE
fi

echo ""
echo "=========================================="
echo "Task 5 Complete!"
echo "=========================================="
echo "Partitions saved to: ../phy/db/part/"
echo "Logs: ../log/create_partitions_${TIMESTAMP}.*"
echo ""

