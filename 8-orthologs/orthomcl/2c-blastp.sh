#!/bin/bash
#SBATCH --cpus-per-task=96
#SBATCH --mem-per-cpu=100M
#SBATCH --time=20-00:00:00

# filter proteins
orthomclFilterFasta ../1-prep/fasta 20 20
#1. first 20 is the minimum allowed length of proteins.  (suggested: 10)
#2. second 20 is the maximum percent stop codons.  (suggested 20)

# all-2-all alignments
makeblastdb -in goodProteins.fasta -dbtype prot
blastp -query goodProteins.fasta -db goodProteins.fasta -evalue 1e-5 -outfmt 6 -num_threads 96 > all2all

