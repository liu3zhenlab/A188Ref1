#!/bin/bash
#SBATCH --time=23:00:00

out=A188r1.maker.output
if [ ! -d $out ]; then
	mkdir $out
fi

if [ ! -d $out/A188r1_datastore ]; then
	mkdir $out/A188r1_datastore
fi


pushd $out

for src in ../results/A188r1*/A188r1.maker.output/A188r1_datastore/*/*; do
	des=`echo $src | sed 's/.*A188r1.maker.output\///g'`
	echo $src
	path1=`echo $des | sed 's/A188r1_datastore\///g' | sed 's/\/.*//g'`
	
	if [ ! -d A188r1_datastore/$path1 ]; then
		mkdir A188r1_datastore/$path1
	fi
	
	path2=`echo $des | sed 's/A188r1_datastore\///g' | sed 's/.*\///g'`
	if [ ! -d A188r1_datastore/$path1/$path2 ]; then
		mkdir A188r1_datastore/$path1/$path2
	fi

	cp -r $src/* A188r1_datastore/$path1/$path2/
done

popd

