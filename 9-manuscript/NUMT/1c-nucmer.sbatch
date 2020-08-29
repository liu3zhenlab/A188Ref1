#!/bin/bash -l
#SBATCH --mem-per-cpu=3G
#SBATCH --time=6-00:00:00
#SBATCH --cpus-per-task=16
#SBATCH --partition=ksu-biol-ari.q,ksu-gen-highmem.q,ksu-plantpath-liu3zhen.q
mt=../../database/1-mitochondion/A188mt.fasta
aref1=/homes/liu3zhen/references/A188Ref1/genome/A188Ref1.fasta
out=A188mt_Ref1

# alignment
/homes/liu3zhen/local/bin/nucmer --maxmatch -t 16 -l 20 -p $out $aref1 $mt
# filter
delta-filter -i 90 -l 500 -m $out.delta  > $out.filt.delta
# convert to table
show-coords -H -T $out.filt.delta > $out.filt.txt
# bed
awk '{ print $8"\t"$1 - 1"\t"$2  }' $out.filt.txt | grep -e "mt" -e "pt" -e "^c" -v | sort -k1,1n -k2,2n > $out.filt.bed

# filter2
delta-filter -i 95 -l 5000 -m $out.delta  > $out.filt.i95l5kb.delta
show-coords -H -T $out.filt.i95l5kb.delta > $out.filt.i95l5kb.txt
awk '{ print $8"\t"$1 - 1"\t"$2  }' $out.filt.i95l5kb.txt | grep -e "mt" -e "pt" -e "^c" -v | sort -k1,1n -k2,2n > $out.filt.i95l5kb.bed

