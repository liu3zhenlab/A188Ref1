in_bnx=../0-raw/RawMolecules.bnx
out_bnx=1o-A188.filter.Molecules.bnx
logfile=1o-filter.log
filter_SNR_dynamic.pl -i $in_bnx -o $out_bnx 1>$logfile 2>&1

