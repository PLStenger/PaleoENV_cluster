#!/bin/bash


# trimmomatic version 0.39
# trimmomatic manual : http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf

############################################################################################################################################
# trnL
############################################################################################################################################

WORKING_DIRECTORY=/scratch_vol0/fungi/PaleoENV_cluster/01_raw_data/TrnL/trnLgh/
OUTPUT=/scratch_vol0/fungi/PaleoENV_cluster/03_cleaned_data/trnL

# Make the directory (mkdir) only if not existe already(-p)
mkdir -p $OUTPUT

ADAPTERFILE=/scratch_vol0/fungi/PaleoENV_cluster/99_softwares/adapters_sequences.fasta

# Arguments :
# ILLUMINACLIP:"$ADAPTERFILE":2:30:10 LEADING:30 TRAILING:30 SLIDINGWINDOW:26:30 MINLEN:150

eval "$(conda shell.bash hook)"
conda activate trimmomatic

cd $WORKING_DIRECTORY

####################################################
# Cleaning step
####################################################

for R1 in *R1*
do
   R2=${R1//R1.fastq.gz/R2.fastq.gz}
   R1paired=${R1//.fastq.gz/_paired.fastq.gz}
   R1unpaired=${R1//.fastq.gz/_unpaired.fastq.gz}	
   R2paired=${R2//.fastq.gz/_paired.fastq.gz}
   R2unpaired=${R2//.fastq.gz/_unpaired.fastq.gz}	

   trimmomatic PE -Xmx60G -threads 8 -phred33 $R1 $R2 $OUTPUT/$R1paired $OUTPUT/$R1unpaired $OUTPUT/$R2paired $OUTPUT/$R2unpaired ILLUMINACLIP:"$ADAPTERFILE":2:30:10 LEADING:30 TRAILING:30 SLIDINGWINDOW:26:30 MINLEN:150

done ;


## ############################################################################################################################################
## # ITS2
## ############################################################################################################################################
## 
## WORKING_DIRECTORY=/scratch_vol0/fungi/PaleoENV_cluster/01_raw_data/ITS2/ITS2
## OUTPUT=/scratch_vol0/fungi/PaleoENV_cluster/03_cleaned_data/ITS2
## 
## # Make the directory (mkdir) only if not existe already(-p)
## mkdir -p $OUTPUT
## 
## ADAPTERFILE=/scratch_vol0/fungi/PaleoENV_cluster/99_softwares/adapters_sequences.fasta
## 
## # Arguments :
## # ILLUMINACLIP:"$ADAPTERFILE":2:30:10 LEADING:30 TRAILING:30 SLIDINGWINDOW:26:30 MINLEN:150
## 
## eval "$(conda shell.bash hook)"
## conda activate trimmomatic
## 
## cd $WORKING_DIRECTORY
## 
## ####################################################
## # Cleaning step
## ####################################################
## 
## for R1 in *R1*
## do
##    R2=${R1//R1.fastq.gz/R2.fastq.gz}
##    R1paired=${R1//.fastq.gz/_paired.fastq.gz}
##    R1unpaired=${R1//.fastq.gz/_unpaired.fastq.gz}	
##    R2paired=${R2//.fastq.gz/_paired.fastq.gz}
##    R2unpaired=${R2//.fastq.gz/_unpaired.fastq.gz}	
## 
##    trimmomatic PE -Xmx60G -threads 8 -phred33 $R1 $R2 $OUTPUT/$R1paired $OUTPUT/$R1unpaired $OUTPUT/$R2paired $OUTPUT/$R2unpaired ILLUMINACLIP:"$ADAPTERFILE":2:30:10 LEADING:30 TRAILING:30 SLIDINGWINDOW:26:30 MINLEN:150
## 
## done ;
