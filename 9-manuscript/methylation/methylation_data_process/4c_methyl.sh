#!/bin/bash
#SBATCH --mem-per-cpu=6G
#SBATCH --time=3-00:00:00
#SBATCH --cpus-per-task=16
##SBATCH --partition=ksu-plantpath-liu3zhen.q,batch.q,killable.q
methl=/homes/liu3zhen/software/Bismark/Bismark_v0.22.1_dev/bismark_methylation_extractor
#methl=/homes/jinguanglin/software/Bismark_v0.20.0/bismark_methylation_extractor
ref=../2-genomePrep
dedupDir=../3-aln
ncpus=$SLURM_CPUS_PER_TASK
module load SAMtools/1.9-foss-2018b

for bam in $dedupDir/*deduplicated.bam; do
  $methl -p --no_overlap --comprehensive \
  --cytosine_report --genome_folder $ref \
  -bedGraph --scaffolds --gzip --parallel $ncpus \
  --buffer_size 20G \
  $bam
done

