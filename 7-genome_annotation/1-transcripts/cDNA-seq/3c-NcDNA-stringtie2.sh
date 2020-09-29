#!/bin/bash -l  
#SBATCH --mem-per-cpu=3G  
#SBATCH --time=0-23:00:00  
#SBATCH --ntasks-per-node=16


###calli transcript
bam=../3-aln/calli.ont.A188Ref1.bam   
out=calli.ont.A188Ref1
stringtie  -L -A $out.stat -o $out $bam

###leaf transcript
bam=../3-aln/leaf.ont.A188Ref1.bam   
out=leaf.ont.A188Ref1
stringtie  -L -A $out.stat -o $out $bam



###merge leaf and calli transcript
stringtie --merge -o nanopore.gtf -c 5 -F 0 -T 0 -g 0 calli.ont.A188Ref1.gtf leaf.ont.A188Ref1.gtf