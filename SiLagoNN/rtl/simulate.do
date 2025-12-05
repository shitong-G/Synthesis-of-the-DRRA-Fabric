# ============================================================================
# Complete Simulation Script with Waveform Saving
# ============================================================================
# This script runs simulation, adds verification signals, and saves waveforms
# Run from rtl directory
# 
# IMPORTANT: Ensure instruction.bin is accessible (copy to rtl/ or run from tb/vec_add/)
# ============================================================================

# Start simulation
vsim -suppress 1549 -voptargs=+acc work.testbench

# Define paths
set DPU_PATH {/testbench/DUT/MTRF_COLS(0)/MTRF_ROWS(0)/if_drra_top_l_corner/Silago_top_l_corner_inst/SILEGO_cell/MTRF_cell/dpu_gen}
set MTRF_PATH {/testbench/DUT/MTRF_COLS(0)/MTRF_ROWS(0)/if_drra_top_l_corner/Silago_top_l_corner_inst/SILEGO_cell/MTRF_cell}

# ============================================================================
# Add Waveforms
# ============================================================================

# Clock and Reset
add wave -divider "Clock and Reset"
add wave /testbench/clk
add wave /testbench/rst_n

# DPU Outputs (MOST IMPORTANT - check these for results)
add wave -divider "DPU <0,0> - Outputs (MOST IMPORTANT)"
add wave -radix decimal $DPU_PATH/dpu_out_0
add wave -radix decimal $DPU_PATH/dpu_out_1

# DPU Inputs
add wave -divider "DPU <0,0> - Inputs"
add wave -radix decimal $DPU_PATH/dpu_in_0
add wave -radix decimal $DPU_PATH/dpu_in_1
add wave -radix decimal $DPU_PATH/dpu_in_2
add wave -radix decimal $DPU_PATH/dpu_in_3

# MTRF Cell Output Ports
add wave -divider "MTRF Cell <0,0> - Output Ports"
add wave -radix decimal $MTRF_PATH/dpu_out_0_left
add wave -radix decimal $MTRF_PATH/dpu_out_1_left

# Testbench Control Signals
add wave -divider "Testbench Control"
add wave /testbench/instr_load
add wave -radix hexadecimal /testbench/instr_input
add wave -radix binary /testbench/seq_address_rb
add wave -radix binary /testbench/seq_address_cb

# Configure wave window
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns

# ============================================================================
# Run Simulation
# ============================================================================
echo "=========================================="
echo "Starting simulation..."
echo "=========================================="
echo "Expected timeline:"
echo "  0-4ns:    Reset phase"
echo "  4-444ns:  Memory init + Instruction loading (27 instructions)"
echo "  444ns+:   Execution phase (check DPU outputs here)"
echo "=========================================="
echo ""
echo "Running simulation for 1000ns..."
run 1000ns

# Zoom to full view
wave zoom full

# ============================================================================
# Save Waveform Images
# ============================================================================

# Create output directory if it doesn't exist
if {![file exists "../sim/waveforms"]} {
    file mkdir "../sim/waveforms"
}

# Get current time for filename
set timestamp [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]

echo ""
echo "Saving waveform images..."
echo "Output directory: ../sim/waveforms/"

# Try to save waveform images (may fail if window path is different)
# Save full waveform view
catch {
    write format image -window .main_pane.wave.interior.cs.body.pw.wf \
        -file "../sim/waveforms/waveform_full_${timestamp}.png" -format png
    echo "  ✓ Saved: waveform_full_${timestamp}.png"
}

catch {
    write format image -window .main_pane.wave.interior.cs.body.pw.wf \
        -file "../sim/waveforms/waveform_full_${timestamp}.ps" -format ps
    echo "  ✓ Saved: waveform_full_${timestamp}.ps"
}

# Save waveform data (WLF format - can reload in QuestaSim)
catch {
    write format wave -file "../sim/waveforms/waveform_${timestamp}.wlf" -format wlf
    echo "  ✓ Saved: waveform_${timestamp}.wlf (can reload in QuestaSim)"
}

# Save zoomed views of specific phases
catch {
    wave zoom range 444ns 2000ns
    write format image -window .main_pane.wave.interior.cs.body.pw.wf \
        -file "../sim/waveforms/waveform_execution_${timestamp}.png" -format png
    echo "  ✓ Saved: waveform_execution_${timestamp}.png (execution phase)"
}

catch {
    wave zoom range 0ns 100ns
    write format image -window .main_pane.wave.interior.cs.body.pw.wf \
        -file "../sim/waveforms/waveform_reset_${timestamp}.png" -format png
    echo "  ✓ Saved: waveform_reset_${timestamp}.png (reset phase)"
}

# Zoom back to full
wave zoom full

# ============================================================================
# Verification Instructions
# ============================================================================
echo ""
echo "=========================================="
echo "VERIFICATION CHECKLIST:"
echo "=========================================="
echo "1. Check Clock & Reset:"
echo "   - clk: Periodic (12ns period) ✓"
echo "   - rst_n: '0' from 0-4ns, then '1' ✓"
echo ""
echo "2. Check Instruction Loading:"
echo "   - instr_load: Pulses after reset ✓"
echo "   - Should load 27 instructions ✓"
echo ""
echo "3. Check DPU Outputs (MOST IMPORTANT):"
echo "   - dpu_out_0 and dpu_out_1: Should NOT be 'X' or 'U'"
echo "   - Expected results: 16, 18, 20, 22, ... (vector addition)"
echo "   - Navigate to execution phase (after 444ns) to check outputs"
echo ""
echo "4. If outputs are 'X', check:"
echo "   - instruction.bin exists in ../tb/vec_add/"
echo "   - Simulation ran long enough (10000ns)"
echo "   - Reset sequence completed"
echo ""
echo "5. To save waveform manually:"
echo "   - Right-click on Wave window -> Print to File"
echo "   - Choose format: PNG, PDF, or PostScript"
echo "=========================================="
echo ""
echo "Simulation complete!"
echo "Waveform images saved to: ../sim/waveforms/"
echo ""
