#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=2G
#SBATCH --time=0-23:00:00
##SBATCH --partition=ksu-plantpath-liu3zhen.q,batch.q,killable.q 

module load Java/1.8.0_162

ncpus=$SLURM_CPUS_PER_TASK;
trimmomatic=/homes/liu3zhen/software/trimmomatic/Trimmomatic-0.38/trimmomatic-0.38.jar
adp_file=/homes/liu3zhen/software/trimmomatic/Trimmomatic-0.38/adapters/TruSeq3-PE-2.fa
#adp_file=/homes/jinguanglin/software/Trimmomatic-0.38/adapters/adapter_A188_2.fa

for fq1 in ../0-raw/*R1.fq.gz; do
	nsample=`echo $fq1 | sed 's/.*\///g' | sed 's/_R1.fq.gz//g'`
	nsampletrim=${nsample}.trim
	fq2=`echo $fq1 | sed 's/R1.fq.gz/R2.fq.gz/g'`
	echo ${nsample}
	java -Xmx16g -jar $trimmomatic PE \
		-threads ${ncpus} -phred33 \
		-trimlog ${nsampletrim}.log \
		$fq1 $fq2 \
		${nsampletrim}_R1.fq ${nsampletrim}_unpaired_R1.fq \
		${nsampletrim}_R2.fq ${nsampletrim}_unpaired_R2.fq \
		LEADING:3 TRAILING:3 \
		ILLUMINACLIP:${adp_file}:3:20:10:1:true \
		SLIDINGWINDOW:4:13 MINLEN:60
done

#ILLUMINACLIP: Cut adapter and other illumina-specific sequences from the read.
#SLIDINGWINDOW: Performs a sliding window trimming approach. It starts
#scanning at the 5‟ end and clips the read once the average quality within the window
#falls below a threshold.
#MAXINFO: An adaptive quality trimmer which balances read length and error rate to
#maximise the value of each read
#LEADING: Cut bases off the start of a read, if below a threshold quality
#TRAILING: Cut bases off the end of a read, if below a threshold quality
#CROP: Cut the read to a specified length by removing bases from the end
#HEADCROP: Cut the specified number of bases from the start of the read
#MINLEN: Drop the read if it is below a specified length
#AVGQUAL: Drop the read if the average quality is below the specified level
#TOPHRED33: Convert quality scores to Phred-33
#TOPHRED64: Convert quality scores to Phred-64

#ILLUMINACLIP:<fastaWithAdaptersEtc>:<seed mismatches>:<palindrome clip
#threshold>:<simple clip threshold> 

#SLIDINGWINDOW:<windowSize>:<requiredQuality>

