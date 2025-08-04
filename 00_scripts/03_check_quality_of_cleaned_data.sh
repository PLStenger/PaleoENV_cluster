#!/bin/bash


# installing FastQC from https://www.bioinformatics.babraham.ac.uk/projects/download.html
# FastQC v0.11.9 (Mac DMG image)

# Correct tool citation : Andrews, S. (2010). FastQC: a quality control tool for high throughput sequence data.

############################################################################################################################################
# trnL
############################################################################################################################################

WORKING_DIRECTORY=/scratch_vol0/fungi/PaleoENV_cluster/03_cleaned_data/trnL
OUTPUT=/scratch_vol0/fungi/PaleoENV_cluster/04_quality_check/trnL

# Make the directory (mkdir) only if not existe already(-p)
mkdir -p $OUTPUT

eval "$(conda shell.bash hook)"
conda activate fastqc

cd $WORKING_DIRECTORY

for FILE in $(ls $WORKING_DIRECTORY/*.fastq.gz)
do
      fastqc $FILE -o $OUTPUT
done ;

conda deactivate fastqc
conda activate multiqc

# Run multiqc for quality summary

multiqc $OUTPUT

############################################################################################################################################
# ITS2
############################################################################################################################################

WORKING_DIRECTORY=/scratch_vol0/fungi/PaleoENV_cluster/03_cleaned_data/ITS2
OUTPUT=/scratch_vol0/fungi/PaleoENV_cluster/04_quality_check/ITS2

# Make the directory (mkdir) only if not existe already(-p)
mkdir -p $OUTPUT

eval "$(conda shell.bash hook)"
conda activate fastqc

cd $WORKING_DIRECTORY

for FILE in $(ls $WORKING_DIRECTORY/*.fastq.gz)
do
      fastqc $FILE -o $OUTPUT
done ;

conda deactivate fastqc
conda activate multiqc

# Run multiqc for quality summary

multiqc $OUTPUT
