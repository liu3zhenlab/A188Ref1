#!/bin/bash
#SBATCH --cpus-per-task=96
#SBATCH --mem-per-cpu=2G
#SBATCH --time=20-00:00:00
#SBATCH --partition=ksu-gen-highmem.q,ksu-plantpath-liu3zhen.q
sfq1=/bulk/liu3zhen/research/projects/A188PE125/2-merge/A188PE125.R1.pair.fq
sfq2=/bulk/liu3zhen/research/projects/A188PE125/2-merge/A188PE125.R2.pair.fq
qfq1=/bulk/liu3zhen/research/projects/B73PE125/2-merge/B73PE125.R1.pair.fq
qfq2=/bulk/liu3zhen/research/projects/B73PE125/2-merge/B73PE125.R2.pair.fq
ref=/homes/liu3zhen/references/A188Ref1/genome/A188Ref1.fasta

perl ~/scripts2/CGRD/cgrd --ref $ref \
	--subj A188 --sfq1 $sfq1 --sfq2 $sfq2 \
	--qry B73 --qfq1 $qfq1 --qfq2 $qfq2 \
	--prefix B2A --threads 96

