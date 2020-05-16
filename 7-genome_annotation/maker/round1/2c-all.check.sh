#!/bin/bash
for i in `seq 1 1878`; do
	dirfound=noOUT
	gfffound=noGFF
	if [ -d A188r1_all.${i} ]; then
		dirfound=yesOUT
		gff=`find A188r1_all.${i}/A188r1.maker.output/A188r1_datastore/*/*/*/*gff 2>/dev/null`;
		if [ ! -z $gff ]; then
			gfffound=yesGFF
		fi
	fi
	echo -e "large\t"$i"\t"$dirfound"\t"$gfffound
done

