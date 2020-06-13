blp <- read.delim("../2-blastp/1o-confident.prot.blastp", header = F, stringsAsFactors = F)
primary <- read.delim("../3-primaryTranscripts/A188Ref1a1.confident.primary.transcripts.txt", stringsAsFactors = F)
blp <- blp[blp$V1 %in% primary$Transcript, ]
blp$Gene <- gsub("_T.*", "", blp$V1)
blp <- blp[order(blp$Gene, blp$V10), ]

blp$Description <- gsub(" OS=.*", "", blp$V9)
blp$Symbol <- ""
blp$Symbol[grep("GN=", blp$V9)] <- blp$V9[grep("GN=", blp$V9)]
blp$Symbol <- gsub(".*GN=", "", blp$Symbol)
blp$Symbol <- gsub(" PE=.*", "", blp$Symbol)
blp$Evalue <- blp$V10
#hist(-log10(blp$V10), nclass=100)

colnames(blp)
blp2 <- blp[, c("Gene", "V1", "Symbol", "Description", "Evalue")]
colnames(blp2) <- c("Gene", "Primary_transcript", "Symbol", "Description", "SwissProt_evalue")

# output:
write.table(blp2, "A188Ref1a1.confident.description", row.names = F, quote = F, sep = "\t")
