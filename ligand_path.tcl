###################################
#  By: Gustavo E. Olivos-Ramirez  #
#      gustavo.olivos@upch.pe     #
#      Lima-Peru                  #
###################################
color Display Background white
display projection Orthographic
display depthcue off
axes location off
display nearclip set 0.00
scale by 1.200000

mol modselect 0 0 protein 
mol modstyle 0 0 NewCartoon 0.30 40.00 5.00 1
mol modcolor 0 0 ColorID 6
mol modmaterial 0 0 AOShiny

mol addrep 0
mol modselect 1 0 resid 438 to 506
mol modcolor 1 0 ColorID 1
mol modstyle 1 0 NewCartoon 0.30 40.00 5.00 1
mol modmaterial 1 0 AOShiny

mol addrep 0
mol modselect 2 0 resname UNL
mol modstyle 2 0 Licorice 0.300000 40.000000 40.000000
mol modmaterial 2 0 AOShiny
mol modcolor 2 0 Type
color Type C green

draw color blue3

set frm [molinfo top get numframes]
set atom [atomselect top "resname UNL"]
set points [open "points.tcl" w]
set lines [open "lines.tcl" w]
set cones [open "cones.tcl" w]

for {set i 0} {$i < $frm} {incr i} {
	$atom frame $i
	set mass [measure center $atom weight mass]
	puts $points [lindex $mass]
	puts $lines [lindex $mass]
	puts $cones [lindex $mass]
}

close $points
close $lines
close $cones

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

set f [open "cones.tcl" r]
set g [open "cones2.tcl" w]
set coords [split [read -nonewline $f] \n]
close $f

for {set i 0} {$i < [llength $coords] - 1} {incr i} {
    lassign [lindex $coords $i] xi yi zi
    lassign [lindex $coords $i+1] xf yf zf
    set xn [expr {$xi + (($xf - $xi)/1.4)}]
    set yn [expr {$yi + (($yf - $yi)/1.4)}]
    set zn [expr {$zi + (($zf - $zi)/1.4)}]
    puts $g [lindex "draw cone {$xn $yn $zn}" ]
}

close $g

set infile [open cones.tcl r]
set indata [read $infile]
close $infile 
set newdata [string replace $indata 0 [string length [lindex [split $indata \n] 0]] {}]
set outfile [open cones.tcl w]
puts $outfile $newdata
close $outfile 

exec gawk -i inplace {
    NR == 1 {prev = $0}
    {printf " {%s} radius 0. resolution 60\n", $0}
} cones.tcl

exec paste cones2.tcl cones.tcl > final_cones.tcl

source final_cones.tcl

#render POV3 $.pov povray +W3500 +H4025 -I%s -O%s.tga +X +A +FN +UA
