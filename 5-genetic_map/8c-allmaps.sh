#!/bin/sh

# this run was performed in the server of 129.130.89.83 at /data1/home/liu3zhen/A188Genome/A188v035allmaps/...
module load foss/2019b
#export PYTHONPATH=$HOME/.local/lib/python2.7/site-packages:/homes/liu3zhen/.conda/envs/allmaps/share/jcvi:$PYTHONPATH
#export PYTHONPATH=/homes/liu3zhen/.conda/envs/allmaps/share/jcvi:$PYTHONPATH
#export PATH=$HOME/.local/bin:$PATH

genetic_map=../1-data/BADH2.A188_a3.genetmap.regroup.csv
fasta=../1-data/A188a3hy.fasta
out=BADH2.A188a3
python -m jcvi.assembly.allmaps merge $genetic_map -o $out.bed
python -m jcvi.assembly.allmaps path $out.bed $fasta 2>$out.log

