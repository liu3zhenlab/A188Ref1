#!/bin/bash
origff=A188r1.all.makerOnly.gff3
agp=A188Ref1.agp
gff0=A188Ref1a1.0.gff3
gff1=A188Ref1a1.1.gff3

# liftover
perl gff.agp.liftover.pl --map $agp --gff $origff > $gff0
# sort
perl gff3sort.pl --precise --chr_order natural $gff0 > $gff1
# cleanup
rm $gff0

