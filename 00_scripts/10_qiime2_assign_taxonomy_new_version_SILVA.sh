#!/bin/bash

###############################################################
### For ITS2
###############################################################

WORKING_DIRECTORY=/scratch_vol0/fungi/PaleoENV_cluster/05_QIIME2/ITS2
OUTPUT=/scratch_vol0/fungi/PaleoENV_cluster/05_QIIME2/ITS2/visual

DATABASE=/scratch_vol0/fungi/PaleoENV_cluster/98_database_files
TMPDIR=/scratch_vol0

#QIIME="singularity exec --cleanenv -B /scratch_vol0:/scratch_vol0 /scratch_vol0/fungi/qiime2_images/qiime2-2024.5.sif qiime"


# Aim: classify reads by taxon using a fitted classifier

# https://docs.qiime2.org/2019.10/tutorials/moving-pictures/
# In this step, you will take the denoised sequences from step 5 (rep-seqs.qza) and assign taxonomy to each sequence (phylum -> class -> …genus -> ). 
# This step requires a trained classifer. You have the choice of either training your own classifier using the q2-feature-classifier or downloading a pretrained classifier.

# https://docs.qiime2.org/2019.10/tutorials/feature-classifier/

cd $WORKING_DIRECTORY

eval "$(conda shell.bash hook)"
conda activate /scratch_vol0/fungi/envs/qiime2-amplicon-2024.10
#conda activate qiime2-2021.4

#export PYTHONPATH="${PYTHONPATH}:/scratch_vol0/fungi/.local/lib/python3.9/site-packages/"
#echo $PYTHONPATH

# I'm doing this step in order to deal the no space left in cluster :
export TMPDIR='/scratch_vol0/fungi'
echo $TMPDIR

# Make the directory (mkdir) only if not existe already(-p)
mkdir -p taxonomy/ITS2
mkdir -p export/taxonomy/ITS2

###############################################################################
## With a currated database:
## its2.global.2023-01-17.curated.tax.mc.add.fa
## from https://www.nature.com/articles/s41597-024-02962-5
#
## Importer le fasta comme FeatureData[Sequence]
#qiime tools import \
#  --input-path /scratch_vol0/fungi/PaleoENV_cluster/98_database_files/its2.global.2023-01-17.curated.tax.mc.add.UPPER.CLEAN.NOEMPTY_ok.fa \
#  --output-path ref-seqs.qza \
#  --type 'FeatureData[Sequence]'
#
## Importer la taxonomie comme FeatureData[Taxonomy]
#qiime tools import \
#  --input-path /scratch_vol0/fungi/PaleoENV_cluster/98_database_files/its2.global.2023-01-17.curated.tax.mc.add.taxo_clean.tsv \
#  --output-path ref-taxonomy.qza \
#  --type 'FeatureData[Taxonomy]' \
#  --input-format HeaderlessTSVTaxonomyFormat
#  
##  Entraîner le classifieur (Naive Bayes, meilleure robustesse)
#qiime feature-classifier fit-classifier-naive-bayes \
#  --i-reference-reads ref-seqs.qza \
#  --i-reference-taxonomy ref-taxonomy.qza \
#  --o-classifier its2-eu-plants-classifier.qza
#
#qiime feature-classifier classify-sklearn \
#  --i-classifier its2-eu-plants-classifier.qza \
#  --i-reads core/RepSeq.qza \
#  --o-classification core/taxonomy.qza
#
#qiime metadata tabulate --m-input-file core/taxonomy.qza --o-visualization core/taxonomy.qzv
#qiime tools export --input-path core/taxonomy.qzv --output-path /scratch_vol0/fungi/PaleoENV_cluster/05_QIIME2/ITS2/export/taxonomy/taxonomy_its2_global_2023-01-17_curated_tax

###############################################################################
# With a currated database:
# DB4Q2 workflow
# Plant ITS2 and rbcL reference databases
# https://figshare.com/articles/online_resource/QIIME2_RefDB_development_zip/17040680?file=56104238
# Database update - 1st July 2025
# NCBI_ITS2_Viridiplantae_fasta_file_2025_07_01.fasta/.qza
# from Duboi et al 2022: https://pmc.ncbi.nlm.nih.gov/articles/PMC9264521/pdf/12863_2022_Article_1067.pdf

#qiime tools import \
#  --type 'FeatureData[Sequence]' \
#  --input-path /scratch_vol0/fungi/PaleoENV_cluster/98_database_files/NCBI_ITS2_Viridiplantae_fasta_file_2025_07_01.fasta \
#  --output-path core/ref-seqs.qza

#qiime tools import \
#  --type 'FeatureData[Taxonomy]' \
#  --input-path /scratch_vol0/fungi/PaleoENV_cluster/98_database_files/NCBI_ITS2_Viridiplantae_taxonomic_lineages_2025_07_01.tsv \
#  --output-path core/ref-taxonomy.qza \
#  --input-format HeaderlessTSVTaxonomyFormat

qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads core/ref-seqs.qza \
  --i-reference-taxonomy core/ref-taxonomy.qza \
  --p-feature-ext-n-features 2048 \
  --o-classifier core/its2_db4q2_custom_classifier.qza

