#!/bin/bash -l
$npPath/nanopolish variants --consensus \
	-w $1 \
	-r $reads \
	-b $bam \
	-g $seq \
	-t $cpusPerTask \
	-o $wd/vcf/$prefix.$1.vcf

