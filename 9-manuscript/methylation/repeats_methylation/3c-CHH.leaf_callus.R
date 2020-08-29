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
  
  ### paired t.test
  ttres <- t.test(metdata[, "callus"], metdata[, "leaf"], paired=T)
  pval <- as.numeric(ttres[[3]])
  meanDiff <- as.numeric(ttres[[5]])
  meanDiff <- round(meanDiff, 4)
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

# output
output_file <- paste0("4o-repeats.", methyl, ".ttest.res")
write.table(ttest.res, output_file, row.names=F, quote=F, sep="\t")
