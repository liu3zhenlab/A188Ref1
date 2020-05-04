#!/bin/bash -l
#SBATCH --cpus-per-task=96
#SBATCH --mem-per-cpu=2G
#SBATCH --time=0-23:59:00
##SBATCH --partition=ksu-gen-highmem.q,ksu-biol-ari.q,batch.q,ksu-plantpath-liu3zhen.q

samtools_module=SAMtools/1.9-foss-2018b
java_module=Java/1.8.0_192

module load $samtools_module
module load $java_module

cpunum=$SLURM_CPUS_PER_TASK
pilon_cpunum=4 # seems multiple cores are not well used; suggest using 4 cores
pilon_memGBperCPU=16 # total memory should be >= 48G; suggest 64G

pilonJar=/homes/liu3zhen/software/pilon/pilon-1.23.jar
pe1=/bulk/liu3zhen/research/projects/A188PE250/2-merge/A188.PE250.trim.all.R1.pair.fq
pe2=/bulk/liu3zhen/research/projects/A188PE250/2-merge/A188.PE250.trim.all.R2.pair.fq
fasta=/bulk/liu3zhen/research/A188Ref1/03-pilon/A188a3n2mpp1.fasta
asm=`echo $fasta | sed 's/.*\///g'`
newasm=A188a3n2mpp2
wd=`pwd`

# softlink the assembly to the current directory
if [ ! -f $asm ]; then
	ln -s $fasta .
fi

nctgs=`grep "^>" -c $fasta`
nctgPerGroup=`expr "$nctgs" "/" 90` # number of contigs per group
echo "randomly group $nctgPerGroup contigs in to a file"
#########################################
# 1.alignment
#########################################
# tmp directory
alndir=$wd/1-aln
if [ ! -d $alndir ]; then
	mkdir $alndir
fi

# aln
pushd $alndir
out=read2asm
if [ ! -f $out.sort.bam.bai ]; then
	ln -s $wd/$asm .
	bwa index $asm
	# alignment
	bwa mem -t $cpunum $asm $pe1 $pe2 > $out.sam

	# sam2bam
	samtools view -@ $cpunum -b $out.sam -o $out.bam
	samtools sort -@ $cpunum $out.bam -o $out.sort.bam
	samtools index -@ $cpunum $out.sort.bam

	rm $out.sam
	rm $out.bam
fi
popd $wd

#########################################
# 2. split data
#########################################
splitdir=$wd/2-split
if [ ! -d $splitdir ]; then
	mkdir $splitdir
fi

pushd $splitdir
ctglist=2-contigs.random.list
grep "^>" $wd/$asm | sed 's/^>//g' | shuf > $ctglist
split -l $nctgPerGroup --numeric-suffixes=1 $ctglist ctg
rename "ctg0" "ctg" ctg*
nctgfiles=`ls ctg* -1 | wc -l | sed 's/ .*//g'`
popd $wd

#########################################
# 3. pilon
#########################################
total_mem=`expr "$pilon_memGBperCPU" '*' "$pilon_cpunum"`
# pilon
pilondir=$wd/3-pilon
if [ ! -d $pilondir ]; then
	mkdir $pilondir
fi

cd $pilondir
pilonsh=3c-pilon.sh
echo "#!/bin/bash" > $pilonsh
echo "module load "$java_module >> $pilonsh
echo "java -Xmx${total_mem}g -jar $pilonJar \\" >> $pilonsh
echo "--genome $wd/$asm \\" >> $pilonsh
echo "--frags $alndir/$out.sort.bam \\" >> $pilonsh
echo "--targets $splitdir/ctg\$SLURM_ARRAY_TASK_ID \\" >> $pilonsh
echo "--output $newasm.\$SLURM_ARRAY_TASK_ID \\" >> $pilonsh
echo "--outdir $pilondir \\" >> $pilonsh
echo "--fix bases \\" >> $pilonsh
echo "--threads \$SLURM_CPUS_PER_TASK \\" >> $pilonsh
echo "--minmq 40 --minqual 20 --changes --vcf" >> $pilonsh

# submit an array job:
sbatch --array=1-$nctgfiles \
  --job-name=$newasm \
  --output=%J_%A_%a.log \
  --error=%J_%A_%a.err \
  --cpus-per-task=$pilon_cpunum \
  --mem-per-cpu=${pilon_memGBperCPU}g \
  --time=4-00:00:00 \
  $pilonsh

cd $wd
