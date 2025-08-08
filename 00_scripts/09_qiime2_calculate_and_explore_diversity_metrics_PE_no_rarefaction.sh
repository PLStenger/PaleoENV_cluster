#!/bin/bash

WORKING_DIRECTORY=/scratch_vol0/fungi/PaleoENV_cluster/05_QIIME2/ITS2
OUTPUT=/scratch_vol0/fungi/PaleoENV_cluster/05_QIIME2/visual_no_rarefaction/ITS2

DATABASE=/scratch_vol0/fungi/PaleoENV_cluster/98_database_files
TMPDIR=/scratch_vol0

# Aim: perform diversity metrics and rarefaction

# https://chmi-sops.github.io/mydoc_qiime2.html#step-8-calculate-and-explore-diversity-metrics
# https://docs.qiime2.org/2018.2/tutorials/moving-pictures/#alpha-rarefaction-plotting
# https://forum.qiime2.org/t/how-to-decide-p-sampling-depth-value/3296/6

# Use QIIME2’s diversity core-metrics-phylogenetic function to calculate a whole bunch of diversity metrics all at once. 
# Note that you should input a sample-depth value based on the alpha-rarefaction analysis that you ran before.

# sample-depth value choice : 
# We are ideally looking for a sequencing depth at the point where these rarefaction curves begin to level off (indicating that most of the relevant diversity has been captured).
# This helps inform tough decisions that we need to make when some samples have lower sequence counts and we need to balance the priorities that you want to choose 
# a value high enough that you capture the diversity present in samples with high counts, but low enough that you don’t get rid of a ton of your samples.

cd $WORKING_DIRECTORY

eval "$(conda shell.bash hook)"
#conda activate qiime2-2021.4
conda activate /scratch_vol0/fungi/envs/qiime2-amplicon-2024.10


# Make the directory (mkdir) only if not existe already(-p)
mkdir -p pcoa_no_rarefaction
mkdir -p export/pcoa_no_rarefaction

mkdir -p core_no_rarefaction
mkdir -p export/core_no_rarefaction

mkdir -p visual_no_rarefaction
mkdir -p export/visual_no_rarefaction/

# I'm doing this step in order to deal the no space left in cluster :
export TMPDIR='/scratch_vol0/fungi'
echo $TMPDIR

# core_metrics_phylogenetic:
############################
    # Aim: Applies a collection of diversity metrics to a feature table
    # Use: qiime diversity core-metrics-phylogenetic [OPTIONS]
    
    # With 4202 -> 0 samples deleted

qiime diversity core-metrics-phylogenetic \
       --i-phylogeny tree/rooted-tree.qza \
       --i-table core_no_rarefaction/Table.qza \
       --p-sampling-depth 20627 \
       --m-metadata-file $DATABASE/sample-metadata_ITS2.tsv \
       --o-rarefied-table core_no_rarefaction/RarTable.qza \
       --o-observed-features-vector core_no_rarefaction/Vector-observed_asv.qza \
       --o-shannon-vector core_no_rarefaction/Vector-shannon.qza \
       --o-evenness-vector core_no_rarefaction/Vector-evenness.qza \
       --o-faith-pd-vector core_no_rarefaction/Vector-faith_pd.qza \
       --o-jaccard-distance-matrix core_no_rarefaction/Matrix-jaccard.qza \
       --o-bray-curtis-distance-matrix core_no_rarefaction/Matrix-braycurtis.qza \
       --o-unweighted-unifrac-distance-matrix core_no_rarefaction/Matrix-unweighted_unifrac.qza \
       --o-weighted-unifrac-distance-matrix core_no_rarefaction/Matrix-weighted_unifrac.qza \
       --o-jaccard-pcoa-results pcoa_no_rarefaction/PCoA-jaccard.qza \
       --o-bray-curtis-pcoa-results pcoa_no_rarefaction/PCoA-braycurtis.qza \
       --o-unweighted-unifrac-pcoa-results pcoa_no_rarefaction/PCoA-unweighted_unifrac.qza \
       --o-weighted-unifrac-pcoa-results pcoa_no_rarefaction/PCoA-weighted_unifrac.qza \
       --o-jaccard-emperor visual_no_rarefaction/Emperor-jaccard.qzv \
       --o-bray-curtis-emperor visual_no_rarefaction/Emperor-braycurtis.qzv \
       --o-unweighted-unifrac-emperor visual_no_rarefaction/Emperor-unweighted_unifrac.qzv \
       --o-weighted-unifrac-emperor visual_no_rarefaction/Emperor-weighted_unifrac.qzv


