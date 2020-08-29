#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=10G
#SBATCH --time=10-00:00:00
#SBATCH --partition=ksu-gen-highmem.q,ksu-biol-ari.q,ksu-plantpath-liu3zhen.q,batch.q,killable.q 
module load SAMtools/1.9-foss-2018b
ncpus=$SLURM_CPUS_PER_TASK
bismark=/homes/liu3zhen/software/Bismark/Bismark_v0.22.1_dev/bismark
refdir=/bulk/liu3zhen/research/projects/A188methyl_A188Ref1/2-genomePrep
fq1=$1
fq2=$2
$bismark --bowtie2 \
		-p $ncpus $refdir \
		--1 $fq1 --2 $fq2

