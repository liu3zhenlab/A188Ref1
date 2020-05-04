#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=6G
#SBATCH --time=0-23:59:59

module load Java/1.8.0_192
gatk=`which gatk`

oriasm=/bulk/liu3zhen/research/reA188asm/01-canu/A188ONTasm03/A188ONTasm03.contigs.fasta
newasm=A188a3n1.fasta

# merge sequences
#cat splitnp.*/polished/polished* > $newasm

# merge VCFs
vcflist=3o-vcf.list
if [ -f $vcflist ]; then
	rm $vcflist
fi

vcfs=`find . -mindepth 2 -maxdepth 3 -name "*vcf" -type f`

vcfcol=3o-vcfcollection
if [ -d $vcfcol ]; then
	rm -rf $vcfcol
fi
mkdir $vcfcol

for evcf in $vcfs; do
	vcfname=`echo $evcf | sed 's/\/[^\/]*$//g' | sed 's/.*\///g'` # directory name
	vcfout=$vcfcol/${vcfname}.vcf
	echo $vcfout >> $vcflist
	grep -e "^##contig" -e "^##nanopolish_window" -v $evcf > $vcfout;
done

mergevcf=3o-npcor.vcf
seqdict=`echo $oriasm | sed 's/fasta$/dict/g'`
if [ ! -f $seqdict ]; then
	$gatk CreateSequenceDictionary -R $oriasm
fi
$gatk MergeVcfs -O $mergevcf -I $vcflist -D $seqdict

# cleanup
rm -rf $vcfcol
perl ~/scripts/vcf/vcfbox.pl summary 3o-npcor.vcf 1>3o-npcor.vcf.summary

