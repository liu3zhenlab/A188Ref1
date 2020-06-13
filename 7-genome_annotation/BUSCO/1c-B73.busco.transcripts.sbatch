#!/bin/bash
#wget https://busco.ezlab.org/datasets/prerelease/liliopsida_odb10.tar.gz
transcriptome=Zea_mays.B73_RefGen_v4.cdna.all.fa
db=liliopsida_odb10
run_busco -i $transcriptome -c 8 -o B73transcripts -m transcriptome -l $db
