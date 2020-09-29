#!/bin/bash -l
#SBATCH --mem-per-cpu=10G  
#SBATCH --time=0-23:00:00  
#SBATCH --ntasks-per-node=12


fq=../0-raw/A188_R021.fq ##input file
out=$(echo $fq |sed 's/.fq//g')


###Trim adapters and split chimeric reads
conda activate porechop
porechop -i $fq -o $out.pc.fq \
                --check_reads 10000 --adapter_threshold 100 \
                --end_size 100 --min_trim_size 5 \
                --end_threshold 80 \
                --extra_end_trim 1 \
                --middle_threshold 100 \
                --extra_middle_trim_good_side 5 \
                --extra_middle_trim_bad_side 50 \
                --verbosity 1

###Trim ploy(A) tail
conda activate cutadapt
cutadapt -g T{12} -e 0.1 -a A{12} -n 100 -j 16 -o $out.cut.fq.gz $out.pc.fq
