#!/bin/bash

#tig00014418	A188r1_datastore/9B/09/tig00014418/	STARTED
#tig00013457_subseq_177283:3909233	A188r1_datastore/CA/A0/tig00013457_subseq_177283%3A3909233/	FINISHED

dsdir=A188r1_datastore
out=A188r1_master_datastore_index.log
if [ -f $out ]; then
	rm $out
fi

pushd A188r1.maker.output
for edir in $dsdir/*/*/*; do
	ctg=`echo $edir | sed 's/.*\///g' | sed 's/\%.*//g'`
	echo -e $ctg"\t"$edir"\tSTARTED" >> $out
	echo -e $ctg"\t"$edir"\tFINISHED" >> $out
done
popd

