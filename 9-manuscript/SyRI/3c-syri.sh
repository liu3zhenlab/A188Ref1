#!/bin/bash
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=4G
#SBATCH --time=6-00:00:00

# with --nosnp, it took 8.5h and 10Gb memory 

syricmd=/homes/liu3zhen/software/syri/syri/bin/syri
ref=B73Ref4.chr.fasta
qry=A188Ref1.chr.fasta
delta=A188vsB73.filt.i95.l1k.m.chr.delta

# 1. data preparation
# change names of chromosomes from numbers to characters
sed 's/^>\([0-9]\)/>chr\1/g' /homes/liu3zhen/references/B73Ref4/genome/B73Ref4.chr.fa > $ref
sed 's/^>\([0-9]\)/>chr\1/g' /homes/liu3zhen/references/A188Ref1/genome/A188Ref1.chr.fasta > $qry
sed 's/^>\([0-9]\{1,2\}\) \([0-9]\)/>chr\1 chr\2/g' ../1-nucmer_maxmatch/A188vsB73.filt.i95.l1k.m.delta \
	| sed 's/[^ ]*\///g' | sed s'/fa /fasta /g' > $delta
show-coords -THrd $delta > ${delta}.coords

# 2. SyRI
# --allow-offset 100 is to avoid copy gain/loss of too samll regions
# if snps are needed to be output, remove --nosnp
$syricmd -c ${delta}.coords --nc 10 -r ${ref} -q ${qry} -d ${delta} --nosnp --allow-offset 100

