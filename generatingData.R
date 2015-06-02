library(stringr)
library(data.table)
library(gdata)
library(sqldf)
library(RMySQL)
library(parallel)
#library(RPostgreSQL)
#library(dplyr)
#library(tidyr)
#library(shiny)

# working directory
(WD <- "/home/js/it/imid/ngs/data/")
if (!is.null(WD)) setwd(WD)
tempDir <- "temp/"
 
# ścieżka do plików VCF (podstawowych)
inputDir <- "input/TSO"
inputFile <- dir(inputDir, "*.vcf", full.names = F)

# ścieżka do plików zadnotowanych (w programie annovar)
multiannoVarsDir <- "outputMultiannoFiles"
multiannoVarsFile <- dir(multiannoVarsDir, "*hg19_multianno.txt", full.names = T)

### funkcja pobierania identyfikatora próbki
getSampleID <- function(multiannoVarsFile){
  sID <- strsplit(dir(multiannoVarsDir, "*hg19_multianno.txt", full.names=F), "_")[[i]][1]
  sID
}

# ramki danych
for (i in 1:length(multiannoVarsFile)) {
  vars <- as.data.table(NULL)
  vars <- read.table(multiannoVarsFile[i], sep = "\t", stringsAsFactors = F, header = T, fill = T) # sep b. ważny!!!
  sID <- getSampleID(multiannoVarsFile[i])
  vars[,"V72"] <- sID
  #tempTab = tempTab[,c(11:12,1:2,4,5:6,3,7,10,8)]
  #colnames(tempTab) <- c("SAMPLE_ID", "VAR_KEY", "CHROM", "POS", "REF", "ALT", "QUAL", "dbSNP_ID", "FILTER", "GT:AD:DP:GQ:PL:MQ:GQX:VF" ,"INFO")
  
  allVarsTab <- write.table(vars, file = "allVariants.tsv", append = T, dec = ".", sep="\t", row.names = F, col.names = F)
  #write.table(vars, file = (paste0(tempDir, sID, ".tsv", collapse="")), append=F, sep="\t", eol="\r\n", na="NA", dec=".", row.names=F, col.names=T)
}

rt <- read.table(file = "/home/js/it/imid/ngs/data/allVariants.tsv")
colnames(rt) <- c(names(vars))

### dane do tabeli "var_sample"
var_sampleTab <- data.table(rt[,c(72,71)])
#colnames(var_sampleTab) <- c("sampleID", "variantID") #lepiej użyć "setnames"
setnames(var_sampleTab,"V72","sampleID")
setnames(var_sampleTab,"key","variantID")

### VariantsDB: baza danych w MySQL
con <- dbConnect(MySQL(), user="root", password="root", dbname="VariantsDB", host="localhost")
### tabela "var_sample"
dbSendQuery(con, 
    "CREATE TABLE IF NOT EXISTS `VariantsDB`.`var_sample` (
    `var_sampleID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `sampleID` INT NOT NULL,
    `variantID` NVARCHAR NOT NULL)
    ENGINE = InnoDB")
dbDisconnect(con)

dbWriteTable(con, "var_sample", var_sampleTab , row.name=F, append=T)
samD <- dbReadTable(con, "TEMP_ALL_VARS")
