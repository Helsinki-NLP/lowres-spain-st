#!/bin/bash
#SBATCH --job-name="backtranslate"
#SBATCH -o logs/backtranslate_roa-itc_%j.out
#SBATCH -e logs/backtranslate_roa-itc_%j.err
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:v100:4
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=8000
#SBATCH --account=project_2001194
#SBATCH --time=00:30:00

input=$1
output=$2

modeldir="models/OPUS-MT+bibles/roa-deu+eng+fra+por+spa/"
modelname="opusTCv20230926max50+bt+jhubc.spm32k-spm32k.transformer-big.model1.npz.best-perplexity.npz"
vocab="opusTCv20230926max50+bt+jhubc.spm32k-spm32k.vocab.yml"
spm_source="opus+jhubc.src.spm32k-model"
spm_target="opus+jhubc.trg.spm32k-model"

MARIAN="/scratch/project_2005815/degibert/marian-dev/build"

# Tokenize data and translate
cat ${input} | ${MARIAN}/spm_encode --model $modeldir/$spm_source | \
sed "s/^/>>spa<< /" | ${MARIAN}/marian-decoder --max-length-crop \
        -m $modeldir/$modelname \
        -o ${output/.spa/.tok.spa} -v $modeldir/$vocab \
        $modeldir/$vocab -d 0 1 2 3 --log logs/backtranslate_${output//\//_}.log

# Detokenize
cat ${output/.spa/.tok.spa} | ${MARIAN}/spm_decode --model=$modeldir/$spm_target > ${output}