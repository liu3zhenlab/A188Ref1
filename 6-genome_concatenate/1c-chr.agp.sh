#!/bin/bash
allmaps_chr_agp=/bulk/liu3zhen/research/A188Ref1/09-allmaps/2-allmaps/BADH2.A188a3.chr.agp
hybrid_scaf_agp=/bulk/liu3zhen/research/A188Ref1/07-hybrid/A188hy2/hybrid_scaffolds/EXP_REFINEFINAL1_bppAdjust_cmap_A188a3n2mpp2_rm_mp_fasta_NGScontigs_HYBRID_SCAFFOLD.agp
hybrid_scaf_fas=/bulk/liu3zhen/research/A188Ref1/07-hybrid/A188hy2/hybrid_scaffolds/EXP_REFINEFINAL1_bppAdjust_cmap_A188a3n2mpp2_rm_mp_fasta_NGScontigs_HYBRID_SCAFFOLD.fasta
prefix=A188a3ha # hybrid_scafolding + allmaps

cut -f 6 $allmaps_chr_agp | grep Super | sort  | uniq > ${prefix}.chr.scaffolds
perl ~/scripts/regular/lookup.pl --Qkey 1 --Tkey 1 --intersect $hybrid_scaf_agp \
	${prefix}.chr.scaffolds > ${prefix}.chr.HYBRID_SCAFFOLD.agp

perl ~/scripts2/agp/agp.liftover.pl --main $allmaps_chr_agp \
	--map ${prefix}.chr.HYBRID_SCAFFOLD.agp \
	--fas $hybrid_scaf_fas | sed 's/^chr//g' > ${prefix}.chr.agp

rm ${prefix}.chr.HYBRID_SCAFFOLD.agp
rm ${prefix}.chr.scaffolds

