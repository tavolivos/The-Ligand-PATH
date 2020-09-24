#THIS SCRIPT WAS WRITEN BY GUSTAVO E. OLIVOS-RAMIREZ. gustavo.olivos@upch.pe


draw color red

set frm [molinfo top get numframes]
set atom [atomselect top "resname UNL"]
set points [open "points.tcl" w]
set lines [open "lines.tcl" w]

for {set i 0} {$i < $frm} {incr i} {
	$atom frame $i
	set mass [measure center $atom weight mass]
	puts $points [lindex $mass]
	puts $lines [lindex $mass]
}

close $points
close $lines

exec gawk -i inplace {
    NR == 1 {prev = $0; next}
    {printf "draw line {%s} {%s} width 2\n", prev, $0; prev = $0}
} lines.tcl

source lines.tcl


exec gawk -i inplace {
    NR == 1 {prev = $0}
    {printf "draw sphere {%s} radius 0.4 resolution 60\n", $0}
} points.tcl

source points.tcl