qiime feature-classifier classify-sklearn \
  --i-classifier core/its2_db4q2_custom_classifier.qza \
  --i-reads core/RepSeq.qza \
  --o-classification core/taxonomy.qza

qiime metadata tabulate \
  --m-input-file core/taxonomy.qza \
  --o-visualization core/taxonomy.qzv

qiime tools export \
  --input-path core/taxonomy.qzv \
  --output-path /scratch_vol0/fungi/PaleoENV_cluster/05_QIIME2/ITS2/export/taxonomy/db4q2_taxonomy_2025_07_01
  
###############################################################################

##  #   --p-query '(ITS2[ALL] OR Its2[ALL] OR its2[ALL] AND viridiplantae[ORGN] NOT bacteria[ORGN] NOT fungi[ORGN] NOT chloroplast[ALL] NOT mitochondrion[ALL]))' \
## 
## qiime rescript get-ncbi-data \
##     --p-query '(txid33090[ORGN] AND (ITS OR Internal Transcribed Spacer) NOT environmental sample[Title] NOT environmental samples[Title] NOT environmental[Title] NOT uncultured[Title] NOT unclassified[Title] NOT unidentified[Title] NOT unverified[Title])' \
##     --o-sequences taxonomy/RefTaxo.qza \
##     --o-taxonomy taxonomy/DataSeq.qza
## 
## 
## qiime feature-classifier classify-consensus-vsearch \
##     --i-query core/RepSeq.qza  \
##     --i-reference-reads taxonomy/RefTaxo.qza \
##     --i-reference-taxonomy taxonomy/DataSeq.qza \
##     --p-perc-identity 0.8 \
##     --p-query-cov 0.3 \
##     --p-top-hits-only \
##     --p-maxaccepts 5 \
##     --p-strand 'both' \
##     --p-unassignable-label 'Unassigned' \
##     --p-min-consensus 0.7 \
##     --p-threads 12 \
##     --o-classification taxonomy/taxonomy_reads-per-batch_RepSeq_vsearch.qza \
##     --o-search-results taxonomy/search_results_RepSeq_vsearch.qza
##     
## qiime feature-classifier classify-consensus-vsearch \
##     --i-query core/RarRepSeq.qza  \
##     --i-reference-reads taxonomy/RefTaxo.qza \
##     --i-reference-taxonomy taxonomy/DataSeq.qza \
##     --p-perc-identity 0.8 \
##     --p-query-cov 0.3 \
##     --p-top-hits-only \
##     --p-maxaccepts 5 \
##     --p-strand 'both' \
##     --p-unassignable-label 'Unassigned' \
##     --p-min-consensus 0.7 \
##     --p-threads 12 \
##     --o-classification taxonomy/taxonomy_reads-per-batch_RarRepSeq_vsearch.qza \
##     --o-search-results taxonomy/search_results__RarRepSeq_vsearch.qza
## 
##   qiime metadata tabulate \
##   --m-input-file taxonomy/taxonomy_reads-per-batch_RepSeq_vsearch.qza \
##   --o-visualization taxonomy/taxonomy_reads-per-batch_RepSeq_vsearch.qzv  
## 
##   qiime metadata tabulate \
##   --m-input-file taxonomy/taxonomy_reads-per-batch_RarRepSeq_vsearch.qza \
##   --o-visualization taxonomy/taxonomy_reads-per-batch_RarRepSeq_vsearch.qzv  
## 
##  qiime taxa barplot \
##   --i-table core/RarTable.qza \
##   --i-taxonomy taxonomy/taxonomy_reads-per-batch_RarRepSeq_vsearch.qza \
##   --m-metadata-file $DATABASE/sample-metadata_ITS2.tsv \
##   --o-visualization taxonomy/taxa-bar-plots_reads-per-batch_RarRepSeq_vsearch.qzv 
##   
##   
##    qiime taxa barplot \
##   --i-table core/RarTable.qza \
##   --i-taxonomy taxonomy/taxonomy_reads-per-batch_RepSeq_vsearch.qza \
##   --m-metadata-file $DATABASE/sample-metadata_ITS2.tsv \
##   --o-visualization taxonomy/taxa-bar-plots_reads-per-batch_RepSeq_vsearch.qzv 
## 
## qiime tools export --input-path taxonomy/taxa-bar-plots_reads-per-batch_RarRepSeq_vsearch.qzv --output-path export/taxonomy/taxa-bar-plots_reads-per-batch_RarRepSeq_vsearch
## qiime tools export --input-path taxonomy/taxa-bar-plots_reads-per-batch_RepSeq_vsearch.qzv --output-path export/taxonomy/taxa-bar-plots_reads-per-batch_RepSeq_vsearch
## qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RepSeq_vsearch.qzv --output-path export/taxonomy/taxonomy_reads-per-batch_RepSeq_vsearch_visual
## qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RarRepSeq_vsearch.qzv --output-path export/taxonomy/taxonomy_reads-per-batch_RarRepSeq_vsearch_visual
## qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RarRepSeq_vsearch.qza --output-path export/taxonomy/taxonomy_reads-per-batch_RarRepSeq_vsearch
## qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RepSeq_vsearch.qza --output-path export/taxonomy/taxonomy_reads-per-batch_RepSeq_vsearch
## qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RarRepSeq.qza --output-path export/taxonomy/taxonomy_reads-per-batch_RarRepSeq

