setwd("/bulk/liu3zhen/research/projects/A188methyl_A188Ref1/10-DMRs/6-DMR_summary")

cpg <- read.delim("../0-DMRs/2o-CpG.DMRs.all")
head(cpg)

# number, length, up and dn, smallest diff and highest diff

dmrsum <- function(dmrfile, methyl) {
  dmr <- read.delim(dmrfile)
  dmr.len <- dmr$length
  dmr.len.mean <- round(mean(dmr.len))
  dmr.len.range <- range(dmr.len)
  ndmr <- nrow(dmr)
  ndmr.up <- sum(dmr$diff.Methy > 0)
  ndmr.dn <- sum(dmr$diff.Methy < 0)
  dmr.up.range <- range(dmr$diff.Methy[dmr$diff.Methy > 0])
  dmr.up.range <- round(dmr.up.range, 2)
  dmr.dn.range <- range(dmr$diff.Methy[dmr$diff.Methy < 0])
  dmr.dn.range <- round(dmr.dn.range, 2)
  out <- c(methyl, ndmr, dmr.len.range, dmr.len.mean, ndmr.up, dmr.up.range, ndmr.dn, dmr.dn.range)
  names(out) <- c("methyl", "ndmr", "min.len", "max.len", "mean.len",
                  "ndmr.up", "min.up", "max.up",
                  "ndmr.dn", "min.dn", "max.dn")
  out <- data.frame(out)
  colnames(out) <- methyl
  out
}

cpg <- dmrsum("../0-DMRs/2o-CpG.DMRs.all", "CpG")
chg <- dmrsum("../0-DMRs/2o-CHG.DMRs.all", "CHG")
chh <- dmrsum("../0-DMRs/2o-CHH.DMRs.all", "CHH")

dmrsummary <- cbind(cpg, chg, chh)

