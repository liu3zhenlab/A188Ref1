#!/bin/bash -l
#SBATCH --array=1-1878
#SBATCH --job-name=all
#SBATCH --output=all%A_%a_%j.log
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=3G # --mem= for memory per node
#SBATCH --time=0-23:59:59

conda activate mymaker

id=$SLURM_ARRAY_TASK_ID
prefix=A188r1
fasdir=/bulk/liu3zhen/research/A188Ref1/14-maker/2-splitctgs/split  # fullpath
job=all.$id

timeid=`date | sed 's/[: ]//g'`

echo $job
echo $SLURM_JOB_ID

done=0
ctgdir=${prefix}_${job}

# check if the job is complete
if [ -d $ctgdir ]; then
	gff=`find ${ctgdir}/${prefix}.maker.output/${prefix}_datastore/*/*/*/*gff 2>/dev/null`;
	if [ ! -z $gff ]; then
		done=1
	fi
else
	rm -rf $ctgdir
	mkdir $ctgdir
fi

# maker run
if [ $done -eq 0 ]; then
	cp maker_* $ctgdir/

	# tmp directory
	tmpdir=/tmp/"maker_"$timeid  # to solve SQLite problem
	if [ ! -d $tmpdir ]; then
		mkdir $tmpdir
	fi

	pushd $ctgdir
	mpiexec -n $SLURM_CPUS_PER_TASK maker -mpi -TMP $tmpdir -base $prefix -f -genome $fasdir/$job
	rm -rf $tmpdir
	rm ./${prefix}.maker.output/${prefix}.db
	rm -rf ./${prefix}.maker.output/mpi_blastdb
	popd
fi