# sequence_rarefaction_filter:
##############################

# Aim: Filter features from sequences based on a feature table or metadata.
# Use: qiime feature-table filter-seqs [OPTIONS]

qiime feature-table filter-seqs \
        --i-data core_no_rarefaction/RepSeq.qza \
        --i-table core_no_rarefaction/RarTable.qza \
        --o-filtered-data core_no_rarefaction/RarRepSeq.qza

# summarize_sequence:
#####################

qiime feature-table tabulate-seqs \
       --i-data core_no_rarefaction/RarRepSeq.qza \
       --o-visualization core_no_rarefaction/RarRepSeq.qzv

# summarize_table :
##################

# Aim: Generate visual and tabular summaries of a feature table
# Use: qiime feature-table summarize [OPTIONS]

qiime feature-table summarize \
       --i-table core_no_rarefaction/RarTable.qza \
       --m-sample-metadata-file $DATABASE/sample-metadata.tsv \
       --o-visualization core_no_rarefaction/RarTable.qzv


# Aim: compute user-specified diversity metrics and pcoa with emperor plot :
############################################################################

# alpha_diversity; Aim: Compute a user-specified alpha diversity metric, for all samples in a feature table
############################################################################################################

# Simpson's index: Measures the relative abundance of the different species making up the sample richness.
qiime diversity alpha --i-table core_no_rarefaction/RarTable.qza \
        --p-metric simpson \
        --o-alpha-diversity core_no_rarefaction/Vector-simpson.qza

# Simpson evenness measure E: Diversity that account for the number of organisms and number of species.
qiime diversity alpha --i-table core_no_rarefaction/RarTable.qza \
        --p-metric simpson_e \
        --o-alpha-diversity core_no_rarefaction/Vector-simpson_e.qza

# Fisher's index: Relationship between the number of species and the abundance of each species.
qiime diversity alpha --i-table core_no_rarefaction/RarTable.qza \
        --p-metric fisher_alpha \
        --o-alpha-diversity core_no_rarefaction/Vector-fisher_alpha.qza
        
# Pielou's evenness: Measure of relative evenness of species richness.
qiime diversity alpha --i-table core_no_rarefaction/RarTable.qza \
        --p-metric pielou_e \
        --o-alpha-diversity core_no_rarefaction/Vector-pielou_e.qza        

# Chao1's index: Estimates diversity from abundant data and number of rare taxa missed from under sampling.
qiime diversity alpha --i-table core_no_rarefaction/RarTable.qza \
        --p-metric chao1 \
        --o-alpha-diversity core_no_rarefaction/Vector-chao1.qza   

# Chao1 confidence interval: Confidence interval for richness estimator chao1.
qiime diversity alpha --i-table core_no_rarefaction/RarTable.qza \
        --p-metric chao1_ci \
        --o-alpha-diversity core_no_rarefaction/Vector-chao1_ci.qza   

# beta_diversity; Aim: Compute a user-specified beta diversity metric, for all pairs of samples in a feature table
##################################################################################################################

#         --p-n-jobs {params.jobs} \

# Jaccard similarity index: Fraction of unique features, regardless of abundance.
qiime diversity beta --i-table core_no_rarefaction/RarTable.qza \
        --p-metric jaccard \
        --o-distance-matrix core_no_rarefaction/Matrix-jaccard.qza

qiime diversity pcoa --i-distance-matrix core_no_rarefaction/Matrix-jaccard.qza \
        --o-pcoa pcoa_no_rarefaction/PCoA-jaccard.qza
        
qiime emperor plot --i-pcoa pcoa_no_rarefaction/PCoA-jaccard.qza \
        --m-metadata-file $DATABASE/sample-metadata.tsv \
        --o-visualization visual_no_rarefaction/Emperor-jaccard.qzv
        
        
# Bray-Curtis dissimilarity: Fraction of overabundant counts.
qiime diversity beta --i-table core_no_rarefaction/RarTable.qza \
        --p-metric braycurtis \
        --o-distance-matrix core_no_rarefaction/Matrix-braycurtis.qza

qiime diversity pcoa --i-distance-matrix core_no_rarefaction/Matrix-braycurtis.qza \
        --o-pcoa pcoa_no_rarefaction/PCoA-braycurtis.qza

qiime emperor plot --i-pcoa pcoa_no_rarefaction/PCoA-braycurtis.qza \
        --m-metadata-file $DATABASE//sample-metadata.tsv \
        --o-visualization visual_no_rarefaction/Emperor-braycurtis.qzv

