#!/bin/bash
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=2G
#SBATCH --time=1-00:00:00

#conda activate mymaker
module load Java/11.0.2

interproscan=/homes/liu3zhen/software/interproscan/interproscan-5.39-77.0/interproscan.sh
protfas=A188Ref1a1.working.proteins.fasta
gff=A188Ref1a1.working.gff
updated_gff=A188Ref1a1.working.itps.gff

# interproscan
$interproscan -appl PfamA -cpu $SLURM_CPUS_PER_TASK -iprlookup -goterms -f tsv -i $protfas

# update with interproscan data
ipr_update_gff $gff ${protfas}.tsv > $updated_gff

