#!/bin/bash
# inputs
all_unplaced_ctgs=1o-unplaced_rmMtPt_fasta
hybrid_scaf_agp=/bulk/liu3zhen/research/A188Ref1/07-hybrid/A188hy2/hybrid_scaffolds/EXP_REFINEFINAL1_bppAdjust_cmap_A188a3n2mpp2_rm_mp_fasta_NGScontigs_HYBRID_SCAFFOLD.agp
hybrid_scaf_fas=/bulk/liu3zhen/research/A188Ref1/07-hybrid/A188hy2/hybrid_scaffolds/EXP_REFINEFINAL1_bppAdjust_cmap_A188a3n2mpp2_rm_mp_fasta_NGScontigs_HYBRID_SCAFFOLD.fasta
ragoo_agp=2o-A188a3ha.ragoo.agp

# intermediate outputs
ctgscaf_list=3o-A188a3ha.unplaced.ctgs.scafs
hybrid_scaf_rmObj_agp=3o-A188a3ha_rmMtPt_HYBRID_SCAFFOLD.rmObj.agp

# final outputs
unplaced_out_agp=3o-A188a3ha.unplaced.ctgs.scafs.agp
unplaced_out_fas=3o-A188a3ha.unplaced.ctgs.scafs.fasta

# extract agp for contigs and scaffolds
cut -f 6 $ragoo_agp | sort | uniq > $ctgscaf_list
cat $hybrid_scaf_agp | sed 's/_obj//g' > $hybrid_scaf_rmObj_agp
perl ~/scripts/regular/lookup.pl --Qkey 1 --Tkey 1 --intersect \
	$hybrid_scaf_rmObj_agp \
	$ctgscaf_list \
	> $unplaced_out_agp

# remove _obj from sequence names
sed 's/_obj//g' $all_unplaced_ctgs > $unplaced_out_fas

#liftOver
perl ~/scripts2/agp/agp.liftover.pl \
	--main $ragoo_agp \
	--map $hybrid_scaf_rmObj_agp \
	--fas $unplaced_out_fas \
	>$unplaced_out_agp

# clean
rm $ctgscaf_list
rm $hybrid_scaf_rmObj_agp
rm $unplaced_out_fas

