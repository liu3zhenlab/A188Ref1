#!/bin/sh
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=16G
#SBATCH --time=10-00:00:00

prefix=splitnp
npmerge=/homes/liu3zhen/scripts2/npcor/npcormerge
splitseqDir=1o-split
runlog=2o-run.log
joblog=2o-npmerge.log

date > $runlog
sh $npmerge -p $prefix -d $splitseqDir -o $joblog >>$runlog
date >> $runlog

