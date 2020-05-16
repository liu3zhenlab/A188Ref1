#!/bin/bash
illumina=../1-cheng/all_ST2_merged.gtf
nanopore=../2-guifang/nanopore.leaf_callus.gtf
merged=all_nano_ST2_merged.A188Ref1.v1.gtf
transcript_prefix=A188rna
## Stringtie2 merges all illumina merged gtf with nanopore merge gtf ##
stringtie --merge -g 0 -l $transcript_prefix -o $merged $illumina $nanopore

