#1. set margin
set margin 10
#2. set width for Silago design blocks
set width 500
#3. set height for Silago design blocks
set height 500
#4. create floorplan area
# Using GF22FDX site name
create_floorplan -site SC8T_104CPP_CMOS22FDX -core_size [expr {8*$width + 7*$margin}] \
    [expr {2*$height + 1*$margin}] 10 10 10 10 
#5. Creating boundary constraints for Silago design blocks
for {set i 0} {$i < 8} {incr i} {
#Top row	
    #set x1 
    #set y1 
    #set x2 
    #set y2 
    set x1 [expr {$i*($width + $margin) + $margin}]
    set y1 [expr {$height + 2 * $margin}]
    set x2 [expr {$x1 + $width}]
    set y2 [expr {$y1 + $height}]
    #set the cell 
    set cell [lindex $all_partition_hinst_list $i]
    puts $cell
    #create_boundary_constraint for the cell
    create_boundary_constraint -type fence -hinst $cell -rects [list [list $x1 $y1 $x2 $y2]]
#Bottom row
    #set x1 
    #set y1 
    #set x2 
    #set y2 
    set x1 [expr {$i*($width + $margin) + $margin}]
    set y1 $margin
    set x2 [expr {$x1 + $width}]
    set y2 [expr {$y1 + $height}]
    #set the cell 
    set cell [lindex $all_partition_hinst_list [expr {$i + 8}]]
    puts $cell
    #create_boundary_constraint for the cell
    create_boundary_constraint -type fence -hinst $cell -rects [list [list $x1 $y1 $x2 $y2]]
}