#!/bin/bash
#SBATCH --mem-per-cpu=60G
#SBATCH --time=6-00:00:00
#SBATCH --cpus-per-task=1

# conda activate GC
cfg=~/software/Genotype_correction/schnablelab/configs/ril.config.txt

export PYTHONPATH=~/software/Genotype_correction:$PYTHONPATH
base=BADH_A188Ref1.5.AB.recall.DHs.taxafilt
out=BADH_A188Ref1.6.AB.recall.DHs.taxafilt

# step1:
python -m schnablelab.imputation.GC vcf2map $base.vcf $out.map

# step2: correction
python -m schnablelab.imputation.GC correct $cfg $out.map

