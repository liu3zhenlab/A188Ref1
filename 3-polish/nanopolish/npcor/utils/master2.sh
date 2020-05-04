#!/bin/bash -l

# modules:
module load Java/1.8.0_192
module load SAMtools/1.8-foss-2017beocatb

export wd=`pwd`

#########################################
# input information: subject to change
#########################################
###
unpolishedseq=/bulk/liu3zhen/research/A188asm/3-nanopolish/A188ONTasm02/0-split/1-gt8mb/gt8mb.9
samtools faidx $unpolishedseq

###
export prefix=`echo $unpolishedseq | sed 's/.*\///g' | sed 's/[.fasta$|.fas$|.fa$]//g'`

if [ ! -d unpolished ]; then
	mkdir unpolished
fi

export seq=$wd/unpolished/$prefix.fasta
cp $unpolishedseq $seq
#export prefix=`echo $seq | sed 's/.*\///g' | sed 's/.fasta//g'`
maxLen=500000
lenBuffer=10
memPerCpu=1800m
export cpusPerTask=16
runtime=0-23:00:00
export reads=/bulk/liu3zhen/LiuRawData/nanopore/guppy/all_merge/A188WGS_Sep2Dec2019_min5kb_guppyPASS.fasta
export bam=/bulk/liu3zhen/research/A188asm/3-nanopolish/A188ONTasm02/1-aln/A188WGS_Sep2Dec2019_min5kb_guppyPASS.A188ONTasm02.bam
export npPath=/homes/liu3zhen/software/nanopolish/nanopolish_0.11.0
export scriptsDir=/homes/liu3zhen/scripts/nanopolish

# create directories
if [ ! -d log ]; then
	mkdir log
fi

if [ ! -d polished ]; then
	mkdir polished
fi

if [ ! -d vcf ]; then
	mkdir vcf
fi

#if [ ! -d jobs_db ]; then
#	mkdir jobs_db
#fi

# step 1: partition
export partitionOut="1-"$prefix".partition.txt"
perl $scriptsDir/fasPartition.pl --fas $seq --max $maxLen --buffer $lenBuffer > $partitionOut

# step 2: submission
for rowInfo in `cat $partitionOut`; do
	sbatch \
	--mem-per-cpu=$memPerCpu \
	--cpus-per-task=$cpusPerTask \
	--time=$runtime \
	-D $wd \
	-J $prefix \
	-o $wd/log/$prefix"_"$rowInfo."nanopolish.log" \
	$scriptsDir/nanopolish.consensus.sh $rowInfo
done

# step 3: rerun if needed
for rowInfo in `cat $partitionOut`; do
	if [ ! -s $wd/vcf/$prefix.$rowInfo.vcf ]; then
		sbatch \
		--mem-per-cpu=$memPerCpu \
		--cpus-per-task=$cpusPerTask \
		--time=$runtime \
		-D $wd \
		-J $prefix \
		-o $wd/log/$prefix"_"$rowInfo."nanopolish.log" \
		$scriptsDir/nanopolish.consensus.sh $rowInfo
	fi
done

# step 4: merge vcf and generate fasta
sbatch \
	--dependency=singleton \
	--mem-per-cpu=16g \
	--cpus-per-task=1 \
	--time=$runtime \
	-D $wd \
	-J $prefix \
	-o $wd/log/$prefix"_"$rowInfo."vcf2fas.log" \
$scriptsDir/vcf2fas.sh

