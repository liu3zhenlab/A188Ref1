#!/bin/bash

# inputs
mt=../../database/1-mitochondion/A188_NA_mitochondrion_DQ490952.1.fasta
pt=../../database/2-chloroplast/A188Pt_KF241980.1.fas

# simplify sequence names:
sed 's/ .*//g' $mt > 1o-mt.fasta
sed 's/ .*//g' $pt > 1o-pt.fasta

# produce agp:
perl  ~/scripts2/agp/fasta2agp.pl --fas 1o-mt.fasta --map 1i-mt.map > 1o-mt.agp
perl  ~/scripts2/agp/fasta2agp.pl --fas 1o-pt.fasta --map 1i-pt.map > 1o-pt.agp

