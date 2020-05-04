#!/bin/bash -l
# all data was generated before 12/12/2018
indata=/bulk/liu3zhen/LiuRawData/nanopore/guppy344b/merge/*fastq
outdir=A188ONTasm03
outprefix=A188ONTasm03
canu=/homes/liu3zhen/software/canu/canu-1.9/Linux-amd64/bin/canu

# load java
module load Java/1.8.0_192
module load gnuplot/5.2.5-foss-2018b

# run canu
$canu -d $outdir \
	-p $outprefix \
	'corMhapOptions=--threshold 0.8 --ordered-sketch-size 1000 --ordered-kmer-size 14' \
	correctedErrorRate=0.105 \
	genomeSize=2.4g \
	minReadLength=10000 \
	minOverlapLength=800 \
	corOutCoverage=60 \
	-gridOptions="--time=4-00:00:00" \
	-nanopore-raw $indata

# some parameters were set based on information at:
# https://canu.readthedocs.io/en/latest/faq.html
# correctedErrorRate=0.12 # so that only the better corrected reads are used. For speed purpose
# Based on a human dataset, the flip-flop basecaller reduces both the raw read error rate and the residual error rate remaining after Canu read correction. For this reason you can reduce the error tolerated by Canu. If you have over 30x coverage add the options:
#'corMhapOptions=--threshold 0.8 --ordered-sketch-size 1000 --ordered-kmer-size 14' correctedErrorRate=0.105.

# Canu consensus sequences are typically well above 99% identity for PacBio datasets. Nanopore accuracy varies depending on pore and basecaller version, but is typically above 98% for recent data.

