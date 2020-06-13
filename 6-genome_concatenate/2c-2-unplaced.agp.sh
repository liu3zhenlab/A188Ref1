#!/bin/bash

# inputs
unplaced_fas=1o-unplaced_rmMtPt_fasta

# intermediate outputs
unplaced_len=2o-unplaced_seq.lens

# final outputs
#out_fas=2o-A188a3ha.ragoo.fasta
unplaced_agp=2o-A188a3ha.ragoo.agp

# unplaced:
#cat ragoo_output/ragoo.fasta | sed 's/_RaGOO//g' | sed 's/^>/>g/g' | sed 's/^>gChr0/>un/g'> $out_fas

# lengths of contigs/scafolds
fastaSize.pl $unplaced_fas > $unplaced_len

if [ -f $unplaced_agp ]; then
	rm $unplaced_agp
fi

for i in `seq 10`; do
	if [ $i -ne 10 ]; then
		id=c0${i}_
	else
		id=c${i}_
	fi

	# keep each contig/scafold separated
	perl ~/scripts2/agp/agp.producer.pl \
		--ctglen $unplaced_len \
		--order ./ragoo_output/orderings/${i}_orderings.txt \
		--seqname $id \
		--ndigit 3 \
		>> $unplaced_agp
done

perl ~/scripts2/agp/agp.producer.pl \
	--ctglen $unplaced_len \
	--order ./ragoo_output/orderings/Chr0_orderings.txt \
	--seqname unk_ \
	--ndigit 3 | sed 's/+/?/g' \
	>> $unplaced_agp

# remove _obj
sed -i 's/_obj//g' $unplaced_agp

# cleanup
rm $unplaced_len

