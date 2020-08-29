setwd("/bulk/liu3zhen/research/A188Ref1/18-sv/4-syriplot")
source("syriplot.R")

a188chrlen <- read.delim("~/references/A188Ref1/genome/A188Ref1.length", header=F)
b73chrlen <- read.delim("~/references/B73Ref4/genome/B73Ref4.length", header=F)
for (chr in 1:10) {
  cat("chr", chr, "\n", sep="")
  pdfoutput <- paste0("chr", chr, ".syri.0.5Mb.pdf")
  ref.chrlen <- b73chrlen[b73chrlen[, 1] == chr, 2]
  qry.chrlen <- a188chrlen[a188chrlen[, 1] == chr, 2]
  syriplot(syriout="syri.allow.offset.100bp.out",
         chr=chr, ref.chrlen=ref.chrlen, qry.chrlen=qry.chrlen,
         ref.name="B73Ref4", qry.name="A188Ref1",
         ref.chr.highlight.bed="B73Ref4.highlight",
         qry.chr.highlight.bed="A188Ref1.highlight",
         min.syn.size=10000, min.others.size=500000,
         xleft=0, xright=1, ref.ypos=0.15, qry.ypos=0.75,
         chr.col="gray80", main="", legend.add=T,
         outpdf=T, outfile=pdfoutput, pdfwidth=6, pdfheight=3)
}
