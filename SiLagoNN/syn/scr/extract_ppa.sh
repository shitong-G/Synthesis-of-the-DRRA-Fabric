#!/bin/bash
################################################################################
# PPA Data Extraction Script
# 
# This script extracts PPA (Power, Performance, Area) data from synthesis reports
# and creates a comparison table.
#
# Usage: ./extract_ppa.sh [report_directory]
# Example: ./extract_ppa.sh syn/rpt
################################################################################

RPT_DIR=${1:-"syn/rpt"}
OUTPUT_FILE="${RPT_DIR}/ppa_comparison.txt"

echo "=========================================="
echo "PPA Data Extraction"
echo "=========================================="
echo "Report directory: $RPT_DIR"
echo "Output file: $OUTPUT_FILE"
echo ""

# Create header
cat > "$OUTPUT_FILE" << EOF
================================================================================
PPA Comparison Table
Generated: $(date)
================================================================================

Clock Period | Frequency | Slack (ns) | Total Area | Comb Area | Seq Area | Cells | Status
-------------|-----------|------------|------------|-----------|----------|-------|--------
EOF

# Find all timing and area reports
for timing_rpt in "$RPT_DIR"/drra_wrapper_timing_*.rpt; do
    if [ ! -f "$timing_rpt" ]; then
        continue
    fi
    
    # Extract clock period from filename
    period=$(basename "$timing_rpt" | sed 's/drra_wrapper_timing_\(.*\)\.rpt/\1/' | sed 's/ns//')
    
    # Calculate frequency (MHz)
    if [ -n "$period" ] && [ "$period" != "0" ]; then
        freq=$(echo "scale=2; 1000/$period" | bc 2>/dev/null || echo "N/A")
    else
        freq="N/A"
    fi
    
    # Extract slack from timing report
    slack_line=$(grep -i "slack" "$timing_rpt" | tail -1)
    if echo "$slack_line" | grep -qi "VIOLATED"; then
        slack=$(echo "$slack_line" | awk '{print $NF}' | head -1)
        status="VIOLATED"
    elif echo "$slack_line" | grep -qi "MET"; then
        slack=$(echo "$slack_line" | awk '{print $NF}' | head -1)
        status="MET"
    else
        slack="N/A"
        status="UNKNOWN"
    fi
    
    # Find corresponding area report
    area_rpt="${timing_rpt/timing_/area_}"
    
    if [ -f "$area_rpt" ]; then
        # Extract area data
        total_area=$(grep "Total cell area:" "$area_rpt" | awk '{print $4}')
        comb_area=$(grep "Combinational area:" "$area_rpt" | awk '{print $3}')
        seq_area=$(grep "Noncombinational area:" "$area_rpt" | awk '{print $3}')
        cells=$(grep "Number of cells:" "$area_rpt" | awk '{print $4}')
        
        # Format numbers (remove decimals if needed)
        total_area=$(printf "%.0f" "$total_area" 2>/dev/null || echo "$total_area")
        comb_area=$(printf "%.0f" "$comb_area" 2>/dev/null || echo "$comb_area")
        seq_area=$(printf "%.0f" "$seq_area" 2>/dev/null || echo "$seq_area")
    else
        total_area="N/A"
        comb_area="N/A"
        seq_area="N/A"
        cells="N/A"
    fi
    
    # Print formatted line
    printf "%-12s | %-9s | %-10s | %-10s | %-9s | %-8s | %-5s | %s\n" \
        "${period}ns" "$freq MHz" "$slack" "$total_area" "$comb_area" "$seq_area" "$cells" "$status" >> "$OUTPUT_FILE"
    
    echo "Extracted data for ${period}ns period"
done

echo ""
echo "=========================================="
echo "PPA comparison table saved to: $OUTPUT_FILE"
echo "=========================================="
echo ""
echo "Preview:"
cat "$OUTPUT_FILE"

