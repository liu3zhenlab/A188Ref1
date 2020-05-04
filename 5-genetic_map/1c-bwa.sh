#!/bin/bash
ref=/homes/liu3zhen/references/A188Ref1/genome/bwa/A188Ref1
perl /homes/liu3zhen/local/slurm/bwa/bwa.sbatch.pl \
	--mem 3G --time 0-23:59:00 \
	--bwa_shell /homes/liu3zhen/local/bin/bwa \
	--indir ../../0-merge --outdir . \
	--db $ref \
	--fq1feature .R1.pair.fq --fq2feature .R2.pair.fq \
	--threads 16

