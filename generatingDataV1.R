library(stringr)
library(data.table)
library(gdata)
library(sqldf)
library(RMySQL)
#library(RPostgreSQL)
#library(dplyr)
#library(tidyr)
#library(shiny)

# working directory
(WD <- "/home/js/it/imid/ngs/data")
if (!is.null(WD)) setwd(WD)
tempDir <- "temp"
 
#ścieżka do plików VCF (podstawowych)
inputDir <- "input/TSO"
inputFile <- dir(inputDir, "*.vcf", full.names = F)

#ścieżka do plików zadnotowanych (annovar)
multiannoVarsDir <- "outputMultiannoFiles/"
multiannoVarsFile <- dir(multiannoVarsDir, "*hg19_multianno.txt", full.names = T)

# VariantsDB_1 : baza danych w MySQL - baza wcześniej stworzona !!! wersja prostsza

con <- dbConnect(MySQL(), user="root", password="root", dbname="VariantsDB_1", host="localhost")
for (i in 1:length(multiannoVarsFile)) {
  tempTab = as.data.table(NULL)
  tempTab = read.table(multiannoVarsFile[i], sep = "\t", stringsAsFactors = FALSE, header = T, fill = T) # sep b. ważny!!!
  tempTab["V72"] <- strsplit((dir(multiannoVarsDir, "*hg19_multianno.txt", full.names = F)), "_")[[i]][1] # SampleID w [[]]
  
  #tempTab = tempTab[,c(11:12,1:2,4,5:6,3,7,10,8)]
  #colnames(tempTab) <- c("SAMPLE_ID", "VAR_KEY", "CHROM", "POS", "REF", "ALT", "QUAL", "dbSNP_ID", "FILTER", "GT:AD:DP:GQ:PL:MQ:GQX:VF" ,"INFO")
  #tempTab <- separate(tempTab, "GT:AD:DP:GQ:PL:MQ:GQX:VF", c("GT","AD","DP","GQ","PL","MQ","GQX","VF") , remove = T, sep = ":" ) #błąd
  #write.table(tempTab, file = (paste0(tempDir, SampleID[i], collapse = "")), append = F)
  
  #insert data into VariantsDB_1
  dbWriteTable(con, "TEMP_ALL_VARS", tempTab, row.name=F, append=T)
  #samD <- dbReadTable(con, "TEMP_ALL_VARS")
  #write.table(x = tempTab, file = (paste0(tempDir,"VarsAll_54_TSO.csv")), sep = "\t", append = T, na = ".", quote = F, dec = ".", row.names = F, col.names = T)
}
dbDisconnect(con)
