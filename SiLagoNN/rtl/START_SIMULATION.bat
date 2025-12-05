@echo off
REM ============================================================================
REM Batch script to start simulation from correct directory
REM ============================================================================

echo Switching to testbench directory...
cd ..\tb\vec_add

echo Starting simulation...
vsim -suppress 1549 -voptargs=+acc -L ../../rtl/work -do ../../rtl/simulate_final.do work.testbench

pause


