#!/bin/bash -l
#SBATCH --mem-per-cpu=60G
#SBATCH --time=6-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --partition=ksu-gen-highmem.q,batch.q,ksu-biol-ari.q,ksu-plantpath-liu3zhen.q
module load Java/1.8.0_192

# generate a bam list
vcf=BADH_A188Ref1_FriApr241438072020/BADH_A188Ref1.vcf
ref=/homes/liu3zhen/references/A188Ref1/genome/gatk/A188Ref1.fasta
out=BADH_A188Ref1
gatk SelectVariants \
	-R $ref \
	-V $vcf \
	-select 'DP >= 300.0' \
	--restrict-alleles-to BIALLELIC \
	-select-type SNP \
	-O $out.1.vcf &>$out.log

# select SNP A188=0/0 and B73=1/1
perl ~/scripts/vcf/vcf.select.samples.geno.pl --vcf $out.1.vcf \
	--samples "A188-1,A188-2,B73R1,B73R2" \
	--geno "0/0,0/0,1/1,1/1" \
	> $out.2.AB.vcf
cut $out.2.AB.vcf -f 1-9,14- > $out.3.AB.DHs.vcf

# geno recall with more stringent criteria and filter sites with high missing rates
perl ~/scripts/vcf/vcf.geno.recall.pl --homoMinAD 2 --homoMinADperc 0.9 \
	--heteroMinAD 1 --heteroMinADperc 0.2 --maxMissing 0.7 \
	--vcf $out.3.AB.DHs.vcf \
	1>$out.4.AB.recall.DHs.vcf \
	2>$out.4.AB.recall.DHs.log

# taxon filtering
perl ~/scripts/vcf/vcf.taxa.filter.pl \
	--vcf $out.4.AB.recall.DHs.vcf \
	--minValid 5000 --maxMissingPerc 0.9 --heteroPercMin 0 \
	--heteroPercMax 0.2 \
	--output $out.5.AB.recall.DHs.taxafilt.vcf
	2>$out.5.AB.recall.DHs.taxafilt.log

