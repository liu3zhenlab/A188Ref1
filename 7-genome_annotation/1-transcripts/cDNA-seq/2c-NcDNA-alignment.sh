#!/bin/bash -l  
#SBATCH --mem-per-cpu=16G  
#SBATCH --time=0-23:00:00  
#SBATCH --ntasks-per-node=12

 
module load SAMtools

ref=~/reference/A188/A188Ref1/minimap2/A188Ref1.mmi
fq=$1
out=$(echo $fq |sed 's/.*\///g'| sed 's/.fq.gz//g') 
out=$out.A188Ref1
/homes/liu3zhen/software/minimap2/minimap2 -t 10 -ax splice $ref $fq 1 > $out.sam  2>$out.log

 samtools view -bS $out.sam -o $out.tmp
        samtools sort $out.tmp -o $out.bam
        samtools index $out.bam

rm $out.tmp