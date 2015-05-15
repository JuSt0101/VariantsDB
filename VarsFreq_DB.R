library(stringr)
library(data.table)
library(gdata)
library(sqldf)
library(RMySQL)
library(dplyr)
library(tidyr)

#sciezki do folderów i plikow
inputDir <- "/home/mongos/NGS/data/output/ANNOVAR_output"
inputFiles <- dir(inputDir, "*.avoutput.hg19_multianno.txt", full.names = T)

# lista SampleID
#vars$Identifier <- strsplit(inputFile, "_")[[1]][1]
SampleID <- c(as.character(substr((dir(inputDir, "avoutput.hg19_multianno.txt", full.names = F)), 1, 5))) #dopracowac!!

## kolumny
> names(tempTab)
[1] "Chr"                     "Start"                   "End"                     "Ref"                     "Alt"                    
[6] "Func.refGene"            "Gene.refGene"            "GeneDetail.refGene"      "ExonicFunc.refGene"      "AAChange.refGene"       
[11] "Func.knownGene"          "Gene.knownGene"          "GeneDetail.knownGene"    "ExonicFunc.knownGene"    "AAChange.knownGene"     
[16] "Func.ensGene"            "Gene.ensGene"            "GeneDetail.ensGene"      "ExonicFunc.ensGene"      "AAChange.ensGene"       
[21] "cytoBand"                "SIFT_score"              "SIFT_pred"               "Polyphen2_HDIV_score"    "Polyphen2_HDIV_pred"    
[26] "Polyphen2_HVAR_score"    "Polyphen2_HVAR_pred"     "LRT_score"               "LRT_pred"                "MutationTaster_score"   
[31] "MutationTaster_pred"     "MutationAssessor_score"  "MutationAssessor_pred"   "FATHMM_score"            "FATHMM_pred"            
[36] "RadialSVM_score"         "RadialSVM_pred"          "LR_score"                "LR_pred"                 "VEST3_score"            
[41] "CADD_raw"                "CADD_phred"              "GERP.._RS"               "phyloP46way_placental"   "phyloP100way_vertebrate"
[46] "SiPhy_29way_logOdds"     "esp6500si_all"           "ExAC_ALL"                "ExAC_AFR"                "ExAC_AMR"               
[51] "ExAC_EAS"                "ExAC_FIN"                "ExAC_NFE"                "ExAC_OTH"                "ExAC_SAS"               
[56] "X1000g2014oct_eur"       "clinvar_20150330"        "Zyg"                     "QUAL"                    "DP"                     
[61] "V1"                      "V2"                      "V3"                      "V4"                      "V5"                     
[66] "V6"                      "V7"                      "V8"                      "V9"                      "V10"                    
[71] "key" 

con <- dbConnect(MySQL(), user="root", password="xxx",dbname="VarsFreq_temp", host="localhost")
for (i in 1:length(inputFiles)) {
  tempTab = as.data.table(NULL)
  tempTab = read.table(inputFiles[1], stringsAsFactors = F, header = T, fill = T, sep = "\t")
  tempTab["V72"] <- SampleID[1]
  
  VarsFreqTab = tempTab[,c(72,71,67,58,1)]
  colnames(VarsFreqTab) <- c("SAMPLE_ID", "VAR_KEY", "FILTER", "ZYG", "CHROM")
  
  #insert data into DB
  dbWriteTable(con, "TEMP_ALL_VARS", tempTab, row.name=F, append=T)
  sampleDB <- dbReadTable(con, "TEMP_ALL_VARS")
  #write.table(x = tempTab, file = (paste0(tempDir,"VarsAll_54_TSO.csv")), sep = "\t", append = T, na = ".", quote = F, dec = ".", row.names = F, col.names = T)
}
dbDisconnect(con)
