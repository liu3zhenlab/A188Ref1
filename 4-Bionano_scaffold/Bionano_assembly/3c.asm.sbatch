#!/bin/bash -l
#SBATCH --mem-per-cpu=10G
#SBATCH --time=5-00:00:00
#SBATCH --cpus-per-task=32
#SBATCH --partition=ksu-biol-ari.q,ksu-plantpath-liu3zhen.q,ksu-gen-highmem.q

# load modules
module load R
#module load Python/2.7.13-foss-2017beocatb

bnx=../1-filter/3o-A188.filter.min150kb.molecules.bnx
bionano_path=/homes/liu3zhen/software/BioNano/tools/pipeline/1.0/Pipeline/1.0/
refaligner_dir=/homes/liu3zhen/software/BioNano/tools/pipeline/1.0/RefAligner/1.0/avx
a_xml=../bionanoXML/optargs_DLE1.xml
ref_cmap=../0-ref_cmap/A188v022/A188v022_DLE1_20kb_0labels.cmap
out=asm5

# run
#echo $SLURM_CPUS_PER_TASK
python2.7 $bionano_path/pipelineCL.py -T $SLURM_CPUS_PER_TASK -b $bnx -r $ref_cmap -f 0.2 -i 5 -y -l $out -a $a_xml -t $refaligner_dir
#-i ITER: Number of extension and merge iterations (default=1, must be in range [0,20], use 0 to skip)
#-f [F]: Run this fraction of grouped jobs on host (0.2 if no arg) [default 0]
#-y: Automatically determine noise parameters (requires reference; optional, default off)
#-l: Location of output files root directory
#-T: num of threads

