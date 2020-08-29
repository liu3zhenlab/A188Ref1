#!/bin/bash

# format data to meet DSS requirement. The required file contains the following 4 columns:
# chromosome number, genomic coordinate, total number of reads, and number of reads showing methylation
for bm in ../5-methyl_CHH-CHG/CHG_context_*.cov.gz.bismark.cov.gz; do
	out=`echo $bm | sed 's/.*\///g' | sed 's/.*context_//g' | sed 's/.cov.gz.bismark.cov.gz//g'`
	echo $out
	gunzip -dc $bm | awk '{ print $1"\t"$2"\t"$5+$6"\t"$5 }' > $out.cov
done

# 

