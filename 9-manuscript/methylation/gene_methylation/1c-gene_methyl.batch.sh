#!/bin/bash
#SBATCH --time=6-00:00:00
#SBATCH --mem-per-cpu=8G
#bismarkout=../5-methyl_CHH-CHG/CHG_context_A188021_leaf.cov.gz.bismark.cov.gz
genebed=~/references/A188Ref1/confident_cds/A188Ref1a1.confident.major.cds.bed
len=~/references/A188Ref1/genome/A188Ref1.length
for bismarkout in ../5-methyl_CHH-CHG/*.cov.gz.bismark.cov.gz; do
	perl ~/scripts2/methyl/methyl.genic.dist.pl --cov $bismarkout --fbed $genebed -g $len
done

