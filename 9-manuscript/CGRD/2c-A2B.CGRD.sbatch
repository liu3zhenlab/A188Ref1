#!/bin/bash
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=4G
#SBATCH --time=20-00:00:00
#SBATCH --partition=ksu-gen-highmem.q,batch.q
qfq1=/bulk/liu3zhen/research/projects/A188PE125/2-merge/A188PE125.R1.pair.fq
qfq2=/bulk/liu3zhen/research/projects/A188PE125/2-merge/A188PE125.R2.pair.fq
sfq1=/bulk/liu3zhen/research/projects/B73PE125/2-merge/B73PE125.R1.pair.fq
sfq2=/bulk/liu3zhen/research/projects/B73PE125/2-merge/B73PE125.R2.pair.fq
ref=~/references/B73Ref4/genome/B73Ref4.fa
perl ~/scripts2/CGRD/cgrd --ref $ref \
	--subj B73 --sfq1 $sfq1 --sfq2 $sfq2 \
	--qry A188 --qfq1 $qfq1 --qfq2 $qfq2 \
	--prefix A2B --plusbins --threads $SLURM_CPUS_PER_TASK

