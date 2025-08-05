#!/bin/bash

############################################################################################################################################
# trnL
############################################################################################################################################

WORKING_DIRECTORY=/scratch_vol0/fungi/PaleoENV_cluster/05_QIIME2/trnL
DATABASE=/scratch_vol0/fungi/PaleoENV_cluster/98_database_files
TMPDIR=/scratch_vol0

# Aim: rarefy a feature table to compare alpha/beta diversity results

# A good forum to understand what it does :
# https://forum.qiime2.org/t/can-someone-help-in-alpha-rarefaction-plotting-depths/4580/16

cd $WORKING_DIRECTORY

eval "$(conda shell.bash hook)"
#conda activate qiime2-2021.4
conda activate /scratch_vol0/fungi/envs/qiime2-amplicon-2024.10

# I'm doing this step in order to deal the no space left in cluster :
export TMPDIR='/scratch_vol0/fungi'
echo $TMPDIR

# Note: max-depth should be chosen based on ConTable.qzv (or on /scratch_vol0/fungi/PaleoENV_cluster/05_QIIME2/export/visual/ConTable/sample-frequency-detail.csv)

#   --i-table core/ConTable.qza \

qiime diversity alpha-rarefaction \
  --i-table core/Table.qza \
  --i-phylogeny tree/rooted-tree.qza \
  --p-max-depth 23564 \
  --p-min-depth 1 \
  --m-metadata-file $DATABASE/sample-metadata_trnL.tsv \
  --o-visualization visual/alpha-rarefaction.qzv
  
qiime tools export --input-path visual/alpha-rarefaction.qzv --output-path export/visual/alpha-rarefaction


############################################################################################################################################
# ITS2
############################################################################################################################################

WORKING_DIRECTORY=/scratch_vol0/fungi/PaleoENV_cluster/05_QIIME2/ITS2
DATABASE=/scratch_vol0/fungi/PaleoENV_cluster/98_database_files
TMPDIR=/scratch_vol0

# Aim: rarefy a feature table to compare alpha/beta diversity results

# A good forum to understand what it does :
# https://forum.qiime2.org/t/can-someone-help-in-alpha-rarefaction-plotting-depths/4580/16

cd $WORKING_DIRECTORY

eval "$(conda shell.bash hook)"
#conda activate qiime2-2021.4
conda activate /scratch_vol0/fungi/envs/qiime2-amplicon-2024.10

# I'm doing this step in order to deal the no space left in cluster :
export TMPDIR='/scratch_vol0/fungi'
echo $TMPDIR

# Note: max-depth should be chosen based on ConTable.qzv (or on /scratch_vol0/fungi/PaleoENV_cluster/05_QIIME2/export/visual/ConTable/sample-frequency-detail.csv)

#   --i-table core/ConTable.qza \

qiime diversity alpha-rarefaction \
  --i-table core/Table.qza \
  --i-phylogeny tree/rooted-tree.qza \
  --p-max-depth 20627 \
  --p-min-depth 1 \
  --m-metadata-file $DATABASE/sample-metadata_ITS2.tsv \
  --o-visualization visual/alpha-rarefaction.qzv
  
qiime tools export --input-path visual/alpha-rarefaction.qzv --output-path export/visual/alpha-rarefaction
