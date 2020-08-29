#!/bin/bash
#SBATCH --mem-per-cpu=16G
#SBATCH --time=1-00:00:00
mkdir CHH
pushd CHH
for bismark in /bulk/liu3zhen/research/projects/A188methyl_A188Ref1/5-methyl_CHH-CHG/CHH*.cov.gz.bismark.cov.gz; do
	perl /homes/liu3zhen/scripts2/methyl/bmcov2bincov.pl \
	--cov $bismark --mins 1 --mind 5
done
popd
#/bulk/liu3zhen/research/projects/A188methyl_A188Ref1/5-methyl_CHH-CHG/CHG_context_A188021_leaf.cov.gz.bismark.cov.gz \
