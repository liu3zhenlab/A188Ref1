#!/bin/bash
a188=A188Ref1a1.confident.major.proteins.fasta
b73=B73Ref4.ensembl46.major.proteins.fasta
orthomclAdjustFasta A188 $a188 1
orthomclAdjustFasta B73 $b73 1

mkdir fasta
mv A188.fasta fasta
mv B73.fasta fasta

