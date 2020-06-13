#!/bin/bash -l
#SBATCH --job-name=ragoo2v4
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=5g
#SBATCH --time=6-00:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --partition=ksu-biol-ari.q,batch.q,ksu-gen-highmem.q,ksu-plantpath-liu3zhen.q
cpu_num=$SLURM_CPUS_PER_TASK
source /homes/liu3zhen/virtualenvs/python3.6.4/bin/activate
module load Python/3.6.4-foss-2018a

# reference
ref=/homes/liu3zhen/references/B73Ref4/genome/B73Ref4.chr.fa
b73ref=B73Ref4.chr.fa
if [ ! -f $b73ref ]; then
	ln -s $ref $b73ref
fi

# query
unplaced_fasta=../../09-allmaps/2-allmaps/BADH2.A188a3.unplaced.fasta
perl ~/scripts/fasta/seq.extract.pl --feature "tig|Super" --fas $unplaced_fasta > 1o-unplaced_rmMtPt_fasta

# ragoo
ragoo.py -t $cpu_num 1o-unplaced_rmMtPt_fasta $b73ref


