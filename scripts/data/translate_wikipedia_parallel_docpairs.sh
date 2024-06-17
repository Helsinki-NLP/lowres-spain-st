#!/bin/bash
#SBATCH --job-name="backtranslate"
#SBATCH -o logs/backtranslate_wikipedia_parallel_docpairs_%j.out
#SBATCH -e logs/backtranslate_wikipedia_parallel_docpairs_%j.err
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:v100:4
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=8000
#SBATCH --account=project_2001194
#SBATCH --time=02:00:00

# This script translates wikipedia documents for alignment
# Usage: sbatch scripts/translate_wikipedia_parallel_docpairs.sh an

lang=$1
dir="data/wikipedia/parallel_docpairs/es-${lang}/"

# Model info
modeldir="models/OPUS-MT+bibles/roa-deu+eng+fra+por+spa/"
modelname="opusTCv20230926max50+bt+jhubc.spm32k-spm32k.transformer-big.model1.npz.best-perplexity.npz"
vocab="opusTCv20230926max50+bt+jhubc.spm32k-spm32k.vocab.yml"
spm_source="opus+jhubc.src.spm32k-model"
spm_target="opus+jhubc.trg.spm32k-model"

MARIAN="/scratch/project_2005815/degibert/marian-dev/build"

for file in "${dir}"/*${lang}.split.txt; do
        input=${file}
        output=${file/split/trans}

        if [ -f ${output} ]; then
                echo "File ${output} exists. Remove it if you want to overwrite"
        else
                # Tokenize data and translate
                cat ${input} | ${MARIAN}/spm_encode --model $modeldir/$spm_source | \
                sed "s/^/>>spa<< /" | ${MARIAN}/marian-decoder --max-length-crop \
                        -m $modeldir/$modelname \
                        -o ${output}.tok -v $modeldir/$vocab \
                        $modeldir/$vocab -d 0 1 2 3 --log logs/backtranslate_${output//\//_}.log

                # Detokenize
                cat ${output}.tok | ${MARIAN}/spm_decode --model=$modeldir/$spm_target > ${output}

                # Remove intermediate tokenized file
                rm ${output}.tok
        fi
done