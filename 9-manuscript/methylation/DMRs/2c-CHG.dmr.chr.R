#setwd("/bulk/liu3zhen/research/projects/A188methyl_A188Ref1/6-CHH.DSS")
#if (!requireNamespace("BiocManager", quietly = TRUE))
#  BiocManager::install(version = "3.10")

library("DSS")
require("bsseq")

args <- commandArgs(trailingOnly = T)
chr <- args[1]
cat("chr =", chr, "\n")

readcov <- function(cov_file, chromosome) {
	covdata <- read.delim(cov_file, header=F, stringsAsFactors = F)
	colnames(covdata) <- c("chr", "pos", "N", "X")
	covdata <- covdata[covdata$chr == chromosome, ]
	stopifnot(nrow(covdata) > 1)
	covdata
}

leaf1 <- readcov("../6-CHG.DSS/A188022_leaf.cov", chr)
leaf2 <- readcov("../6-CHG.DSS/A188023_leaf.cov", chr)
callus1 <- readcov("../6-CHG.DSS/A188122_callus.cov", chr)
callus2 <- readcov("../6-CHG.DSS/A188123_callus.cov", chr)

# prepare data
bsd <- makeBSseqData(list(leaf1, leaf2, callus1, callus2),
                     c("l1","l2", "c1", "c2"))
head(bsd)

# DML test with smoothing; default 500bp
dml <- DMLtest(bsd, group1=c("c1", "c2"), group2=c("l1","l2"), smoothing=TRUE)
write.table(dml, paste0("2o-CHG.DMsites.", chr), row.names = F, quote = F, sep = "\t")

# DMRs
dmrs <- callDMR(dml, delta=0.1, p.threshold=0.05)
write.table(dmrs, paste0("2o-CHG.DMRs.", chr), row.names = F, quote = F, sep = "\t")

