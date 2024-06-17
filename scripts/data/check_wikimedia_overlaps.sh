#!/bin/bash

for lang in "arg"; do #"ast" "oci" "arg"; do
  echo $lang
  for dataset in "wikimedia-v20210402" "wikimedia-v20230407" "WikiMatrix-v1"; do
    echo $dataset
    paste data/$lang/parallel/tatoeba.id data/$lang/parallel/tatoeba.$lang.lid | \
    grep -n $dataset | \
    cut -f4 | \
    sort | \
    comm -12 - <(sort data/$lang/mono/wikipedia_all_no_overlaps.$lang) | wc -l
    done
done
