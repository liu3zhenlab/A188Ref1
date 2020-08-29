setwd("/bulk/liu3zhen/research/projects/A188methyl_A188Ref1/10-DMRs/4-plot")

library(reshape)

logs <- c("../1-CpG/2o-CpG.DMRs.up.log", "../1-CpG/2o-CpG.DMRs.dn.log",
          "../2-CHG/2o-CHG.DMRs.up.log", "../2-CHG/2o-CHG.DMRs.dn.log",
          "../3-CHH/2o-CHH.DMRs.up.log", "../3-CHH/2o-CHH.DMRs.dn.log")

all <- NULL
for (log in logs) {
  partition <- read.delim(log, header=F)
  methyl.info <- gsub(".*\\/2o-", "", log)
  methyl.info <- gsub(".DMR.", "", methyl.info)
  methyl.info <- gsub(".log", "", methyl.info)
  methyl <- gsub("\\..*", "", methyl.info)
  dmr.change <- gsub(".*\\.", "", methyl.info)
  colnames(partition) <- c("Group", "Count")
  partition$Methyl <- methyl
  partition$DMR <- dmr.change
  all <- rbind(all, partition)
}

all <- data.frame(all)
total <- all[all$Group=="totalDMRs", 2:4]
genic <- all[all$Group=="onfeatureDMRs", 2:4]



total.data <- cast(data=total, DMR~Methyl, value="Count")
rnames <- total.data[,1]
cnames <- colnames(total.data)
total.data <- total.data[,-1]
total.data <- as.matrix(total.data)
rownames(total.data) <- rnames
colnames(total.data) <- cnames[-1]

genic.data <- cast(data=genic, DMR~Methyl, value="Count")
rnames <- genic.data[,1]
cnames <- colnames(genic.data)
genic.data <- genic.data[,-1]
genic.data <- as.matrix(genic.data)
rownames(genic.data) <- rnames
colnames(genic.data) <- cnames[-1]

intergenic.data <- total.data - genic.data
colnames(genic.data) <- paste0(cnames[-1], "\ngenic")
colnames(intergenic.data) <- paste0(colnames(intergenic.data), "\nintergenic")


combined <- cbind(genic.data, intergenic.data)
combined <- combined[, order(colnames(combined))]
combined

### plot
pdf("2o-DMR.proportion.pdf", width=6.5, height=4.5)
par(mar=c(2, 4, 2.5, 0.2))
colors <- c("royalblue3", "orangered3")
barplot(combined, ylab="number of DMRs", main="callus vs seedling DMRs",
        col=colors, cex.names=1, cex.axis=1, cex.main=1.5)
legend("topright", legend = c("Up", "Down"), lwd=3,
       col=rev(colors), bty="n")
dev.off()
