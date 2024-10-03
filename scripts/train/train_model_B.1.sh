#!/bin/bash
#SBATCH --job-name="finetune_spa-itc"
#SBATCH -o logs/finetune_spa-itc_%j.out
#SBATCH -e logs/finetune_spa-itc_%j.err
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:v100:4
#SBATCH --cpus-per-task=40
#SBATCH --mem=32G
#SBATCH --account=project_2001194
#SBATCH --time=72:00:00

# OPUS+bibles model
opusmodeldir="models/OPUS-MT+bibles/deu+eng+fra+por+spa-itc/"
opusmodelname="opusTCv20230926max50+bt+jhubc.spm32k-spm32k.transformer-big.model1.npz.best-perplexity.npz"
vocab="opusTCv20230926max50+bt+jhubc.spm32k-spm32k.vocab.yml"

# Output model
modeldir="models/opus+bibles_ft_all_xxx_bleu"
datadir="data/train"

mkdir -p $modeldir
mkdir -p ${modeldir}/valid_logs

# Marian
MARIAN="/scratch/project_2005815/degibert/marian-dev/build"

# Fine-tune
${MARIAN}/marian --model "${modeldir}/model.npz" \
       --pretrained-model "${opusmodeldir}/${opusmodelname}" \
       -v "${opusmodeldir}/$vocab" "${opusmodeldir}/$vocab" \
       --valid-sets "${datadir}/dev.src.xxx.ara.tok" "${datadir}/dev.trg.tok"  \
       --train-sets "${datadir}/train.src.xxx.ara.tok" "${datadir}/train.trg.tok" \
       --valid-translation-output "${modeldir}/valid_logs/validation-output-after-{U}-updates-{E}-epochs.txt" \
       --log "${modeldir}/train.log" --valid-log "${modeldir}/valid.log" \
       --task transformer-big \
       --optimizer-delay 2 \
       --early-stopping 10 \
       --valid-freq 2500 \
       --valid-metrics bleu perplexity ce-mean-words \
       --valid-mini-batch 16 \
       --beam-size 6 \
       --normalize 1 \
       --allow-unk \
       --workspace 25000 \
       --save-freq 2500 \
       --disp-freq 2500 \
       --devices 0 1 2 3 \
       --seed 1111 \
       --shuffle batches \
       --sharding local \
       --disp-first 10 \
       --disp-label-counts \
       --keep-best
