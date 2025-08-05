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


qiime rescript get-ncbi-data \
    --p-query '(ITS2[ALL] OR Its2[ALL] OR its2[ALL] NOT bacteria[ORGN] NOT fungi[ORGN]))' \
    --o-sequences taxonomy/RefTaxo.qza \
    --o-taxonomy taxonomy/DataSeq.qza


#qiime feature-classifier classify-consensus-blast \
#  --i-query core/RepSeq.qza \
#  --i-reference-reads taxonomy/RefTaxo.qza \
#  --i-reference-taxonomy taxonomy/DataSeq.qza \
#  --p-perc-identity 0.70 \
#  --o-classification taxonomy/taxonomy_reads-per-batch_RepSeq.qza \
#  --verbose

qiime feature-classifier classify-consensus-vsearch \
    --i-query core/RepSeq.qza  \
    --i-reference-reads taxonomy/RefTaxo.qza \
    --i-reference-taxonomy taxonomy/DataSeq.qza \
    --p-perc-identity 0.77 \
    --p-query-cov 0.3 \
    --p-top-hits-only \
    --p-maxaccepts 1 \
    --p-strand 'both' \
    --p-unassignable-label 'Unassigned' \
    --p-threads 12 \
    --o-classification taxonomy/taxonomy_reads-per-batch_RepSeq_vsearch.qza
    
qiime feature-classifier classify-consensus-vsearch \
    --i-query core/RarRepSeq.qza  \
    --i-reference-reads taxonomy/RefTaxo.qza \
    --i-reference-taxonomy taxonomy/DataSeq.qza \
    --p-perc-identity 0.77 \
    --p-query-cov 0.3 \
    --p-top-hits-only \
    --p-maxaccepts 1 \
    --p-strand 'both' \
    --p-unassignable-label 'Unassigned' \
    --p-threads 12 \
    --o-classification taxonomy/taxonomy_reads-per-batch_RarRepSeq_vsearch.qza

  qiime metadata tabulate \
  --m-input-file taxonomy/taxonomy_reads-per-batch_RepSeq_vsearch.qza \
  --o-visualization taxonomy/taxonomy_reads-per-batch_RepSeq_vsearch.qzv  

  qiime metadata tabulate \
  --m-input-file taxonomy/taxonomy_reads-per-batch_RarRepSeq_vsearch.qza \
  --o-visualization taxonomy/taxonomy_reads-per-batch_RarRepSeq_vsearch.qzv  

 qiime taxa barplot \
  --i-table core/RarTable.qza \
  --i-taxonomy taxonomy/taxonomy_reads-per-batch_RarRepSeq_vsearch.qza \
  --m-metadata-file $DATABASE/sample-metadata_others_markers_NC.tsv \
  --o-visualization taxonomy/taxa-bar-plots_reads-per-batch_RarRepSeq_vsearch.qzv 
  
  
   qiime taxa barplot \
  --i-table core/RarTable.qza \
  --i-taxonomy taxonomy/taxonomy_reads-per-batch_RepSeq_vsearch.qza \
  --m-metadata-file $DATABASE/sample-metadata_others_markers_NC.tsv \
  --o-visualization taxonomy/taxa-bar-plots_reads-per-batch_RepSeq_vsearch.qzv 

qiime tools export --input-path taxonomy/taxa-bar-plots_reads-per-batch_RarRepSeq_vsearch.qzv --output-path export/taxonomy/taxa-bar-plots_reads-per-batch_RarRepSeq_vsearch
qiime tools export --input-path taxonomy/taxa-bar-plots_reads-per-batch_RepSeq_vsearch.qzv --output-path export/taxonomy/taxa-bar-plots_reads-per-batch_RepSeq_vsearch
qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RepSeq_vsearch.qzv --output-path export/taxonomy/taxonomy_reads-per-batch_RepSeq_vsearch_visual
qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RarRepSeq_vsearch.qzv --output-path export/taxonomy/taxonomy_reads-per-batch_RarRepSeq_vsearch_visual
qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RarRepSeq_vsearch.qza --output-path export/taxonomy/taxonomy_reads-per-batch_RarRepSeq_vsearch
qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RepSeq_vsearch.qza --output-path export/taxonomy/taxonomy_reads-per-batch_RepSeq_vsearch
qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RarRepSeq.qza --output-path export/taxonomy/taxonomy_reads-per-batch_RarRepSeq

