#!/bin/bash
# parse all2all alignments
orthomclBlastParser all2all ../1-prep/fasta > similarSequences.txt
# create a mysql database and a configure file
/home/liu3zhen/software/orthomcl-pipeline/scripts/orthomcl-setup-database.pl \
	--user orthomcl --password orthomcl --host localhost \
	--database orthomcl4 --outfile orthomcl.conf
# install the required schema into the database
orthomclInstallSchema orthomcl.conf
# load blast result to database
orthomclLoadBlast orthomcl.conf similarSequences.txt  # 1 h
#find pairs of orthologs (a few hours)
orthomclPairs orthomcl.conf orthomclPairs.log cleanup=yes  # 2-3 hrs
orthomclDumpPairsFiles orthomcl.conf
# group orthologs including paralogs
mcl mclInput --abc -I 1.5 -o mclOutput
orthomclMclToGroups orthogroup 1 < mclOutput > A188.B73.orthologs.groups.txt