### SIGNIFIANCE
  
# Now test for relationships between alpha diversity and study metadata   
  
qiime diversity alpha-group-significance \
  --i-alpha-diversity core_no_rarefaction/Vector-faith_pd.qza \
  --m-metadata-file $DATABASE/sample-metadata.tsv \
  --o-visualization core_no_rarefaction/faith-pd-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core_no_rarefaction/Vector-evenness.qza \
  --m-metadata-file $DATABASE/sample-metadata.tsv \
  --o-visualization core_no_rarefaction/evenness-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core_no_rarefaction/Vector-shannon.qza \
  --m-metadata-file $DATABASE/sample-metadata.tsv \
  --o-visualization core_no_rarefaction/shannon_group-significance.qzv  
  
# Aim: statistically compare groups of alpha/beta diversity values
# Aim: Visually and statistically compare groups of alpha diversity values

qiime diversity alpha-group-significance --i-alpha-diversity core_no_rarefaction/Vector-simpson.qza \
        --m-metadata-file $DATABASE/sample-metadata.tsv \
        --o-visualization visual_no_rarefaction/AlphaSignification-simpson.qzv

qiime diversity alpha-group-significance --i-alpha-diversity core_no_rarefaction/Vector-simpson_e.qza \
        --m-metadata-file $DATABASE/sample-metadata.tsv \
        --o-visualization visual_no_rarefaction/AlphaSignification-simpson_e.qzv
            
qiime diversity alpha-group-significance --i-alpha-diversity core_no_rarefaction/Vector-chao1_ci.qza \
        --m-metadata-file $DATABASE/sample-metadata.tsv \
        --o-visualization visual_no_rarefaction/AlphaSignification-chao1_ci.qzv

qiime diversity alpha-group-significance --i-alpha-diversity core_no_rarefaction/Vector-chao1.qza \
        --m-metadata-file $DATABASE/sample-metadata.tsv \
        --o-visualization visual_no_rarefaction/AlphaSignification-chao1.qzv

qiime diversity alpha-group-significance --i-alpha-diversity core_no_rarefaction/Vector-pielou_e.qza \
        --m-metadata-file $DATABASE/sample-metadata.tsv \
        --o-visualization visual_no_rarefaction/AlphaSignification-pielou_e.qzv
        
qiime diversity alpha-group-significance --i-alpha-diversity core_no_rarefaction/Vector-fisher_alpha.qza \
        --m-metadata-file $DATABASE/sample-metadata.tsv \
        --o-visualization visual_no_rarefaction/AlphaSignification-fisher_alpha.qzv

# Aim: Determine whether numeric sample metadata category is correlated with alpha diversity

qiime diversity alpha-correlation --i-alpha-diversity core_no_rarefaction/Vector-simpson.qza \
        --m-metadata-file $DATABASE/sample-metadata.tsv \
        --p-method spearman \
        --o-visualization visual_no_rarefaction/AlphaCorrelation-simpson.qzv

qiime diversity alpha-correlation --i-alpha-diversity core_no_rarefaction/Vector-simpson_e.qza \
        --m-metadata-file $DATABASE/sample-metadata.tsv \
        --p-method spearman \
        --o-visualization visual_no_rarefaction/AlphaCorrelation-simpson_e.qzv

qiime diversity alpha-correlation --i-alpha-diversity core_no_rarefaction/Vector-chao1_ci.qza \
        --m-metadata-file $DATABASE/sample-metadata.tsv \
        --p-method spearman \
        --o-visualization visual_no_rarefaction/AlphaCorrelation-chao1_ci.qzv

qiime diversity alpha-correlation --i-alpha-diversity core_no_rarefaction/Vector-chao1.qza \
        --m-metadata-file $DATABASE/sample-metadata.tsv \
        --p-method spearman \
        --o-visualization visual_no_rarefaction/AlphaCorrelation-chao1.qzv      
        
qiime diversity alpha-correlation --i-alpha-diversity core_no_rarefaction/Vector-pielou_e.qza \
        --m-metadata-file $DATABASE/sample-metadata.tsv \
        --p-method spearman \
        --o-visualization visual_no_rarefaction/AlphaCorrelation-pielou_e.qzv        
        
 qiime diversity alpha-correlation --i-alpha-diversity core_no_rarefaction/Vector-fisher_alpha.qza \
        --m-metadata-file $DATABASE/sample-metadata.tsv \
        --p-method spearman \
        --o-visualization visual_no_rarefaction/AlphaCorrelation-fisher_alpha.qzv        
  
