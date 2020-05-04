library("genoseg")

geno <- read.delim("BADH2.A188Ref1.filt.txt", stringsAsFactors = F)
geno$CHROM <- gsub("_[0-9]+$", "", geno$Site)
geno$POS <- gsub(".*_", "", geno$Site)
geno$POS <- as.numeric(as.character(geno$POS))
tigcounts <- table(geno$CHROM)
tigs <- names(tigcounts)[tigcounts >= 5]
length(tigs)
genocols <- grep("BA", colnames(geno))

base <- "BADH2.A188Ref1.filt"
segout <- paste0(base, ".seg.txt")
segscore <- paste0(base, ".seg.score.txt")

# segmentation
genosegDH(geno = geno, genocols = genocols, chromosomes = tigs, chrname = "CHROM", posname = "POS", 
          output.common = base, data.type = "logratio", allele1.name = "1", 
          allele2.name = "2", missing.name = "0", allele1.code = -1, 
          allele2.code = 1, min.seg.size = 1e+05, cna.alpha = 0.01, 
          cna.nperm = 10000, cna.p.method = "perm", cna.eta = 0.01, cna.min.width = 2, 
          seg.mean.cutoffs = c(-0.8, 0.8))

seg <- read.delim(segout)
segnum <- table(seg$Individual)
cat(segnum)
rmdhs <- names(segnum[segnum >= 55])
length(rmdhs)
cat(rmdhs)
seg2 <- seg[!seg$Individual %in% rmdhs, ]
nrow(seg2)
segout2 <- paste0(base, ".seg.filt.txt")
write.table(seg2, segout2, row.names = F, quote = F, sep = "\t")

# convert segments to scores:
segout <- seg2score(seg.input = segout2,
		segscore.output = segscore,
		missing.data.code = 0, binsize = 100000)

