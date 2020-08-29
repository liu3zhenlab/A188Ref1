#!/bin/bash -l
#SBATCH --mem-per-cpu=96G
#SBATCH --time=25-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --partition=ksu-gen-highmem.q,ksu-plantpath-liu3zhen.q,batch.q,killable.q
out=A188vsB73

# filter 1
delta-filter -i 95 -l 1000 ${out}.delta  > ${out}.filt.i95.l1k.delta

# filter 2
delta-filter -m ${out}.filt.i95.l1k.delta  > ${out}.filt.i95.l1k.m.delta
# this step took >6 days
# to add -q -r resulted in more alignments. I think -1 was overrided if -q -r were added.

# convert to txt
show-coords -THrd ${out}.filt.i95.l1k.m.delta > ${out}.filt.i95.l1k.m.delta.txt


