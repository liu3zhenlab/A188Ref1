#!/bin/bash
#wget https://busco.ezlab.org/datasets/prerelease/liliopsida_odb10.tar.gz
db=liliopsida_odb10
transcriptome=A188Ref1a1.confident.transcripts.fasta
run_busco -i $transcriptome -c 8 -o A188transcripts -m transcriptome -l $db -t tmp2

