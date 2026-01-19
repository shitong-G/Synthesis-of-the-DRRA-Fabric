# Script to check utilization and floorplan size
# Usage: innovus -stylus -batch -files check_utilization.tcl

# Read the assembled design
cd ../phy/db/part
read_db drra_wrapper.enc.dat/pnr

puts "\n=========================================="
puts "Floorplan and Utilization Report"
puts "==========================================\n"

# Get floorplan dimensions
set core_bbox [get_db current_design .core_bbox]
set core_width [expr {[lindex $core_bbox 2] - [lindex $core_bbox 0]}]
set core_height [expr {[lindex $core_bbox 3] - [lindex $core_bbox 1]}]
set core_area [expr {$core_width * $core_height}]

puts "Core Dimensions:"
puts "  Width:  $core_width um"
puts "  Height: $core_height um"
puts "  Area:   $core_area um²\n"

# Get cell statistics
set std_cells [get_db insts -if {.is_placed == true && .cell.base.is_physical == false}]
set num_std_cells [llength $std_cells]

# Calculate placed cell area
set total_cell_area 0
foreach cell $std_cells {
    set bbox [get_db $cell .bbox]
    set cell_width [expr {[lindex $bbox 2] - [lindex $bbox 0]}]
    set cell_height [expr {[lindex $bbox 3] - [lindex $bbox 1]}]
    set cell_area [expr {$cell_width * $cell_height}]
    set total_cell_area [expr {$total_cell_area + $cell_area}]
}

# Get macro area
set macros [get_db insts -if {.is_placed == true && .cell.base.is_physical == true}]
set num_macros [llength $macros]
set total_macro_area 0
foreach macro $macros {
    set bbox [get_db $macro .bbox]
    set macro_width [expr {[lindex $bbox 2] - [lindex $bbox 0]}]
    set macro_height [expr {[lindex $bbox 3] - [lindex $bbox 1]}]
    set macro_area [expr {$macro_width * $macro_height}]
    set total_macro_area [expr {$total_macro_area + $macro_area}]
}

set total_placed_area [expr {$total_cell_area + $total_macro_area}]
set utilization [expr {($total_placed_area / $core_area) * 100.0}]

puts "Cell Statistics:"
puts "  Standard cells: $num_std_cells"
puts "  Macros:         $num_macros"
puts "  Total cells:    [expr {$num_std_cells + $num_macros}]\n"

puts "Area Statistics:"
puts "  Standard cell area: $total_cell_area um²"
puts "  Macro area:         $total_macro_area um²"
puts "  Total placed area:  $total_placed_area um²"
puts "  Core area:          $core_area um²"
puts "  Utilization:        [format "%.2f" $utilization]%\n"

# Check partition sizes
puts "Partition Information:"
set partitions [get_db insts -if {.is_partition == true}]
foreach part $partitions {
    set part_name [get_db $part .name]
    set part_bbox [get_db $part .bbox]
    set part_width [expr {[lindex $part_bbox 2] - [lindex $part_bbox 0]}]
    set part_height [expr {[lindex $part_bbox 3] - [lindex $part_bbox 1]}]
    set part_area [expr {$part_width * $part_height}]
    puts "  $part_name: ${part_width}x${part_height} um (area: $part_area um²)"
}

puts "\n=========================================="
puts "Recommendations:"
puts "=========================================="
if {$utilization < 30.0} {
    puts "WARNING: Utilization is very low ($utilization%)."
    puts "Consider reducing floorplan size by approximately [format "%.0f" [expr {100.0 / $utilization}]]%"
    puts "Suggested core size: [format "%.0f" [expr {$core_width * sqrt($utilization / 70.0)}]] x [format "%.0f" [expr {$core_height * sqrt($utilization / 70.0)}]] um"
    puts "(Target utilization: 70%)"
} elseif {$utilization < 50.0} {
    puts "Utilization is moderate ($utilization%)."
    puts "Consider reducing floorplan size slightly."
} else {
    puts "Utilization is reasonable ($utilization%)."
}
puts ""

