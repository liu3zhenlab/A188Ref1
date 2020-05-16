#!/bin/bash
origff=../../4-makerRUNs/round2/A188r1.maker.output/A188r1.all.makerOnly.gff3
agp=~/references/A188Ref1/genome/A188Ref1.agp
gff0=A188Ref1a1.0.gff3
gff1=A188Ref1a1.1.gff3

# liftover
perl ~/scripts2/maker/gff.agp.liftover.pl --map $agp --gff $origff > $gff0
# sort
perl /homes/liu3zhen/software/gff3sort/gff3sort.pl --precise --chr_order natural $gff0 > $gff1
# cleanup
rm $gff0

