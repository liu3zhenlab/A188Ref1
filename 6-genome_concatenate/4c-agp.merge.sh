#!/bin/bash

# script
agp2table=/homes/liu3zhen/scripts2/agp/agp2orgtable.pl
fa_organizer=/homes/liu3zhen/scripts/fasta/fasta.reorganiz.pl

# inputs
ctgs_fas=../4-contigs/A188Ref1.contigs.fasta
chr_agp=../1-chr.placed/A188a3ha.chr.agp
unplaced_agp=../2-unplaced/3o-A188a3ha.unplaced.ctgs.scafs.agp
mt_agp=../3-mtpt/1o-mt.agp 
pt_agp=../3-mtpt/1o-pt.agp

# intermediate output
organized_table=A188Ref1.organized.table

# output
out_agp=A188Ref1.agp
out_fas=A188Ref1.fasta
out_len=A188Ref1.length

# merge agp
cat $chr_agp $unplaced_agp $mt_agp $pt_agp | grep "^#" -v > $out_agp

# produce organized table
perl $agp2table $out_agp > $organized_table

# produce fasta
perl $fa_organizer --fasta $ctgs_fas --table $organized_table > $out_fas
fastaSize.pl $out_fas > $out_len

# cleanup
rm $organized_table

