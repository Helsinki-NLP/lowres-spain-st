#!/bin/bash

for lid in ast oci arg ara
do
    sbatch --job-name langid_${lid}_synt scripts/langid.sh packages/data/train-parts synt.clean.spa-${lid}.${lid} $lid
    sbatch --job-name langid_spa_synt scripts/langid.sh packages/data/train-parts synt.clean.spa-${lid}.spa spa

    sbatch --job-name langid_${lid}_tatoeba scripts/langid.sh packages/data/train-parts tatoeba.clean.spa-${lid}.${lid} $lid
    sbatch --job-name langid_spa_tatoeba scripts/langid.sh packages/data/train-parts tatoeba.clean.spa-${lid}.spa spa

    #sbatch --job-name langid_${lid}_cra scripts/langid.sh data/${lid}/mono crawled.txt $lid
    #sbatch --job-name langid_${lid}_lit scripts/langid.sh data/${lid}/mono literary.txt $lid
    #sbatch --job-name langid_${lid}_wik scripts/langid.sh data/${lid}/mono wikipedia_all_no_overlaps.${lid} $lid

    #file_prefix=data/${lid}/parallel/tatoeba.${lid}
    #sbatch --job-name langid_spa-${lid}_${lid} scripts/langid.sh $file_prefix $lid

    #file_prefix=data/${lid}/parallel/tatoeba.spa
    #sbatch --job-name langid_spa-${lid}_spa scripts/langid.sh $file_prefix spa
done

#sbatch --job-name langid_oci_dis scripts/langid.sh data/oci/mono wiki_discussions.oci oci
