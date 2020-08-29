setwd("/bulk/liu3zhen/research/A188Ref1/12-repeats/4-elementsMethyl")
options(stringsAsFactors = F)

methyl <- "CHH"
allfiles <- dir(path = methyl, pattern = methyl)
allfiles <- allfiles[!grepl("depth$", allfiles)]
allfiles

# tissue and repeat
tissues <- c("callus", "leaf")

elements <- c("subtelomere", "MITE", "LINE", "Helitron", "TIR",
              "knob180", "Copia", "Gypsy", "CRM", "45s_rDNA", "CentC")
elements_colors <- c("red", "palegreen3", "pink", "blue", "palegreen4",
                     "darkolivegreen3", "wheat4", "turquoise3", "orange", "purple", "gray60")

outlist <- vector("list", length(elements))
names(outlist) <- elements
ttest.res <- NULL
for (element in elements) {

  metdata <- NULL
  for (tissue in tissues) {
    subfiles <- grep(paste0(tissue, ".*", element), allfiles, value=T)
    for (efile in subfiles) {
      sample_tissue <- gsub(".*context_", "", efile)
      sample_tissue <- gsub(".100bp.methyl.*", "", sample_tissue)
      sample_tissue
      met <- read.delim(paste0(methyl, "/", efile), header = F)
      colnames(met) <- c("chr", "start", "end", sample_tissue)
      if (is.null(metdata)) {
        metdata <- met
      } else {
        metdata <- merge(metdata, met, by=c("chr", "start", "end"))
      }
    }
    metdata[, tissue] <- rowMeans(metdata[, grep(tissue, colnames(metdata))])
  }
  
  outlist[[element]] <- metdata
  
  ### paired t.test
  ttres <- t.test(metdata[, "callus"], metdata[, "leaf"], paired=T)
  pval <- as.numeric(ttres[[3]])
  meanDiff <- as.numeric(ttres[[5]])
  meanDiff <- round(meanDiff, 2)
  ttout <- c(element, pval, meanDiff)
  
  ### merge t.test results from all repeat elements
  if (is.null(ttest.res)) {
    ttest.res <- ttout
  } else {
    ttest.res <- rbind(ttest.res, ttout)
  }
}

ttest.res <- data.frame(ttest.res)
rownames(ttest.res) <- 1:nrow(ttest.res)
colnames(ttest.res) <- c("element", "ttest.pval", "diff_callus_leaf")
ttest.res$ttest.pval <- formatC(as.numeric(ttest.res$ttest.pval), format = "e", digits = 2)


library(vioplot)
pdf(paste0("5o-", methyl, ".plot.pdf"), width = 5, height = 4.5)
par(mar=c(3, 6, 3, 0.5), mgp=c(2,1,0))
#leaf_col <- rgb(152/255, 251/255, 152/255, 0.5)  # palegreen 0.5 transparent
#callus_col <- rgb(1, 165/255, 0/255, 0.5)  # orange1 0.5 transparent
leaf_col <- "olivedrab4"
callus_col <- "lightsalmon3"
vp1 <- vioplot(horizontal=T, las = 1,
        outlist[["subtelomere"]][,"leaf"],
        outlist[["MITE"]][,"leaf"],
        outlist[["LINE"]][,"leaf"],
        outlist[["Helitron"]][,"leaf"],
        outlist[["TIR"]][,"leaf"],
        outlist[["knob180"]][,"leaf"],
        outlist[["Copia"]][,"leaf"],
        outlist[["Gypsy"]][,"leaf"],
        outlist[["CRM"]][,"leaf"],
        outlist[["45s_rDNA"]][,"leaf"],
        outlist[["CentC"]][,"leaf"],
        names=elements, col="gray90", border=leaf_col,
        drawRect=F, rectCol=NA, lineCol="gray30", colMed="grey90",
        side="left", lwd = 2,
        xlab=paste(methyl, "methylation level"),
        ylim=c(0, 0.4),
        main=paste(methyl, "of repeats"))

points(vp1$median, c(1:11)-0.2, col=leaf_col, pch=19, cex=0.9)

vp2 <- vioplot(horizontal=T, las = 1,
        outlist[["subtelomere"]][,"callus"],
        outlist[["MITE"]][,"callus"],
        outlist[["LINE"]][,"callus"],
        outlist[["Helitron"]][,"callus"],
        outlist[["TIR"]][,"callus"],
        outlist[["knob180"]][,"callus"],
        outlist[["Copia"]][,"callus"],
        outlist[["Gypsy"]][,"callus"],
        outlist[["CRM"]][,"callus"],
        outlist[["45s_rDNA"]][,"callus"],
        outlist[["CentC"]][,"callus"],
        col="gray90", border=callus_col,
        drawRect=F, rectCol=NA, lineCol="gray30", colMed="grey90",
        side="right", lwd=2, add=T)

points(vp2$median, c(1:11)+0.2, col=callus_col, pch=19, cex=0.9)

methyl_change <- ttest.res$diff_callus_leaf
text_col <- rep("blue", 11)
text_col[methyl_change < 0] <- "red"
text(rep(0.4, 11), c(1:11)+0.3, labels = ttest.res$diff_callus_leaf, pos=2, col=text_col)

dev.off()

