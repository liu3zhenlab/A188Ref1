#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=12G
#SBATCH --time=0-23:00:00

# SNAP model training
# 11/202/2019
makerout=/bulk/liu3zhen/research/A188Ref1/14-maker/4-makerRUNs/round1/A188r1.maker.output
idxlog=A188r1_master_datastore_index.log

modelOut=snaphmm
if [ ! -d $modelOut ]; then
	mkdir $modelOut
fi

pushd $modelOut
#export 'confident' gene models from MAKER and rename to something meaningful
maker2zff -x 0.25 -l 50 -d $makerout/$idxlog

rename genome A188r1 *

# gather some stats and validate
fathom A188r1.ann A188r1.dna -gene-stats > gene-stats.log 2>&1
fathom A188r1.ann A188r1.dna -validate > validate.log 2>&1
# collect the training sequences and annotations, plus 1000 surrounding bp for training
fathom A188r1.ann A188r1.dna -categorize 1000 > categorize.log 2>&1
fathom uni.ann uni.dna -export 1000 -plus > uni-plus.log 2>&1

# create the training parameters
mkdir params
pushd params
forge ../export.ann ../export.dna > ../forge.log 2>&1
popd

# assembly the HMM
hmm-assembler.pl A188r1 params > A188r1.hmm
popd

