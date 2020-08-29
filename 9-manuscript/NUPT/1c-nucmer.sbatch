#!/bin/bash -l
#SBATCH --mem-per-cpu=3G
#SBATCH --time=6-00:00:00
#SBATCH --cpus-per-task=16
#SBATCH --partition=ksu-biol-ari.q,ksu-gen-highmem.q,ksu-plantpath-liu3zhen.q
pt=../../database/2-chloroplast/A188Pt.fas
aref1=/homes/liu3zhen/references/A188Ref1/genome/A188Ref1.fasta
out=A188pt_Ref1

# alignment
/homes/liu3zhen/local/bin/nucmer --maxmatch -t 16 -l 20 -p $out $aref1 $pt
# filter
delta-filter -i 90 -l 500 -m $out.delta  > $out.filt.delta
# convert to table
show-coords -H -T $out.filt.delta > $out.filt.txt

