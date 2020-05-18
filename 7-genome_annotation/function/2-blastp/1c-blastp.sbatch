#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=2G
#SBATCH --time=0-24:00:00
ncpus=$SLURM_CPUS_PER_TASK
uniprot=~/references/UniProtKB/Swiss-Prot/blast+/swissprot
prot=../../5-postmaker/3-confident/A188Ref1a1.confident.proteins.fasta
out=1o-confident.prot.blastp
log=1o-confident.prot.blastp.log

blastp -db $uniprot \
  -query $prot \
  -out $out -evalue 1e-6 \
  -num_alignments 1 -seg yes -soft_masking true \
  -lcase_masking -max_hsps 1 -num_threads $ncpus \
  -outfmt "6 qseqid qlen sseqid slen length pident ppos qcovs stitle evalue bitscore" \
  1>$out.log 2>&1

# hit evalues
cut -f 1,10 $out > ${out}.evalues

