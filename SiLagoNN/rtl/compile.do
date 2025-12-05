if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

if {[file exists dware]} {
    vdel -lib dware -all
}
vlib dware
vmap dware dware

vcom -work dware -2008 DW/DWpackages.vhd
vcom -work dware -2008 DW/DW01_add.vhd
vcom -work dware -2008 DW/DW_foundation_comp.vhd
vcom -work dware -2008 DW/DW_Foundation_comp_arith.vhd
vlog -work dware DW/DW_div.v
vlog -work dware DW/DW_div_pipe.v

set compiled_files {}
set fp [open "silagonn_hierarchy.txt" r]
while {[gets $fp line] >= 0} {
    if {[string trim $line] != ""} {
        set file_path $line
        if {[lsearch $compiled_files $file_path] == -1} {
            vcom -work work -2008 $file_path
            lappend compiled_files $file_path
        }
    }
}
close $fp

vcom -work work -2008 ../tb/vec_add/const_package.vhd
vcom -work work -2008 ../tb/vec_add/testbench.vhd
