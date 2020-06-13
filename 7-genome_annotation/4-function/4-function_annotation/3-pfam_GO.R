pfam <- read.delim("../1-interproscan/1o-confident.prot.interproscan.pfam", header = F)
# header information can be found https://github.com/ebi-pf-team/interproscan/wiki/OutputFormats
pfam <- pfam[, c(1, 5, 6, 9, 14)]
colnames(pfam) <- c("Transcript", "Pfam", "Pfam_description", "Evalue", "GO")
pfam$Gene <- gsub("_T.*", "", pfam$Transcript)

# build gene pfam table
gene_pfam <- paste(pfam$Gene, pfam$Pfam)
pfam2 <- pfam[!duplicated(gene_pfam), ] # remove redundancy:
pfam_out <- pfam2[, c("Gene", "Pfam", "Pfam_description", "Evalue")]
# output
write.table(pfam_out, "A188Ref1a1.confident.Pfam", quote = F, row.names = F, sep = "\t")

# GO
go_out0 <- pfam[pfam$GO != "", c("Gene", "GO")]
gosplit <- strsplit(as.character(go_out0$GO), "\\|") # split GOs
genefreq <- sapply(gosplit, length) # count number of GO per line
go_out <- data.frame(Gene = rep(go_out0$Gene, genefreq),
                     GO = unlist(gosplit))
go_out <- go_out[!duplicated(paste(go_out$Gene, go_out$GO)), ] # remove redundancy
go_out <- go_out[order(go_out$Gene, go_out$GO), ] # order by genes then GO
# output
write.table(go_out, "A188Ref1a1.confident.GO", quote = F, row.names = F, sep = "\t")


