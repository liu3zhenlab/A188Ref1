#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=2G
#SBATCH --time=0-24:00:00
ncpus=$SLURM_CPUS_PER_TASK
te=/homes/liu3zhen/references/makerTEproteins/blast+/te_nrd
prot=A188Ref1a1.working.proteins.fasta
out=4o-prot2te.blastp
log=4o-prot2te.blastp.log
te_genes=4o-te.genes

blastp -db $te \
  -query $prot \
  -out $out -evalue 1e-50 -qcov_hsp_perc 60 \
  -num_alignments 1 -seg yes -soft_masking true \
  -lcase_masking -max_hsps 1 -num_threads $ncpus \
  -outfmt "6 qseqid qlen sseqid slen length pident ppos qcovs evalue bitscore" \
  1>$out.log 2>&1

# TE gene list:
cut -f 1 $out | sed 's/_T.*//g' | sort | uniq > $te_genes

