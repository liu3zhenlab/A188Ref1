#!/bin/bash
prefix=A188Ref1a1.working
newgff=${prefix}.gff
ref=/homes/liu3zhen/references/A188Ref1/genome/A188Ref1.fasta

rawgff=../1-liftover/A188Ref1a1.1.gff3
map=A188Ref1.raw.match.table

# change names:
maker_map_ids --prefix Zm00056a --justify 6 $rawgff > ${map}.tmp
# change to community standard:
perl /homes/liu3zhen/scripts2/maker/letter2num.replace.pl ${map}.tmp > $map
rm ${map}.tmp

# gff
cp $rawgff ${newgff}.tmp
map_gff_ids $map ${newgff}.tmp
#sed 's/;Alias=.*//g' -i ${newgff}.tmp # to rm Alias information
perl /homes/liu3zhen/scripts2/maker/names.correct.pl --gff ${newgff}.tmp > $newgff
gffread $newgff -T -o ${prefix}.gtf
rm ${newgff}.tmp

# transcript, cds, protein
gffread $newgff -g $ref -w ${prefix}.transcripts.fasta -x ${prefix}.cds.fasta -y ${prefix}.proteins.fasta
# remove the part after a space in names
sed 's/ .*//g' -i ${prefix}.transcripts.fasta
sed 's/ .*//g' -i ${prefix}.cds.fasta
sed 's/ .*//g' -i ${prefix}.proteins.fasta
sed -i 's/\.$//g' ${prefix}.proteins.fasta # remove the stop codon (.)

# cleanup
#rm $rawgff

