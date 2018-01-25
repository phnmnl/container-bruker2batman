#!/usr/bin/Rscript

## import optparse library
suppressPackageStartupMessages(library("optparse"))

## specify our desired options in a list
## by default OptionParser will add an help option equivalent to
## make_option(c("-h", "--help"), action="store_true", default=FALSE,
## help="Show this help message and exit")
option_list <- list(
  make_option(c("-i", "--inputData"), 
              help="Full path to the input zipped Bruker file, required.")
)

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults,
parser <- OptionParser(option_list=option_list)
opt <- parse_args(parser)

datapath<-opt$inputData

## read in bruker spectra
## find the data files
ppm <- NULL
swp <- NULL #for checking the necessary for interpolation. Added by J Gao.
pfile <-list.files(path = datapath, pattern = "^procs$", all.files = FALSE,full.names = TRUE, recursive = TRUE, ignore.case = TRUE)
rfile <-list.files(path = datapath, pattern = "^1r$", all.files = FALSE,full.names = TRUE, recursive = TRUE, ignore.case = TRUE)

ps <- substr(pfile, 1, nchar(pfile)-5)
rs <- substr(rfile, 1, nchar(rfile)-2)

if (length(setdiff(rs,ps)) == 0 & length(setdiff(ps,rs)) > 0)
{
	pfile <- paste(rs,"procs",sep = "")
} 

L<-length(pfile)
Lr<-length(rfile)
sa <- NULL
snam <- NULL
if (L==0 || Lr==0 || L!=Lr)
{   
	return (cat("Bruker file does not exist in datapath, or other problems with bruker files...\n"))
} else {
for (i in 1:L)
{    
  con  <- file(pfile[i], open = "r")
  aLine <- readLines(con, n = -1, warn = FALSE)
  myV <- strsplit(aLine, "=")    
  close(con)
  
  ftsize <- 70000
  for (j in 1:length(myV))
  {
	if (match("##$OFFSET",myV[[j]][1],nomatch = 0))
	{    offset <- as.numeric(myV[[j]][2])
	}
	if (match("##$SW_p",myV[[j]][1],nomatch = 0))
	{    sw <- as.numeric(myV[[j]][2])
	}
	if (match("##$SF",myV[[j]][1],nomatch = 0))
	{
	  sf <- as.numeric(myV[[j]][2])
	}
	if (match("##$SI",myV[[j]][1],nomatch = 0))
	{  
	  si <- as.numeric(myV[[j]][2])
	}
	if (match("##$BYTORDP",myV[[j]][1],nomatch = 0))
	{    bytordp <- as.numeric(myV[[j]][2])
	}
	if (match("##$NC_proc",myV[[j]][1],nomatch = 0))
	{
	  ncproc <- as.numeric(myV[[j]][2])
	}
	if (match("##$FTSIZE",myV[[j]][1],nomatch = 0))
	{
	  ftsize <- as.numeric(myV[[j]][2])
	}
  }
  
  if (bytordp==0){machine_format =  "little"}
  else {machine_format = "big"}
  #read NMR resonance data
  s<-readBin(rfile[i], what="int",n = ftsize, size = 4, signed = T, endian =machine_format)
  s<- ((2^ncproc)* s)
  nspec <- length(s)
  
  tmpppm <- ppm
  tmpswp <- swp  #for checking if necessary to do interpolation. Added by J Gao.
  
  swp <- sw/sf
  dppm <- swp/(nspec-1)
  ppm<-offset
  ppm<-seq(offset,(offset-swp),by=-dppm)

  ## interpolation
  if (!is.null(tmpppm))
  {
	if ((tmpppm[1] != ppm[1]) || tmpswp != swp || length(tmpppm) != length(ppm))
	{
	  sinter <- approx(ppm, s, xout = tmpppm)
	  s <- sinter$y
	  s[is.na(s)]<-0
	  ppm <- tmpppm
	  swp <- tmpswp #Added for checking if necessary to do interpolation. by J Gao.
	}
  }
  
  sa<- cbind(sa,s)
  ## find corresponding title
  stitle<-paste(substr(rfile[i],1,nchar(rfile[i])-2),"title",sep="")
  if (!file.exists(stitle))
	stitle<-paste(substr(rfile[i],1,nchar(rfile[i])-2),"TITLE",sep="")
  if (file.exists(stitle))
  {
	if (!file.info(stitle)$size == 0)
	{
	  con<-file(stitle,open="r")
	  ntem <- readLines(con, n = 1, warn = FALSE)
	  close(con)
	} else {
	  sT <- strsplit(rfile[i], "/")
	  sTitle <-sT[[1]]         
	  lsT<-length(sTitle)
	  if (lsT>4)
		ntem<-paste(sTitle[lsT-4],"_",sTitle[lsT-3],"_",sTitle[lsT-1],sep="")
	  else if (lsT>3)
		ntem<-paste(sTitle[lsT-3],"_",sTitle[lsT-1],sep="")
	  else if (lsT>=1)
		ntem<-paste(sTitle[lsT-1],sep="")
	  else
		ntem<-i
	}
  } else {
	sT <- strsplit(rfile[i], "/")
	sTitle <-sT[[1]]         
	lsT<-length(sTitle)
	if (lsT>4)
	  ntem<-paste(sTitle[lsT-4],"_",sTitle[lsT-3],"_",sTitle[lsT-1],sep="")
	else if (lsT>3)
	  ntem<-paste(sTitle[lsT-3],"_",sTitle[lsT-1],sep="")
	else if (lsT>=1)
	  ntem<-paste(sTitle[lsT-1],sep="")
	else
	  ntem<-i
  }
  snam<- cbind(snam, ntem)            
}
}
snam <- cbind("ppm", snam)
sa <- cbind(ppm,sa)
colnames(sa)<- snam

#write to txt file
write.table(sa,file="NMRdata_from_Bruker",row.names=FALSE,col.names=TRUE,quote=FALSE,sep = "\t")