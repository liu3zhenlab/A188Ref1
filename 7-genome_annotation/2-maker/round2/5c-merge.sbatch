#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=16G
#SBATCH --time=0-23:00:00
# merge data
#conda activate mymaker
cd A188r1.maker.output
fasta_merge -d A188r1_master_datastore_index.log 
gff3_merge -n -s -d A188r1_master_datastore_index.log >  A188r1.all.maker.gff3
gff3_merge -g -n -s -d A188r1_master_datastore_index.log >  A188r1.all.makerOnly.gff3
awk '$2=="est2genome"' A188r1.all.maker.gff3 > A188r1.all.maker.est2genome.gff3
awk '$2=="protein2genome"' A188r1.all.maker.gff3 > A188r1.all.maker.protein2genome.gff3
cd ..

