#!/bin/bash

workingGFF=../2-working/A188Ref1a1.working.itps.gff
confident=A188Ref1a1.confident

ref=/homes/liu3zhen/references/A188Ref1/genome/A188Ref1.fasta

# filter
perl ~/scripts2/maker/quality_filter_Liu.pl -s -a 0.4 $workingGFF > ${confident}.gff
sed -i 's/Alias=.*//g' ${confident}.gff

# gff to gtf
gffread ${confident}.gff -T -o ${confident}.gtf

# transcript, cds, protein
gffread ${confident}.gff -g $ref -w ${confident}.transcripts.fasta -x ${confident}.cds.fasta -y ${confident}.proteins.fasta
# remove the part after a space in names
sed 's/ .*//g' -i ${confident}.transcripts.fasta
sed 's/ .*//g' -i ${confident}.cds.fasta
sed 's/ .*//g' -i ${confident}.proteins.fasta
sed -i 's/\.$//g' ${confident}.proteins.fasta # remove the stop codon (.)

# cleanup
#rm $rawgff

