#!/bin/bash -l
row=$SLURM_ARRAY_TASK_ID
region=`head $1 -n $row | tail -n 1`
echo region $region
echo reads $reads
echo bam $bam
echo ref $seq
echo ploidy $ploidy
echo wd $wd
echo prefix $prefix
$np/nanopolish variants --consensus \
	-w $region \
	-r $reads \
	-b $bam \
	-g $seq \
	-p $ploidy \
	-t $cpu \
	-o $wd/vcf/$prefix.$row.vcf

