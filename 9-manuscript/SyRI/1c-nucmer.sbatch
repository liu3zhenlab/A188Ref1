#!/bin/bash -l
#SBATCH --mem-per-cpu=40G
#SBATCH --time=20-00:00:00
#SBATCH --cpus-per-task=32
#SBATCH --partition=ksu-biol-ari.q,ksu-gen-highmem.q,ksu-plantpath-liu3zhen.q
a188=/homes/liu3zhen/references/A188Ref1/genome/A188Ref1.chr.fasta
b73=/homes/liu3zhen/references/B73Ref4/genome/B73Ref4.chr.fa
out=A188vsB73
/homes/liu3zhen/local/bin/nucmer --maxmatch -c 500 -b 500 -l 50 -t 48 -p $out $b73 $a188

