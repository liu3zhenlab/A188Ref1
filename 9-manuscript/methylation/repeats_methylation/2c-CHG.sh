#!/bin/bash
#SBATCH --mem-per-cpu=16G
#SBATCH --time=1-00:00:00

outDir=CHG
for methyl in ${outDir}/*cov.gz.100bp.methyl.depth; do
	methylSample=`echo $methyl | sed 's/.*\///g' | sed 's/.cov.gz.100bp.methyl.depth//g'`
	echo $methylSample
	for bed in ../3-elementsREC/1-elements_beds/*bed; do
		element=`echo $bed | sed 's/.*\///g' | sed 's/1o-//g' | sed 's/.bed//g'`
		echo $element
		bedtools intersect -a $methyl -b ${bed} | cut -f 1,2,3,7 > ${outDir}/${methylSample}.100bp.methyl.${element}
	done
done
