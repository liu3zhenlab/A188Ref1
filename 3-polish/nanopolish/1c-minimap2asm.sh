#!/bin/bash -l
#SBATCH --cpus-per-task=96
#SBATCH --mem-per-cpu=1G
#SBATCH --time=12-00:00:00

module load SAMtools/1.9-foss-2018b

ncpu=$SLURM_CPUS_PER_TASK
refmmi=/bulk/liu3zhen/research/A188Ref1/00-canu/1-db/minimap2/A188ONTasm03.contigs.mmi
reads=/bulk/liu3zhen/research/reA188asm/00-nanoData/A188.guppy344b.gt10kb.fastq
out=1o-reads2ref

# aln
/homes/liu3zhen/software/minimap2/minimap2 -ax map-ont -N 0 -t $ncpu $refmmi $reads 1>$out.sam 2>$out.log

# bam and sort
samtools view -b -@ $ncpu $out.sam | samtools sort -@ $ncpu -o $out.bam
samtools index -@ $ncpu $out.bam

