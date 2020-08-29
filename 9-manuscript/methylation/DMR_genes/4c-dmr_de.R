setwd("/bulk/liu3zhen/research/projects/A188methyl_A188Ref1/10-DMRs/5-DMR_expression")

##########################################################################################################
# modules
##########################################################################################################
dmrde_analysis <- function(de, dmrfile, distance_to_gene=1000, region=c("gene body", "5-upstream", "3-downstream"), methyl=c("CpG", "CHG", "CHH")) {
  dmr <- read.delim(dmrfile, header = F)
  colnames(dmr) <- c("methylChr", "methylStart", "methylEnd", "Length", "nCHG", "callusMethyl", "leafMethyl",
                     "geneChr", "geneStart", "geneEnd", "Gene", "Symbol", "Strand", "Distance")
  if (region == "gene body") {
    regiondmr <- dmr[dmr$Distance == 0, ]
  } else if (region == "5-upstream") {
    regiondmr <- dmr[(dmr$Distance <= distance_to_gene & dmr$Strand == "+" & dmr$methylEnd < dmr$geneStart) |
                       (dmr$Distance <= distance_to_gene & dmr$Strand == "-" & dmr$methylStart > dmr$geneEnd), ]
  } else if (region == "3-downstream") {
    regiondmr <- dmr[(dmr$Distance <= distance_to_gene & dmr$Strand == "+" & dmr$methylStart > dmr$geneEnd) |
                       (dmr$Distance <= distance_to_gene & dmr$Strand == "-" & dmr$methylEnd < dmr$geneStart), ]
  }
  
  dmrde <- merge(regiondmr, de, by="Gene")
  dmr_diff <- dmrde$callusMethyl - dmrde$leafMethyl
  deqval <- dmrde$callus_seedling.qval
  delog2fc <- dmrde$callus_seedling.log2fc
  desig <- deqval<0.05 & abs(delog2fc)>0
  
  ### 
  plot(dmr_diff, delog2fc, cex = 0.1,
       xlab="Methyl diff (callus - seedling)",
       ylab="log2(callus/seedling)",
       main=paste(methyl, region))
  points(dmr_diff[desig], delog2fc[desig], cex=0.2, pch=19, col="red")
  abline(h=0, v=0, col="red", lty=2)
  #abline(h=c(-5, 5), col="orange", lty=2)
  
  dmr_dn_gene_up <- sum(dmr_diff < 0 & desig & delog2fc > 0)
  dmr_dn_gene_dn <- sum(dmr_diff < 0 & desig & delog2fc < 0)
  dmr_up_gene_up <- sum(dmr_diff > 0 & desig & delog2fc > 0)
  dmr_up_gene_dn <- sum(dmr_diff > 0 & desig & delog2fc < 0)
  
  stat <- c(dmr_dn_gene_up, dmr_dn_gene_dn, dmr_up_gene_up, dmr_up_gene_dn)
  stat.matrix <- matrix(stat, nrow=2, byrow=T)
  chisq <- chisq.test(stat.matrix)[[1]]
  chisq <- round(chisq, 2)
  dof <- chisq.test(stat.matrix)[[2]]
  pval <- chisq.test(stat.matrix)[[3]]
  pval <- round(pval, 4)
  out <- c(methyl, region, stat, chisq, dof, pval)
  names(out) <- c("methyl", "region", "dmrDn_geneUp", "dmrDn_geneDn", "dmrUp_geneUp", "dmrUp_geneDn", "chisq", "degree_freedom", "pvalue")
  out
}

##########################################################################################################
### DEGs
##########################################################################################################
defile <- "/bulk/liu3zhen/research/projects/A188RNASeq/3-diverse.tissues/A188Ref1/4-DE/callus/1o-callus_seedling.DE"
de <- read.delim(defile)

##########################################################################################################
# modules
##########################################################################################################
dmr <- read.delim("CHG/1o-CHG.DMR.cds", header = F)
colnames(dmr) <- c("methylChr", "methylStart", "methylEnd", "Length", "nCHG", "callusMethyl", "leafMethyl",
                   "geneChr", "geneStart", "geneEnd", "Gene", "Symbol", "Strand", "Distance")
##########################################################################################################
### DMR-DEG
##########################################################################################################
regions <- c("gene body", "5-upstream", "3-downstream")

allout <- NULL

### CHG
methyl01 <- "CpG"
dmrfile01 <- paste0(methyl01, "/1o-", methyl01, ".DMR.cds")
for (region in regions) {
  out <- dmrde_analysis(de=de, dmrfile=dmrfile01, region=region, methyl=methyl01, distance_to_gene=1000)
  allout <- rbind(allout, out)
}

### CHG
methyl02 <- "CHG"
dmrfile02 <- paste0(methyl02, "/1o-", methyl02, ".DMR.cds")
for (region in regions) {
  out <- dmrde_analysis(de=de, dmrfile=dmrfile02, region=region, methyl=methyl02, distance_to_gene=1000)
  allout <- rbind(allout, out)
}

### CHH
methyl03 <- "CHH"
dmrfile03 <- paste0(methyl03, "/1o-", methyl03, ".DMR.cds")
for (region in regions) {
  out <- dmrde_analysis(de=de, dmrfile=dmrfile03, region=region, methyl=methyl03, distance_to_gene=1000)
  allout <- rbind(allout, out)
}

allout <- data.frame(allout)
rownames(allout) <- 1:nrow(allout)
allout
