source("/homes/liu3zhen/beocatscripts/snp/snp.filter.R")
source("~/scripts/snp/geno.format.converter.R")

snps <- read.delim("../3-snps/BADH_A188Ref1.6.AB.recall.DHs.taxafilt.corrected.map", stringsAsFactors = F)
dim(snps)
cn <- colnames(snps)
cols <- grep("BA", cn)

snps2 <- format.converter(data = snps, site.cols = c(1, 2), geno.cols = cols,
                          old.code = c("A", "B", "X", "-"), new.code = c(1, 2, 0, 0))
# filter
cn2 <- colnames(snps2)
cols2 <- grep("DH", cn2)
snpsOut <- snp.filter(input = snps2, colranges = cols2,
                      poptype = "DH",
                      taxa.max.missing.rate = 0.8,
                      taxa.min.heter.rate = 0,
                      taxa.max.heter.rate = 0.05,
                      site.max.missing.rate = 0.8,
                      site.min.heter.rate = 0,
                      site.max.heter.rate = 0.05,
                      site.min.maf = 0.1)
# output
write.table(snpsOut, "BADH2.A188Ref1.filt.txt",
            row.names = F, quote = F, sep = "\t")

