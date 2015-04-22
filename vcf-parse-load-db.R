library(stringr)
library(data.table)
library(gdata)
library(sqldf)
library(RMySQL)
library(dplyr)
library(tidyr)

#sciezki do folderów i plikow
inputDir <- "/home/js/it/imid/ngs/data/vcf/input"
inputFiles <- dir(inputDir, "*.vcf", full.names = TRUE)
tempDir <- "/home/js/it/imid/ngs/data/vcf/temp/"

# lista SampleID
SampleID <- c(as.character(substr((dir(inputDir, "*.vcf", full.names = FALSE)), 1, 5))) #dopracowac!!

# All Variants without annotations, loading into database
# problematyczna kolumna INFO
con <- dbConnect(MySQL(), user="root", password="root",dbname="MiSeqVarsDB", host="localhost")
for (i in 1:length(inputFiles)) {
  tempTab = as.data.table(NULL)
  tempTab = read.table(inputFiles[i], stringsAsFactors = FALSE, comment.char = "#", header = FALSE, fill = T)
  tempTab["V11"] <- SampleID[i]
  tempTab["V12"] <- paste(tempTab$V1,":", tempTab$V2, "_" , tempTab$V4, ">" , tempTab$V5, sep="")
  tempTab = tempTab[,c(11:12,1:2,4,5:6,3,7,10,8)]
  colnames(tempTab) <- c("SAMPLE_ID", "VAR_KEY", "CHROM", "POS", "REF", "ALT", "QUAL", "dbSNP_ID", "FILTER", "GT:AD:DP:GQ:PL:MQ:GQX:VF" ,"INFO")
  #tempTab <- separate(tempTab, "GT:AD:DP:GQ:PL:MQ:GQX:VF", c("GT","AD","DP","GQ","PL","MQ","GQX","VF") , remove = T, sep = ":" ) #błąd
  #write.table(tempTab, file = (paste0(tempDir, SampleID[i], collapse = "")), append = F)
  
  #insert data into MiSeqVarsDB
  dbWriteTable(con, "TEMP_ALL_VARS", tempTab, row.name=F, append=T)
  samD <- dbReadTable(con, "TEMP_ALL_VARS")
  #write.table(x = tempTab, file = (paste0(tempDir,"VarsAll_54_TSO.csv")), sep = "\t", append = T, na = ".", quote = F, dec = ".", row.names = F, col.names = T)
}
dbDisconnect(con)
