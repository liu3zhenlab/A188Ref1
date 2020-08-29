setwd("/bulk/liu3zhen/research/projects/A188methyl_A188Ref1/10-DMRs/4-plot")

############################################################################
# modules
############################################################################
# y-axis conversion
yconvert <- function(y, ymax, base, ceil) {
  base + (ceil*0.95 - base) / ymax * y
}

drawdist <- function(up.dmr, dn.dmr, base, ceil, methyl) {
  up <- read.delim(up.dmr, header = F)
  dn <- read.delim(dn.dmr, header = F)
  
  adj.up <- yconvert(up[,5], max(up[, 5], dn[, 5]), base, ceil)
  lines(x=up[, 1], y=adj.up, col = colors[1], lwd=1.5)
  
  adj.dn <- yconvert(dn[,5], max(up[, 5], dn[, 5]), base, ceil)
  lines(x=dn[, 1], y=adj.dn, col = colors[2], lwd=1.5)
  
  text(-10, base, pos=3, labels="0", offset=0.1, xpd=T, cex=0.8)
  text(-10, ceil, pos=1, labels=max(up[, 5]), offset=0.3, xpd=T, cex=0.8)
  text(0, (base+ceil)/2, pos=2, labels=methyl, cex=1.2, xpd=T)
}
############################################################################
colors <- c("orangered3", "royalblue3")

pdf("1o-genic.dmr.dist.pdf", width=5, height = 3.5)

par(mar=c(2.5, 4, 2.5, 1))
plot(NULL, NULL, xlim=c(1, 400), ylim=c(-10, 90),
     xlab = "Bin", ylab = "DMR overlapping bps",
     xaxt = "n", yaxt="n", frame.plot=F,
     main="Genic distribution of callus vs seedling DMRs ")

abline(v=c(1, 101, 300, 400), col="gray90", lwd=1.5)
abline(h=c(1, 30, 60, 90), col="gray30", lwd=1.5)

axis(1, at=c(1, 100, 301, 400), labels=c("-2kb", "-1bp", "1bp", "2kb"))
axis(1, at=c(101, 300), labels=c("TSS", "TTS"), lwd=4,
     line=-1, xpd=T, tick=F, padj=-2)

### CHH
drawdist(up.dmr="../3-CHH/2o-CHH.DMRs.up.bin.dmr",
         dn.dmr="../3-CHH/2o-CHH.DMRs.dn.bin.dmr",
         base=1, ceil=30, methyl="CHH")
### CHG
drawdist(up.dmr="../2-CHG/2o-CHG.DMRs.up.bin.dmr",
         dn.dmr="../2-CHG/2o-CHG.DMRs.dn.bin.dmr",
         base=31, ceil=60, methyl="CHG")
### CpG
drawdist(up.dmr="../1-CpG/2o-CpG.DMRs.up.bin.dmr",
         dn.dmr="../1-CpG/2o-CpG.DMRs.dn.bin.dmr",
         base=61, ceil=90, methyl="CpG")

legend(x=150, y=90, legend = c("Up", "Down"), lwd=3,
       col=colors, bty="n", ncol=2)

dev.off()
