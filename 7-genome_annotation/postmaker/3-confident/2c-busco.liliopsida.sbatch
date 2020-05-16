#!/bin/bash
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=1G
#SBATCH --time=1-00:00:00

#conda activate asm
# download data on 9/25/2019
#wget https://busco.ezlab.org/datasets/prerelease/liliopsida_odb10.tar.gz
#tar -xf liliopsida_odb10.tar.gz 
db=/bulk/liu3zhen/research/A188asm/33-BUSCO/liliopsida_odb10
transcriptome=A188Ref1a1.confident.transcripts.fasta
proteins=A188Ref1a1.confident.proteins.fasta
run_busco -i $proteins -c 32 -o 2o-maker.liliopsida.proteins -m  proteins -l $db -t 2otmp
run_busco -i $transcriptome -c 32 -o 2o-maker.liliopsida.transcripts -m transcriptome -l $db -t 2otmp2

