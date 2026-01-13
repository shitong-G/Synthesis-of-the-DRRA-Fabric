# Power planning script
# This script creates the power/ground mesh for the design

#1. Create power rings
# Create VDD ring
create_power_ring -nets {VDD} -width 5 -spacing 2 -layer {top M7 bottom M7 left M6 right M6}

# Create VSS ring  
create_power_ring -nets {VSS} -width 5 -spacing 2 -layer {top M7 bottom M7 left M6 right M6}

#2. Create power stripes
# Vertical stripes
create_power_straps -nets {VDD} -layer M6 -width 5 -spacing 20 -direction vertical -start_at 0 -num_instances 20

create_power_straps -nets {VSS} -layer M6 -width 5 -spacing 20 -direction vertical -start_at 10 -num_instances 20

# Horizontal stripes
create_power_straps -nets {VDD} -layer M7 -width 5 -spacing 20 -direction horizontal -start_at 0 -num_instances 20

create_power_straps -nets {VSS} -layer M7 -width 5 -spacing 20 -direction horizontal -start_at 10 -num_instances 20

#3. Connect power rings to stripes
sroute -connect { blockPin padPin padRing corePin floatingStripe } -layerChangeRange { M1 M7 } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort oneGeom } -padPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } -allowJogging 1 -crossoverViaLayerRange { M1 M7 } -nets { VDD VSS } -allowLayerChange 1 -blockPin useLef -targetViaLayerRange { M1 M7 }

