#!/bin/bash

for lang in "arg" "ast" "oci"; do
  echo "Processing $lang..."

  # Create a master temporary file to accumulate lines to be removed
  master_tmp_file=$(mktemp)

  for dataset in "wikimedia-v20210402" "wikimedia-v20230407" "WikiMatrix-v1"; do
    echo "Processing $dataset..."

    # Generate a temporary file with the lines to be removed for the current dataset
    tmp_file=$(mktemp)

    # Capture the lines to be removed from wikipedia.$lang
    paste data/$lang/parallel/tatoeba.id data/$lang/parallel/tatoeba.$lang.lid | \
        grep -n $dataset | \
        cut -f4 | \
        sort > $tmp_file
    
    # Append these lines to the master temporary file
    cat $tmp_file >> $master_tmp_file

    # Clean up the current temporary file
    rm $tmp_file

    echo "Done with $dataset!"
  done

  # Remove duplicate lines in the master temporary file
  sort $master_tmp_file | uniq > ${master_tmp_file}_sorted

  # Iterate through wikipedia.$lang and wikipedia.spa, removing lines if needed
  paste data/$lang/mono/wikipedia_all.$lang data/$lang/synt/wikipedia_all.spa | \
    awk -v file=${master_tmp_file}_sorted 'BEGIN {
      FS="\t"; OFS="\t";
      while ((getline line < file) > 0) {
        remove[line] = 1;
      }
      close(file);
    }
    {
      lang_line = $1;
      if (!(lang_line in remove)) {
        print $0;
      }
    }' | awk -F'\t' -v lang="$lang" '{print $1 > "data/" lang "/mono/wikipedia_all_no_overlaps." lang; print $2 > "data/" lang "/synt/wikipedia_all_no_overlaps.spa"}'

  # Clean up the master temporary file
  rm ${master_tmp_file}_sorted
  rm $master_tmp_file

  echo "Done with $lang!"
done
