setwd("/bulk/liu3zhen/research/projects/A188methyl_A188Ref1/9-genic")

methyl_type = "CpG"
base <- 0.15
ceil <- 0.83
methyl_files <- dir(pattern=methyl_type)
methyl_files <- methyl_files[grep("methyl", methyl_files)]
#colors <- c("darkolivegreen4", "darkorange")
colors <- c("olivedrab4", "lightsalmon3")

pdf("2o-gene.CpG.pdf", width = 4, height = 3.9)

par(mar=c(2.5, 4, 3.5, 1))
plot(NULL, NULL, xlim=c(1, 400), ylim=c(base, ceil),
     xlab = "", ylab = "methylation rates",
     xaxt = "n", main = methyl_type)
abline(v=c(101, 300), col="gray90", lwd=1.5)
axis(1, at = c(1, 100), labels = c("-2kb", "-1bp"))
axis(1, at = c(101, 300), labels = c("TSS", "TTS"), lwd=4, line = -1, xpd = T, tick = F, padj = -2)
axis(1, at = c(301, 400), labels = c("1bp", "2kb"))

for (emfile in methyl_files) {
  methyl <- read.delim(emfile, header = F)
  if (grepl("leaf", emfile)) {
    sel_col <- colors[1]
  } else {
    sel_col <- colors[2]
  }
  lines(x=methyl[, 1], y=methyl[, 2], col = sel_col)
}

legend(x=60, y = ceil, legend = c("seedling", "callus"), lwd = 5,
       col = colors, bty = "n", ncol = 2)

dev.off()
