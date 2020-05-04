in_bnx=1o-A188.filter.Molecules.bnx
min_len=150 #kb
out_head=3o-A188.filter.min$min_len"kb.molecules"
logfile=3o-len.filter.log
# run
RefAligner -i $in_bnx -minlen $min_len -merge -o $out_head -bnx 1>$logfile 2>&1

