#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=2G
#SBATCH --time=1-00:00:00
module load Java/11.0.2
ncpus=$SLURM_CPUS_PER_TASK
interproscan=/homes/liu3zhen/software/interproscan/interproscan-5.39-77.0/interproscan.sh
prot=../../5-postmaker/3-confident/A188Ref1a1.confident.proteins.fasta
out=1o-confident.prot.interproscan
log=1o-confident.prot.interproscan.log
sh $interproscan -cpu $ncpus -i $prot -f tsv -o $out -goterms --pathways 1>$log 2>&1

# pfam
#awk '$4 == "Pfam"' $out | cut -f 1 | sort | uniq > ${out}.pfam.transcripts
awk '$4 == "Pfam"' $out > ${out}.pfam

