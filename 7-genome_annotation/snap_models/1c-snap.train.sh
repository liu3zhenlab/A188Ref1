#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=12G
#SBATCH --time=0-23:00:00

# SNAP model training
# run maker without snap and return result at "A188.maker.output"
makerout=<path_to>/A188.maker.output
idxlog=A188_master_datastore_index.log

mkdir snap
cd snap

#export 'confident' gene models from MAKER and rename to something meaningful
maker2zff -x 0.25 -l 50 -d $makerout/$idxlog

#rename 's//genome/g' *
# gather some stats and validate
fathom genome.ann genome.dna -gene-stats > gene-stats.log 2>&1
fathom genome.ann genome.dna -validate > validate.log 2>&1
# collect the training sequences and annotations, plus 1000 surrounding bp for training
fathom genome.ann genome.dna -categorize 1000 > categorize.log 2>&1
fathom uni.ann uni.dna -export 1000 -plus > uni-plus.log 2>&1

# create the training parameters
mkdir params
cd params
forge ../export.ann ../export.dna > ../forge.log 2>&1
cd ..

# assembly the HMM
hmm-assembler.pl genome params > snap.genome.hmm

