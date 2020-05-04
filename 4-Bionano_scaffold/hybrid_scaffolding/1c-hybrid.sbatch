#!/bin/bash
#SBATCH --mem-per-cpu=2G
#SBATCH --time=0-23:00:00
#SBATCH --cpus-per-task=120
#SBATCH --partition=ksu-biol-ari.q,ksu-plantpath-liu3zhen.q,ksu-gen-highmem.q

# load modules
#module load R
perlbrew switch  perl-5.16.3
bnPipe=/homes/liu3zhen/software/BioNano/tools/pipeline/1.0/
bnOut=/bulk/liu3zhen/research/projects/A188Bionano/4-asm-A188asm022/asm5/contigs/
A188asm=A188a3n2mpp2.rm.mp.fasta
A188bionanoCmap=$bnOut/exp_refineFinal1/EXP_REFINEFINAL1.cmap
hybridscriptpath=$bnPipe/HybridScaffold/1.0
hybrid_cfg=$bnPipe/HybridScaffold/1.0/hybridScaffold_DLE1_config.xml
refaligner=$bnPipe/RefAligner/1.0/sse/RefAligner
#refalign_cfg=optArguments_haplotype_DLE1_saphyr.xml
refalign_cfg=/bulk/liu3zhen/research/projects/A188Bionano/bionanoXML/optargs_DLE1.xml
denovoasm_script_path=$bnPipe/Pipeline/1.0
denovoasm_noise=$bnOut/auto_noise/autoNoise1.errbin
filterBNX=/bulk/liu3zhen/research/projects/A188Bionano/1-filter/3o-A188.filter.min150kb.molecules.bnx # molecules
out=A188hy2

# run
perl $hybridscriptpath/hybridScaffold.pl \
	-n $A188asm \
	-b $A188bionanoCmap \
	-c $hybrid_cfg \
	-r $refaligner \
	-B 2 -N 2 \
	-x -y -f \
	-m $filterBNX \
	-p $denovoasm_script_path \
	-q $refalign_cfg \
	-e $denovoasm_noise \
	-o $out

#-n <sequence file in FASTA format>
#-b <Bionano CMAP file>
#-c <hybrid scaffold configuration file in XML format>
#-r <RefAligner binary file>
#-o <output directory>
#-B <conflict filter level genome maps: 1, 2, or 3>
#-N <conflict filter level for sequences: 1, 2, or 3>
#-f <a flag to overwrite existing files; optional>
#-x <a flag to align molecules to hybrid scaffolds and genome maps>
#-y <a flag to generate chimeric quality score for the input genome maps>
#-M <a conflict resolution text file; optional>
#-m <molecule BNX file to align molecules to genome maps and hybrid scaffolds; optional> -p <de novo assembly pipeline script; optional but needed by the -x option>
#-q <de novo assembly optArguments XML files; optional but needed for the -x option>
#-e <de novo assembly noise parameter ERRBIN or ERR file; recommended for -y option>
#-v <a flag to print the pipeline version>

