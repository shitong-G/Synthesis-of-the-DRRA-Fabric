# Design-specific variables
# This file can be used to set design-specific parameters

# Clock period (should match logic synthesis)
# Can be overridden by environment variable
if {[info exists ::env(CLOCK_PERIOD)]} {
    set CLOCK_PERIOD $::env(CLOCK_PERIOD)
} else {
    set CLOCK_PERIOD 20.0
}

# Power/ground net names
set POWER_NET "VDD"
set GROUND_NET "VSS"

# Design margins
set MARGIN 10

# Block dimensions (in microns)
set BLOCK_WIDTH 500
set BLOCK_HEIGHT 500

# Core utilization
set CORE_UTILIZATION 0.7

# Place and route settings
set PLACE_EFFORT medium
set ROUTE_EFFORT medium

