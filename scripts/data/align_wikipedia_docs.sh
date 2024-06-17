#!/bin/bash

lang=$1
dir="data/wikipedia/parallel_docpairs/es-${lang}/"

for file in $dir/*${lang}.split.txt; do
    filename="${file/.${lang}.split.txt/}"
    echo ${filename}
    source=${filename}.an.split.txt
    target=${filename}.es.split.txt
    trans=${filename}.an.trans.txt
    output=${filename}.aligned

    python scripts/Bleualign/bleualign.py -s $source -t $target --srctotarget $trans -o $output --bleu_n 4
    break
done