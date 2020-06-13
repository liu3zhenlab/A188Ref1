setwd("/bulk/liu3zhen/research/A188Ref1/20-orthologs/4-para_compare")

para <- read.delim("../3-ortho_parse/A188Ref1a1.paralogs", stringsAsFactors = F)
head(para)
para <- para[, 3:4]
rec <- read.delim("~/references/A188Ref1/function/A188Ref1a1.confident.genes.recombination", stringsAsFactors = F)
head(rec)

paraRec <- merge(para, rec[, c(1, 10, 11)], by.x = "Para1", by.y = "Gene")
colnames(paraRec) <- c("Para1", "Para2", "Para1_rec", "Para1_recgroup")
paraRec <- merge(paraRec, rec[, c(1, 10, 11)], by.x = "Para2", by.y = "Gene")
colnames(paraRec) <- c("Para2", "Para1", "Para1_rec", "Para1_recgroup", "Para2_rec", "Para2_recgroup")
paraRec <- paraRec[, c("Para1", "Para2", "Para1_rec", "Para1_recgroup", "Para2_rec", "Para2_recgroup")]
head(paraRec)

# constracting recombination 
para_contrast <- paraRec[(paraRec$Para1_recgroup == "L" & grepl("H", paraRec$Para2_recgroup)) |
                         (paraRec$Para2_recgroup == "L" & grepl("H", paraRec$Para1_recgroup)), ]
nrow(para_contrast)
write.table(para_contrast, "1o-para.L.H.recombination.list", row.names = F, quote = F, sep = "\t")

# high-REC
para1_H <- para_contrast[grepl("H", para_contrast$Para1_recgroup), "Para1"]
para2_H <- para_contrast[grepl("H", para_contrast$Para2_recgroup), "Para2"]
paraH <- data.frame(c(para1_H, para2_H), row.names = NULL)
write.table(paraH, "1o-para.H.list", row.names = F, col.names = F, quote = F, sep = "\t")

# high-REC
para1_L <- para_contrast[para_contrast$Para1_recgroup == "L", "Para1"]
para2_L <- para_contrast[para_contrast$Para2_recgroup == "L", "Para2"]
paraL <- data.frame(c(para1_L, para2_L), row.names = NULL)
write.table(paraL, "1o-para.L.list", row.names = F, col.names = F, quote = F, sep = "\t")


