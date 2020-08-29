#!/bin/bash
#conda activate jcvi

# create BED files
python -m jcvi.formats.gff bed --type=mRNA --key=Name ~/references/A188Ref1/confident/A188Ref1a1.confident.gff -o A188.all.bed
python -m jcvi.formats.gff bed --type=mRNA --key=ID ~/references/B73Ref4/genemodel2/Zea_mays.B73_RefGen_v4.46.gff3 -o B73.all.bed
# remove "transcript:" due to extra notes in B73 gff
sed -i  's/transcript://g' B73.all.bed

# extract major transcript

perl ~/scripts/regular/lookup.pl --Qkey 4 --Tkey 1 A188.all.bed ~/references/A188Ref1/confident/A188Ref1a1.confident.major.list --intersect > A188.bed
perl ~/scripts/regular/lookup.pl --Qkey 4 --Tkey 1 B73.all.bed ~/references/B73Ref4/majorTranscripts/B73Ref4.ensembl46.major.transcripts.list --intersect > B73.bed

# format cds fasta
python -m jcvi.formats.fasta format /homes/liu3zhen/references/B73Ref4/majorTranscripts/B73Ref4.ensembl46.major.cds.fasta B73.cds
seqtk subseq /homes/liu3zhen/references/A188Ref1/confident/A188Ref1a1.confident.cds.fasta ~/references/A188Ref1/confident/A188Ref1a1.confident.major.list > A188.major.cds.fasta
python -m jcvi.formats.fasta format A188.major.cds.fasta A188.cds

# synteny
python -m jcvi.compara.catalog ortholog A188 B73 --no_strip_names # 2:2 synteny

# depth
python -m jcvi.compara.synteny depth --histogram A188.B73.anchors 

# organize results:
mkdir synteny2to2
mv A188.B73* synteny2to2

# the previous analysis identify historic genome duplications
# to use --cscore=.99 to find 1:1 synteny relationship
python -m jcvi.compara.catalog ortholog A188 B73 --no_strip_names --cscore=.99

# organize results:
mkdir synteny1to1
mv A188.B73.* synteny1to1/

# cleanup
rm A188.all.bed 
rm B73.all.bed 

