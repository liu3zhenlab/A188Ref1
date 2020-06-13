#!/bin/bash
gtf=all_nano_ST2_merged.A188Ref1.v1.gtf
prefix=`echo $gtf | sed 's/.gtf//g'`
ref=/homes/liu3zhen/references/A188Ref1/genome/A188Ref1.fasta
gffread -E  $gtf -o- > ${prefix}.gff
# convert to fasta:
gffread -w ${prefix}.fasta -g $ref ${prefix}.gff


