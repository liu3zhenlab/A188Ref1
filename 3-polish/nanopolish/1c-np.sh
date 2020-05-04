#!/bin/sh

#################################
# supply full-path for inputs
#################################
prefix=splitnp
npcor=/homes/liu3zhen/scripts2/npcor/npcor2
ref=/bulk/liu3zhen/research/reA188asm/01-canu/A188ONTasm03/A188ONTasm03.contigs.fasta
reads=/bulk/liu3zhen/research/reA188asm/00-nanoData/A188.guppy344b.gt10kb.fastq
bam=/bulk/liu3zhen/research/A188Ref1/00-canu/4-nanopore2asm/1o-reads2ref.bam
npDir=/homes/liu3zhen/software/nanopolish/nanopolish_0.11.0
scriptDir=/homes/liu3zhen/scripts2/npcor/utils
splitseqDir=1o-split
javaModule=Java/1.8.0_192
samtoolsModule=SAMtools/1.9-foss-2018b
ncpu=8
log=1o-run.log

if [ -f $log ]; then
	nlog=`ls -1 ${log}* | wc -l`
	log=${log}.${nlog}
fi

date > $log

# spliting
echo "1. split fasta" &>>$log

if [ -d $splitseqDir ]; then
	rm -rf $splitseqDir
fi
mkdir $splitseqDir
cd $splitseqDir
perl $scriptDir/split.fasta.pl --num 1 --prefix $prefix --decrease $ref &>>../$log 
cd ..

echo "2. run NP correction" &>>$log
# run correction
for ctg in $splitseqDir/splitnp*; do
	echo "np: "$ctg >> $log
	$npcor -n $npDir -f $ctg -r $reads -b $bam \
		-s $scriptDir \
		-m 100000 \
		-l $javaModule \
		-l $samtoolsModule \
		-t 10-00:00:00 \
		-c $ncpu \
		-g 5 \
		>> $log
done
date >> $log

#-a ksu-gen-highmem.q,batch.q,ksu-biol-ari.q,vis.q,ksu-gen-reserved.q,ksu-plantpath-liu3zhen.q,killable.q \

