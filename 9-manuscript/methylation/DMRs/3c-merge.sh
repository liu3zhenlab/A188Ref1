#!/bin/bash

prefix=2o-CHG.DMRs
for i in `seq 10`; do
	if [ $i -eq 1 ]; then
		cat ${prefix}.${i} > ${prefix}.all
	else
		grep "^chr" -v ${prefix}.${i} >>${prefix}.all
	fi
done

