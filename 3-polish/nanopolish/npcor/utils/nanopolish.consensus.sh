#!/bin/bash -l

$np/nanopolish variants --consensus \
	-w $1 \
	-r $reads \
	-b $bam \
	-g $seq \
	-p $ploidy \
	-t $cpu \
	-o $wd/vcf/$prefix.$1.vcf