# Now test for relationships between beta diversity and study metadata 

qiime diversity beta-group-significance \
  --i-distance-matrix core_no_rarefaction/Matrix-unweighted_unifrac.qza \
  --m-metadata-file $DATABASE/sample-metadata.tsv \
  --m-metadata-column Acronyme \
  --o-visualization core_no_rarefaction/unweighted-unifrac-Acronyme-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core_no_rarefaction/Matrix-unweighted_unifrac.qza \
  --m-metadata-file $DATABASE/sample-metadata.tsv \
  --m-metadata-column SampleID \
  --o-visualization core_no_rarefaction/unweighted-unifrac-SampleID-group-significance.qzv \
  --p-pairwise
  
qiime diversity beta-group-significance --i-distance-matrix core_no_rarefaction/Matrix-jaccard.qza  \
        --m-metadata-file $DATABASE/sample-metadata.tsv  \
        --m-metadata-column Acronyme \
        --o-visualization visual_no_rarefaction/BetaSignification-jaccard-Acronyme.qzv  \
        --p-method permanova  \
        --p-pairwise  \
        --p-permutations 9999
  
qiime diversity beta-group-significance --i-distance-matrix core_no_rarefaction/Matrix-braycurtis.qza  \
        --m-metadata-file $DATABASE/sample-metadata.tsv  \
        --m-metadata-column Acronyme \
        --o-visualization visual_no_rarefaction/BetaSignification-braycurtis-Acronyme.qzv  \
        --p-method permanova  \
        --p-pairwise  \
        --p-permutations 9999  

# Create a PCoA plot to explore beta diversity metric. 
# To do this you can use Emperor, a powerful tool for interactively exploring scatter plots. You do not need to install Emperor.

#first, use the unweighted unifrac data as input
qiime emperor plot \
  --i-pcoa pcoa_no_rarefaction/PCoA-unweighted_unifrac.qza \
  --m-metadata-file $DATABASE/sample-metadata.tsv \
  --p-custom-axes Acronyme \
  --o-visualization pcoa_no_rarefaction/unweighted-unifrac-emperor-Acronyme.qzv

#now repeat with bray curtis
qiime emperor plot \
  --i-pcoa pcoa_no_rarefaction/PCoA-braycurtis.qza \
  --m-metadata-file $DATABASE/sample-metadata.tsv \
  --p-custom-axes Acronyme \
  --o-visualization pcoa_no_rarefaction/bray-curtis-emperor-Acronyme.qzv

qiime tools export --input-path core_no_rarefaction/RarTable.qza --output-path export/table/RarTable
qiime tools export --input-path core_no_rarefaction/RarRepSeq.qza --output-path export/table/RarRepSeq

qiime tools export --input-path visual_no_rarefaction/BetaSignification-braycurtis-Acronyme.qzv --output-path export/visual_no_rarefaction/BetaSignification-braycurtis-Acronyme
qiime tools export --input-path visual_no_rarefaction/BetaSignification-jaccard-Acronyme.qzv --output-path export/visual_no_rarefaction/BetaSignification-jaccard-Acronyme
qiime tools export --input-path visual_no_rarefaction/AlphaCorrelation-fisher_alpha.qzv --output-path export/visual_no_rarefaction/AlphaCorrelation-fisher_alpha
qiime tools export --input-path visual_no_rarefaction/AlphaCorrelation-pielou_e.qzv --output-path export/visual_no_rarefaction/AlphaCorrelation-pielou_e
qiime tools export --input-path visual_no_rarefaction/AlphaCorrelation-chao1.qzv --output-path export/visual_no_rarefaction/AlphaCorrelation-chao1
qiime tools export --input-path visual_no_rarefaction/AlphaCorrelation-simpson_e.qzv --output-path export/visual_no_rarefaction/AlphaCorrelation-simpson_e
qiime tools export --input-path visual_no_rarefaction/AlphaCorrelation-simpson.qzv --output-path export/visual_no_rarefaction/AlphaCorrelation-simpson
qiime tools export --input-path visual_no_rarefaction/AlphaSignification-fisher_alpha.qzv --output-path export/visual_no_rarefaction/AlphaSignification-fisher_alpha
qiime tools export --input-path visual_no_rarefaction/AlphaSignification-pielou_e.qzv --output-path export/visual_no_rarefaction/AlphaSignification-pielou_e
qiime tools export --input-path visual_no_rarefaction/AlphaSignification-chao1.qzv --output-path export/visual_no_rarefaction/AlphaSignification-chao1
qiime tools export --input-path visual_no_rarefaction/AlphaSignification-simpson_e.qzv --output-path export/visual_no_rarefaction/AlphaSignification-simpson_e
qiime tools export --input-path visual_no_rarefaction/AlphaSignification-simpson.qzv --output-path export/visual_no_rarefaction/AlphaSignification-simpson
qiime tools export --input-path visual_no_rarefaction/Emperor-braycurtis.qzv --output-path export/visual_no_rarefaction/Emperor-braycurtis
qiime tools export --input-path visual_no_rarefaction/Emperor-jaccard.qzv --output-path export/visual_no_rarefaction/Emperor-jaccard
qiime tools export --input-path visual_no_rarefaction/Emperor-weighted_unifrac.qzv --output-path export/visual_no_rarefaction/Emperor-weighted_unifrac
qiime tools export --input-path visual_no_rarefaction/Emperor-unweighted_unifrac.qzv --output-path export/visual_no_rarefaction/Emperor-unweighted_unifrac 

