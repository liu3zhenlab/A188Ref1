#!/bin/bash

workingGFF=../2-working/A188Ref1a1.working.itps.gff
te_gene=../2-working/4o-te.genes
confident=A188Ref1a1.confident

ref=/homes/liu3zhen/references/A188Ref1/genome/A188Ref1.fasta

# filter 1 (remove TE genes)
perl ~/scripts2/maker/gff.gene.remove.pl $workingGFF $te_gene 1>${confident}.teclean.itps.gff 2>removed.te.itps.gff

# filter 2 (Pfam and AED)
perl ~/scripts2/maker/quality_filter_Liu.pl -s -a 0.4 ${confident}.teclean.itps.gff > ${confident}.itps.gff
# originally one exon could has multiple parents (transcripts) separated by ","
# after removing some transcripts but their genes, "," was left, which should replaced by ";"
sed -i 's/,$/;$/g' ${confident}.itps.gff
sed 's/Alias=.*//g' ${confident}.itps.gff > ${confident}.gff

# gff to gtf
gffread ${confident}.gff -T -o ${confident}.gtf

# transcript, cds, protein
gffread ${confident}.gff -g $ref -w ${confident}.transcripts.fasta -x ${confident}.cds.fasta -y ${confident}.proteins.fasta
# remove the part after a space in names
sed 's/ .*//g' -i ${confident}.transcripts.fasta
sed 's/ .*//g' -i ${confident}.cds.fasta
sed 's/ .*//g' -i ${confident}.proteins.fasta
sed -i 's/\.$//g' ${confident}.proteins.fasta # remove the stop codon (.)

# list and lengths
grep "^>" ${confident}.transcripts.fasta | sed 's/>//g' > ${confident}.transcripts.list
fastaSize.pl ${confident}.transcripts.fasta | sort -k1 > ${confident}.transcripts.lengths

# cleanup
#rm $rawgff

