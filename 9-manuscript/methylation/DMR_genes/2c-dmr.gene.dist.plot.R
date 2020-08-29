#!/bin/bash

for dmr in ../0-DMRs/2o-CpG.DMRs*; do
	dataset=`echo $dmr | sed 's/.*\///g'`
	genebed=~/references/A188Ref1/confident_cds/A188Ref1a1.confident.major.cds.bed
	glen=~/references/A188Ref1/genome/A188Ref1.length
	perl ~/scripts2/methyl/DMR.genic.dist.pl \
		--dmr $dmr \
		-fbed $genebed \
		--glen $glen \
		2>${dataset}.log
done
