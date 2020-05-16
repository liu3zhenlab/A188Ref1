### A188 maker annotation
The maker annotation pipeline was selected for A188 genome annotation. During the process, we made many mistakes for parameter selection. The protocol from [darencard](https://gist.github.com/darencard/bb1001ac1532dd4225b030cf0cd61ce2) and the information provided by Dr. Bo Wang help establish the following procedure.

#### resouces for learning how to use maker
[maker introduction](http://www.yandell-lab.org/publications/pdf/maker_current_protocols.pdf)  
[maker paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2134774)  
[tutorial_2014](http://weatherby.genetics.utah.edu/MAKER/wiki/index.php/MAKER_Tutorial_for_GMOD_Online_Training_2014)  
[tutorial_2018](MAKER_Tutorial_for_WGS_Assembly_and_Annotation_Winter_School_2018)  
[multiple protocols](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4286374)  
[MPI guide](https://informatics.fas.harvard.edu/maker-on-the-fasrc-cluster.html)  
[case 1](https://gist.github.com/darencard/bb1001ac1532dd4225b030cf0cd61ce2)  
[case 2](https://reslp.github.io/blog/My-MAKER-Pipeline)  
[parameter explanation](http://weatherby.genetics.utah.edu/MAKER/wiki/index.php/The_MAKER_control_files_explained)  

#### Brief about sofeware packages
The maker (2.31.10) conda was installed. Repeatmasker was replaced with an older version (4.0.7).  
Three predictors were used:  
1. snap (2013_11_29)  
2. augustus (3.3.3)  
3. fgenesh (v.8.0.0)  

#### step 1: collect EST/protein evidence and prepare a repeat library


#### step 2: Produce gene models without using gene predictors (round 1)
The configure file [maker_opts.ctl](maker_setting/round1/maker_opts.ctl) was used for round 1.  
Briefly, the A188 assembled transcripts and B73Ref4 protein data were used as EST and protein evidence, respectively. The A188 EDTA repeat library was used as the repeat database. The parameters "est2genome=1" and "protein2genome=1" were set to directly produce gene models from transcripts and proteins. At this stage, no ab initio gene predictors were used.

Slurm scheduler was used for running maker contig by contig. [Here](maker_setting/round1/1-all.sbatch) is the running code.

**Problem**: parallel runs could have conflicting indexed databases or /tmp directories.  
**Solutions**:  
1. Results, including intermediate outputs, of each run was output to separted directory.  
2. Created a independent /tmp directory  
Here are code for running maker on <contig_fasta>
```
prefix=A188
timeid=`date | sed 's/[: ]//g'`
tmpdir=/tmp/"maker_"$timeid
mkdir $tmpdir
mpiexec -n 8 maker -mpi -TMP $tmpdir -base $prefix -f -genome <contig_fasta>
```

Because contigs were run in parallel, additional steps were run to merge data.   
1. Ran [2c-all.check.sh](maker_setting/round1/2c-all.check.sh) to check if a contig run was finished.
2. Once all finished, cp all outputs to a common directory by running [3c-all.cp.sh](maker_setting/round1/3c-all.cp.sh).
3. Generated a log file by running [4c-master.log.producer.sh](maker_setting/round1/4c-master.log.producer.sh).
4. Produced gff and fasta outputs with [5c-merge.sbatch](maker_setting/round1/5c-merge.sbatch).

#### step 3: Train snap models
Train a snap model using [1c-snap.train.sh](1c-snap.train.sh), resulting in a hmm file: [A188r1.hmm](A188r1.hmm).
NOTE: carefully check log files to make sure the running is successful.

#### step 4: Run maker round 2
The gene model set from round 1 used est2genome and protein2genome results of A188 transcripts and B73 proteins. For round 2, these two sets of evidence were not repeatedly used. Instead, gene models produced from round 1 was input as one of predicted gene models (pred_gff=<maker only gff3>). These gene models were competed with gene models predicted by three gene predictors. Additional ESTs from relative maize genotypes and proteins from closely related species were provided for gene model evaluation.

Here is the configure file [maker_opts.ctl](maker_setting/round2/maker_opts.ctl).  

Again, additional steps were run to check and merge outputs:  
1. Ran [2c-all.check.sh](maker_setting/round1/2c-all.check.sh) to check if a contig run was finished.
2. Once all finished, cp all outputs to a common directory by running [3c-all.cp.sh](maker_setting/round1/3c-all.cp.sh).
3. Generated a log file by running [4c-master.log.producer.sh](maker_setting/round1/4c-master.log.producer.sh).
4. Produced gff and fasta outputs with [5c-merge.sbatch](maker_setting/round1/5c-merge.sbatch).


