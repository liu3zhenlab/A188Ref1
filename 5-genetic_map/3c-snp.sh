#!/bin/bash
A188bamdir=/bulk/liu3zhen/research/projects/A188PE125/3-aln2A188Ref1
B73bamdir=/bulk/liu3zhen/research/projects/B73PE125/2-aln2A188Ref1
DHbamdir=../2-alnfilter
bamdir=$A188bamdir,$B73bamdir,$DHbamdir
ref=/homes/liu3zhen/references/A188Ref1/genome/gatk/A188Ref1.fasta
perl ~/local/slurm/snp/gatk.sbatch.pl \
	--outbase BADH_A188Ref1 \
	--bampaths $bamdir \
	--ref $ref \
	--mem 4G --maxlen 2000000
  #--checkscript
