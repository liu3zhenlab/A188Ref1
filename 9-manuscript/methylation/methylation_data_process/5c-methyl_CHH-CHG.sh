#!/bin/bash
input=$1
bedgraph=/homes/liu3zhen/software/Bismark/Bismark_v0.22.1_dev/bismark2bedGraph
out=$(echo $input | sed 's/.*\///g' | sed 's/_bt2_pe.deduplicated.txt.gz//g')
echo $out
$bedgraph -o ${out}.cov --CX $input

