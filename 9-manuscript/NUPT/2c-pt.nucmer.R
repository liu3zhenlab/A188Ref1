setwd("/bulk/liu3zhen/research/A188Ref1/15-NUPT/1-nucmer")

#############################################################################
# determine xaxis
#############################################################################
smart.axis <- function(chr_length) {
# smartly determine axix
  numdigits <- nchar(chr_length)
  unit <- 10 ^ (numdigits - 1) / (2 - round((chr_length / 10 ^ numdigits), 0)) # 1 or 5 e (numdigits)
  subunit <- unit / 5 

  nums_at <- unit * (0:10)
  nums_at <- nums_at[nums_at < chr_length]
  
  if (unit >= 6) {
    scaled_labels <- nums_at / 1000000
    scale_len <- 1000000
    scale_label <- "Mb"
  } else if (numdigits < 6) {
    scaled_labels <- unit / 1000
    scale_len <- 1000
    scale_label <- "Kb"
  }
  
  # unit numbers
  label_unit_num <- nums_at
  
  # subunit numbers
  label_subunit_num <- seq(0, chr_length, by = subunit)
  
  label_subunit_num <- label_subunit_num[!label_subunit_num %in% label_unit_num] 
  
  # return
  list(label_unit_num, label_subunit_num, scaled_labels, scale_len, scale_label)
}

upsidedown <- function(pos, ymax, scale = 1) {
# upside down chromosome and corresponding coordinates
  newpos <- (ymax - pos) / scale
}

######################

######################
# file to store Pt regions
######################
nupt_region_out <- "2o-A188.NUPT.regions.txt"
cat("chr\tstart\tend\n", file = nupt_region_out)

######################
# plot
######################
par(mar = c(1, 2, 3, 2))
xlabel <- ""
ylabel <- "Physical positoin (Mb)"
mainlabel <- "NUPTs on A188Ref1"
min_ref_match <- 3000
min_qry_match <- 3000
min_identity <- 95
feature_closeup <- T
closeup_scale <- 800
closeup_dist <- 0.4 # distance from  original locations
two_cols <- c("darkseagreen4", "darkseagreen3")
line_adjust <- 0.1

# chromosome lengths
chrlen_file <- "/homes/liu3zhen/references/A188Ref1/genome/A188Ref1.length"

# nucmer file
nuc_file <- "/bulk/liu3zhen/research/A188Ref1/15-NUPT/1-nucmer/A188pt_Ref1.filt.txt"

# chrs
select_seqs <- 1:10
nseqs <- length(select_seqs)
xrange <- c(1, nseqs)

# chr chrlens
chrlens <- read.delim(chrlen_file, header = F)
# y-axis
ymax <-  max(chrlens[, 2])
yaxis_data <- smart.axis(ymax)
len_scale <- yaxis_data[[3]]  # length scale, e.g., 1000000

yrange <- c(0, max(chrlens[, 2]))

# nucmer alignment (show-coords -T -H output)
nuc_aln <- read.delim(nuc_file, header = F)
colnames(nuc_aln) <- c("refstart", "refend", "qrystart", "qryend",
                       "reflen", "qrylen", "identity", "ref", "qry")

# filter alignment
nuc_pass_aln <- nuc_aln[nuc_aln$ref %in% select_seqs &
                        nuc_aln$reflen >= min_ref_match &
                        nuc_aln$qrylen >= min_qry_match &
                        nuc_aln$identity >= min_identity, ]
head(nuc_pass_aln)

# plot

pdf("2o-NUPTs_A188Ref1.pdf", width=8, height=5, useDingbats=F)

plot(NULL, NULL, xlim = xrange, ylim = yrange,
     xlab = xlabel, ylab = ylabel, main = mainlabel,
     xaxt = "n", yaxt = "n", bty = "n")

# y-axis
axis(2, at = ymax - yaxis_data[[1]], labels = yaxis_data[[3]], lwd = 1)
axis(2, at = ymax - yaxis_data[[2]], labels = F, lwd = 0.2)

# plot each chromosome
for (i in 1:nseqs) {
  echr <- select_seqs[i] # each selected chromosome
  echrlen <- chrlens[chrlens[, 1] == echr, 2]
  # chromosome
  lines(c(i, i), c(ymax - echrlen, ymax), lwd = 10, lend = 0, col = "gray80", xpd = T)
  text(i, ymax, pos = 3, labels = echr, xpd = T, cex = 1.2)
  
  # alignments
  echr_aln <- nuc_pass_aln[nuc_pass_aln$ref == echr, ]
  
  if (nrow(echr_aln) > 0) {
    previous_pos <- 0
    #closeup_new_pos <- echr_aln$refstart[1] - 1
    for (j in 1:nrow(echr_aln)) {
      y_start <- echr_aln$refstart[j]
      y_end <- echr_aln$refend[j]
      lines(c(i, i), c(ymax - y_start, ymax - y_end), col=two_cols[1], lwd = 10)
      
      # alignment closeup
      if (feature_closeup) {
        select_col <- two_cols[j %% 2 + 1]
        
        if (previous_pos == 0) {
          closeup_new_pos <- y_start - 1
        }
        
        if ((y_start - previous_pos) > 100000 & previous_pos != 0) {
          # draw insertion lines
          y_basepos <- ymax - closeup_new_pos
          lines(c(i + line_adjust, i + closeup_dist - line_adjust), c(y_basepos, y_basepos), col = two_cols[2])
          lines(c(i + line_adjust, i + closeup_dist - line_adjust),
                c(y_basepos, y_basepos - (previous_pos - closeup_new_pos) * closeup_scale), col = two_cols[2])
          # output regions
          cat(echr, closeup_new_pos, previous_pos, sep = "\t", file = nupt_region_out, append = T)
          cat("\n", file = nupt_region_out, append = T)
          closeup_new_pos <- y_start - 1
        }
        previous_pos <- y_end
        y_closeup.start <- ymax - closeup_new_pos - (y_start - closeup_new_pos) * closeup_scale
        y_closeup.end <- ymax - closeup_new_pos - (y_end - closeup_new_pos) * closeup_scale
        lines(c(i + closeup_dist, i + closeup_dist), c(y_closeup.end, y_closeup.start), lwd = 8, lend = 1, col = select_col, xpd = T)
      }
    }
    # last region
    y_basepos <- ymax - closeup_new_pos
    lines(c(i + line_adjust, i + closeup_dist - line_adjust), c(y_basepos, y_basepos), col = two_cols[2])
    lines(c(i + line_adjust, i + closeup_dist - line_adjust),
          c(y_basepos, y_basepos - (previous_pos - closeup_new_pos) * closeup_scale), col = two_cols[2])
    cat(echr, closeup_new_pos, previous_pos, sep = "\t", file = nupt_region_out, append = T)
    cat("\n", file = nupt_region_out, append = T)
  }
}

# 10kb block

block <- 10000
block_pos <- 280000000
lines(c(9, 9), c(ymax - block_pos - block * closeup_scale, ymax - block_pos),
      lwd = 8, lend = 1, col = two_cols[2])
lines(c(9.2, 9.2), c(ymax - block_pos - block * closeup_scale, ymax - block_pos),
      lwd = 8, lend = 1, col = two_cols[1])
text(9.2, ymax - block_pos - block * closeup_scale / 2, pos=4, labels = paste(block / 1000, "kb"))


# legends
#legend_labels <- c("NUPT")
#legend_shapes <- c(16)
#legend_colors <- c("darkseagreen4")
#legend("bottomright", bty = "n", legend = legend_labels, col = legend_colors, pch = legend_shapes)

dev.off()

