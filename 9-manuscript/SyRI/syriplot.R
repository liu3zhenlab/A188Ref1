#####################################################################################
#' module to determine xaxis
#####################################################################################
smart.axis <- function(maxnum) {
  numdigits <- nchar(maxnum)
  unit <- 10 ^ (numdigits - 1) / (2- round((maxnum / 10 ^ numdigits), 0)) # 1 or 5 e (numdigits - 1)
  subunit <- unit / 5
  
  numsat <- unit * (0:10)
  numsat <- numsat[numsat < maxnum]
  
  if (unit >= 6) {
    numlabels <- numsat / 1000000
    label.scale <- "Mb"
  } else if (numdigits < 6) {
    numlabels <- unit / 1000
    label.scale <- "Kb"
  }
  
  subunits <- seq(0, maxnum, by = subunit)
  subunits <- subunits[!subunits %in% c(numsat, 0)]
  # return
  list(numsat, numlabels, label.scale, subunits)
}

#########################################################################################
#'@param syriout SyRI output, required
#'@param chr name of select chromosome,required
#'@param ref.chrlen bp length of the select ref chromosome, required
#'@param qry.chrlen bp length of the select qry chromosome, required
#'@param ref.name name of ref genome, required
#'@param qry.name name of qry genome, required
#'@param chr.highlight.bed bed file (six columns) with no header (NULL)
#'1. chr 2. start 3. end 4. feature 5. color 6. height
#'@param min.syn.size minimum length of syntenic blocks to be plotted (10000)
#'  either ref or qry block larger than min.syn.size will be plotted
#'@param min.others.size minimum length of other blocks to be plotted (50000)
#'  either ref or qry block larger than min.syn.size will be plotted
#'@param xleft x-axis position of start of chromosomes on the canvas (0)
#'@param xright x-axis position of end of chromosomes on the canvas(1)
#'@param ref.ypos y-axis position of ref chromosome on the canvas (0.1)
#'@param qry.ypos y-axis position of qry chromosome on the canvas (0.8)
#'@param chr.col chromosome background color ("gray80")
#'@param main main text (NULL)
#'@param main.pos text coordinates (x, y) and a value (1, 2, 3, 4) to pass to "pos" to specify (below, left, above, right)
#'@param add2existingplot logic value to specify whether drawing is added to an existing plot
#'@param text.add logic value to specify wheather to add genome text (TRUE)
#'@param text.yadj.value value to adjust genome texts (up on top and down on bottom) (0.08)
#'@param text.col color for chromosome text ("palevioletred4")
#'@param legend.add logic value to indicate whether to add legend (TRUE)
#'@param outpdf logic value to indicate whether a PDF will be output (FALSE)
#'@param outfile filename including path for the PDF output (NULL)
#'@param pdfwidth inch of width of output PDF figure (6)
#'@param pdfheight inch of height of output PDF figure (3.5)
#'@method sv types: synteny, duplication, translocation, inversion
#' synteny=SYN; duplication=DUP+INVDP; translocation=TRANS+INVTR; inversion=TDM
#'@author Sanzhen Liu, liu3zhen@gmail.com
#'@description 
#'@example 
#'@return
#'
syriplot <- function(syriout, ref.chrlen, qry.chrlen, chr, ref.name, qry.name,
                     ref.chr.highlight.bed=NULL, qry.chr.highlight.bed=NULL,
                     min.syn.size=10000, min.notal.hdr.size=10000, min.others.size=50000,
                     xleft=0, xright=1, ref.ypos=0.1, qry.ypos=0.8, chr.col="gray80",
                     main=NULL, main.pos=NULL, add2existingplot=F,
                     text.add=T, text.yadj.value=0.08, text.col="palevioletred4",
                     legend.add=T, legend.x=0.5, legend.y=1,
                     outpdf=F, outfile=NULL, pdfwidth=6, pdfheight=3) {
  
  if (outpdf) {
    pdf(outfile, width=pdfwidth, height=pdfheight)
    stopifnot(!is.null(outfile))
  }
  
  ### read data
  syri <- read.delim(syriout, header=F, comment.char="#", stringsAsFactors=F)

  # canvasas (0, 1)
  par(mar=c(2, 0, 0, 0))
  
  # plot xrange and unit
  max.chrlen <- max(ref.chrlen, qry.chrlen)
  xaxtdata <- smart.axis(max.chrlen)
  x.unit <- max.chrlen / (xright - xleft)
  chr.height <- 1/20
    
  # coordinate conversion modules
  xpos.conversion <- function(pos) {
    pos / x.unit + xleft
  }
  
  #####################################################################################
  ### chromosome draw
  #####################################################################################
  chrdraw <- function(genome.name, chr, chrlen, ypos, height, chr.col,
                      text.add=T, text.yadj.value, text.col="palevioletred4") {
    rect(xpos.conversion(1), ypos-height/2,
         xpos.conversion(chrlen), ypos+height/2,
         col=chr.col, border=chr.col)
    #chrlen.mb <- round(chrlen / 1000000, 1)
    #chr.label <- paste0(genome.name, " ", chr, ":1-", chrlen.mb, " Mb")
    chr.label <- genome.name
    if (text.add) {
      text(0, ypos+text.yadj.value, labels=chr.label, pos=4, col=text.col)
    }
  }
  
  #####################################################################################
  #' syntenic link
  #####################################################################################
  syndraw <- function(alignment, ybottom, ytop, color="gray75") {
    # alignment is a vector with four column; first two from REF, 2nd two from QRY
    alignment <- as.numeric(as.character(alignment))
    alignment <- xpos.conversion(alignment)
	polygon(alignment[c(1,3,4,2)], c(ybottom, ytop, ytop, ybottom), border=NA, col=color)
  }
  
  ###############################################################################
  ### module to draw bands
  ###############################################################################
  bandconnect <- function(qryregion, refregion, ytop, ybottom, inversion=F,
                          border=NA, bandcol="brown") {
    ### module
    transform_curve <- function(startp, endp, npoint=1000) {
      ### computer transform_curve coordinates
      midp <- (startp + endp) / 2
      beizer_value <- sqrt(0:(npoint-1)) / sqrt(npoint-1)  # sqrt as default
      
      curve.x1 <- seq(startp[1], midp[1], by=(midp[1] - startp[1])/(npoint-1))
      curve.y1 <- startp[2] - beizer_value * (startp[2] - midp[2])
      
      curve.x2 <- rev(seq(endp[1], midp[1], by=(midp[1] - endp[1])/(npoint-1)))
      curve.y2 <- rev(endp[2] - beizer_value * (endp[2] - midp[2]))
      
      curve.x <- c(curve.x1, curve.x2)
      curve.y <- c(curve.y1, curve.y2)
      list(x=curve.x, y=curve.y)
    }
    
    if (inversion) {
      qryregion <- rev(qryregion)
    }
    
    p1 <- transform_curve(c(qryregion[1], ytop), c(refregion[1], ybottom))
    p2 <- transform_curve(c(qryregion[2], ytop), c(refregion[2], ybottom))
    px <- c(p1$x, rev(p2$x))
    py <- c(p1$y, rev(p2$y))
    #lines(px, py)
    polygon(px, py, border=border, col=bandcol)
  }
  
  ###############################################################################
  ### module to draw bands for a certain sv type
  ###############################################################################
  type.band.dram <- function(syridata, svtype, min.len, bandcol, ybottom, ytop, inversion=F) {
    syri.type <- syridata[syridata$Type==svtype &
                            (abs(syridata[, 2] - syrichr[, 1]) >= min.len | 
                               abs(syrichr[, 4]- syrichr[, 3]) >= min.len), ]
    if (nrow(syri.type) > 0) {
      for (i in 1:nrow(syri.type)) {
        bandconnect(qryregion=as.numeric(xpos.conversion(syri.type[i, 3:4])),
                    refregion=as.numeric(xpos.conversion(syri.type[i, 1:2])),
                    ybottom=ybottom, ytop=ytop, inversion=inversion,
                    border=bandcol, bandcol=bandcol)
      }
    }
  }
  
  ###############################################################################
  ### module to highlight chromosome segments
  ###############################################################################
  seghighlight <- function(syridata, chr, svtype, genome=c("ref","qry"), min.len=5000, color, ypos, height) {
    # module to highlight regions of certain sv types on chromosome
    rectplot <- function(two_coordinates, ybottom, ytop, ...) {
      ### module to plot rect
      rect(xpos.conversion(two_coordinates[1]), ybottom,
           xpos.conversion(two_coordinates[2]), ytop, ...)
    }
    
    stopifnot(genome=="ref" | genome=="qry")
    if (genome == "ref") {
      col0 <- 1; col1 <- 2; col2 <- 3
    } else {
      col0 <- 6; col1 <- 7; col2 <- 8
    }
    # subset
    syridata <- syridata[syridata[, 11]==svtype & syridata[, col0]==chr, ]
    syridata[, col1] <- as.numeric(as.character(syridata[, col1]))
    syridata[, col2] <- as.numeric(as.character(syridata[, col2]))
    syri.highlight <- syridata[abs(syridata[, col2] - syridata[, col1]) >= min.len, ]
    if (nrow(syri.highlight) > 0) {
      apply(syri.highlight[, col1:col2], 1, rectplot, ybottom=ypos-height/2, ytop=ypos+height/2,
            col=color, border=NA)
    }
  }
  
  ###############################################################################
  ### chromosome highlights
  ###############################################################################
  chr.add.highlight <- function(bed, chr, ypos) {
    features <- NULL
    feature.cols <- NULL
    feature.highlight <- read.delim(bed, header=F, comment.char="#", stringsAsFactors=F) # read bed file
    feature.highlight.chr <- feature.highlight[feature.highlight[,1]==chr, ]
    if (nrow(feature.highlight.chr) > 0) {
      for (i in 1:nrow(feature.highlight.chr)) {
        feature.highlight.pos <- xpos.conversion(as.numeric(feature.highlight.chr[i, 2:3]))
        feature.highlight.col <- feature.highlight.chr[i, 5]
        feature.highlight.height <- feature.highlight.chr[i, 6]
        # draw
        rect(feature.highlight.pos[1], ypos-feature.highlight.height/2,
             feature.highlight.pos[2], ypos+feature.highlight.height/2,
             border=feature.highlight.col, col=feature.highlight.col)
        if (sum(features %in% feature.highlight.chr[i, 4]) == 0) {
          features <- c(features, feature.highlight.chr[i, 4])
          feature.cols <- c(feature.cols, feature.highlight.col)
        }
      }
    }
    
    col.out <- NULL
    if (!is.null(feature.cols)) {
      col.out <- data.frame(feature=features, col=feature.cols)
    }
    col.out
  }
  
  ### color scheme
  band.types <- c("synteny", "duplication", "translocation", "inversion")
  band.cols <- c("gray75", "orchid4", "goldenrod3", "darkolivegreen4")
  names(band.cols) <- band.types
  
  chr.highlight <- c("NOTAL", "HDR")
  chr.highlight.cols <- c("royalblue4", "red")
  names(chr.highlight.cols) <- chr.highlight
  
  ########################################################################################
  ### plot canvas and labels
  ########################################################################################
  if (!add2existingplot) {
    plot(NULL, NULL, xlim=c(0,1), ylim=c(0,1), axes=F, ylab="", main="")
    if (is.null(main.pos)) {
      text((xleft + xright)/2, 1.02, pos=1, labels=main, cex=1.2, col=text.col)
    } else {
      text(main.pos[1], main.pos[2], pos=main.pos[3], labels=main, cex=1.2, col=text.col)
    }
  }
  ### xaxis
  xaxs.lines.at <- xpos.conversion(xaxtdata[[1]])
  axis(side=1, at=xaxs.lines.at, labels=xaxtdata[[2]])
  xaxs.lines.sub <- xpos.conversion(xaxtdata[[4]])
  abline(v=xaxs.lines.at, col="gray90", lwd=2)
  abline(v=xaxs.lines.sub, col="gray95", lwd=1)
  
  ### qry chromosome
  chrdraw(genome.name=qry.name, chr=chr, chrlen=qry.chrlen, ypos=qry.ypos, chr.col=chr.col,
          height=chr.height, text.add=text.add, text.yadj.value=text.yadj.value)
  
  ### ref chromosome
  chrdraw(genome.name=ref.name, chr=chr, chrlen=ref.chrlen, ypos=ref.ypos, chr.col=chr.col,
          height=chr.height, text.add=text.add, text.yadj.value=(-1*text.yadj.value))
  
  ### extract chr syri data
  syrichr <- syri[syri[, 1]==chr & syri[, 6]==chr, c(2,3,7,8,9,10,11,12)]
  colnames(syrichr) <- c("refS", "refE", "qryS", "qryE", "ID", "ParentID", "Type", "Copy")
  for (i in 1:4) {
    syrichr[, i] <- as.numeric(syrichr[, i])
  }
  
  ### base to draw connection bands
  qrybase <- qry.ypos-chr.height/2
  refbase <- ref.ypos+chr.height/2
  
  ### syntenic block
  syn <- syrichr[syrichr$Type=="SYN" &
                (abs(syrichr$refE - syrichr$refS) >= min.syn.size & 
                 abs(syrichr$qryE - syrichr$qryS) >= min.syn.size), ]
  stopifnot(nrow(syn)>0)
  # draw syn
  apply(syn[,1:4], 1, syndraw, ybottom=refbase, ytop=qrybase, color=band.cols["synteny"])
  
  ### duplication
  # type, minimum length, col
  type.band.dram(syridata=syrichr, svtype="DUP", min.len=min.others.size,
                 bandcol=band.cols["duplication"], ybottom=refbase, ytop=qrybase)
    
  ### inverted duplication
  type.band.dram(syridata=syrichr, svtype="INVDP", min.len=min.others.size,
                 bandcol=band.cols["duplication"], ybottom=refbase, ytop=qrybase)
  
  ### TRANS
  type.band.dram(syridata=syrichr, svtype="TRANS", min.len=min.others.size,
                 bandcol=band.cols["translocation"], ybottom=refbase, ytop=qrybase)
  
  ### INVTR
  type.band.dram(syridata=syrichr, svtype="INVTR", min.len=min.others.size,
                 bandcol=band.cols["translocation"], ybottom=refbase, ytop=qrybase)
  
  ### INV
  type.band.dram(syridata=syrichr, svtype="INV", min.len=min.others.size,
                 bandcol=band.cols["inversion"], ybottom=refbase, ytop=qrybase, inversion=T)
  
  ### NOTAL
  seghighlight(syridata=syri, chr=chr, svtype="NOTAL", genome="ref", min.len=min.notal.hdr.size,
               color=chr.highlight.cols["NOTAL"],ypos=ref.ypos, height=chr.height)
  seghighlight(syridata=syri, chr=chr, svtype="NOTAL", genome="qry", min.len=min.notal.hdr.size,
               color=chr.highlight.cols["NOTAL"],ypos=qry.ypos, height=chr.height) 
  ### HDR
  seghighlight(syridata=syri, chr=chr, svtype="HDR", genome="ref", min.len=min.notal.hdr.size,
               color=chr.highlight.cols["HDR"],ypos=ref.ypos, height=chr.height)
  seghighlight(syridata=syri, chr=chr, svtype="HDR", genome="qry", min.len=min.notal.hdr.size,
               color=chr.highlight.cols["HDR"],ypos=qry.ypos, height=chr.height) 
  
  ### chromosome highlight
  ref.highlight.legend <- NULL
  qry.highlight.legend <- NULL
  if (!is.null(ref.chr.highlight.bed)) {
    ref.highlight.legend <- chr.add.highlight(bed=ref.chr.highlight.bed, chr=chr, ypos=ref.ypos)
  }
  
  if (!is.null(qry.chr.highlight.bed)) {
    qry.highlight.legend <- chr.add.highlight(bed=qry.chr.highlight.bed, chr=chr, ypos=qry.ypos)
  }
  
  highlight.legends <- rbind(ref.highlight.legend, qry.highlight.legend)
  
  # stop if feature and color are conflicting
  #stopifnot(sum(duplicated(highlight.legends[,1]))==0 | sum(duplicated(highlight.legends[,2]))==0)
  
  ### legends
  # link bands (band.cols)
  if (legend.add) {
    legend(0.5, 1.02, legend=band.types, col=band.cols, lty=1, bty="n", lwd=3, ncol=2, xpd=T, cex=0.8)
    
    if (!is.null(highlight.legends)) {
	  highlight.legends <- highlight.legends[!duplicated(paste(highlight.legends[,1], highlight.legends[,2])), ]
	  chr.highlight <- c(chr.highlight, as.character(highlight.legends[,1]))
      chr.highlight.cols <- c(chr.highlight.cols, as.character(highlight.legends[,2]))
	}

    chr.highlight.text <- chr.highlight
	chr.highlight.text[chr.highlight.text=="NOTAL"] <- "unaligned"
	chr.highlight.text[chr.highlight.text=="HDR"] <- "divergent"
	legend(xleft, 1.02, legend=chr.highlight.text, col=chr.highlight.cols, bty="n",
           pch="|", pt.cex=1.2, ncol=2, xpd=T, cex=0.8)
  }
  
  ### pdf out
  if (outpdf) { dev.off() }
  
  ### return two values
  invisible(c(max.chrlen, x.unit, xleft))
}