qiime tools export --input-path core_no_rarefaction/bray_curtis_distance_matrix.qza --output-path export/core_no_rarefaction/bray_curtis_distance_matrix
qiime tools export --input-path core_no_rarefaction/Vector-evenness.qza --output-path export/core_no_rarefaction/Vector-evenness
qiime tools export --input-path core_no_rarefaction/jaccard_distance_matrix.qza --output-path export/core_no_rarefaction/jaccard_distance_matrix
qiime tools export --input-path core_no_rarefaction/jaccard_pcoa_results.qza --output-path export/core_no_rarefaction/jaccard_pcoa_results
qiime tools export --input-path core_no_rarefaction/observed_otus_vector.qza --output-path export/core_no_rarefaction/observed_otus_vector
qiime tools export --input-path core_no_rarefaction/rarefied_table.qza --output-path export/core_no_rarefaction/rarefied_table
qiime tools export --input-path core_no_rarefaction/Vector-shannon.qza --output-path export/core_no_rarefaction/Vector-shannon
qiime tools export --input-path core_no_rarefaction/Matrix-unweighted_unifrac.qza --output-path export/core_no_rarefaction/Matrix-unweighted_unifrac
qiime tools export --input-path core_no_rarefaction/weighted_unifrac_distance_matrix.qza --output-path export/core_no_rarefaction/weighted_unifrac_distance_matrix
qiime tools export --input-path core_no_rarefaction/weighted_unifrac_pcoa_results.qza --output-path export/core_no_rarefaction/weighted_unifrac_pcoa_results

qiime tools export --input-path core_no_rarefaction/Matrix-braycurtis.qza --output-path export/core_no_rarefaction/Matrix-braycurtis
qiime tools export --input-path core_no_rarefaction/Matrix-jaccard.qza --output-path export/core_no_rarefaction/Matrix-jaccard
qiime tools export --input-path core_no_rarefaction/Matrix-unweighted_unifrac.qza --output-path export/core_no_rarefaction/Matrix-unweighted_unifrac
qiime tools export --input-path core_no_rarefaction/Matrix-weighted_unifrac.qza --output-path export/core_no_rarefaction/Matrix-weighted_unifrac
qiime tools export --input-path core_no_rarefaction/Vector-evenness.qza --output-path export/core_no_rarefaction/Vector-evenness
qiime tools export --input-path core_no_rarefaction/Vector-faith_pd.qza --output-path export/core_no_rarefaction/Vector-faith_pd
qiime tools export --input-path core_no_rarefaction/Vector-observed_asv.qza --output-path export/core_no_rarefaction/Vector-observed_asv
qiime tools export --input-path core_no_rarefaction/Vector-shannon.qza --output-path export/core_no_rarefaction/Vector-shannon

qiime tools export --input-path pcoa_no_rarefaction/PCoA-braycurtis.qza --output-path export/pcoa_no_rarefaction/PCoA-braycurtis
qiime tools export --input-path pcoa_no_rarefaction/PCoA-jaccard.qza --output-path export/pcoa_no_rarefaction/PCoA-jaccard
qiime tools export --input-path pcoa_no_rarefaction/PCoA-unweighted_unifrac.qza --output-path export/pcoa_no_rarefaction/PCoA-unweighted_unifrac
qiime tools export --input-path pcoa_no_rarefaction/PCoA-weighted_unifrac.qza --output-path export/pcoa_no_rarefaction/PCoA-weighted_unifrac
