#!/bin/bash
#SBATCH --job-name="train_distill_%j"
#SBATCH -o logs/train_distill_%j.out
#SBATCH -e logs/train_distill_%j.err
#SBATCH --partition=gputest
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:v100:4
#SBATCH --cpus-per-task=40
#SBATCH --mem=32G
#SBATCH --account=project_2001194
#SBATCH --time=00:15:00

# OPUS+bibles model
opusmodeldir="models/OPUS-MT+bibles/deu+eng+fra+por+spa-itc/"
vocab="opusTCv20230926max50+bt+jhubc.spm32k-spm32k.vocab.yml"
spm_target="opus+jhubc.trg.spm32k-model"

# Output model
modeldir="models/distilled"
datadir="data/train"
distilldir="data/distillation"

mkdir -p $modeldir
mkdir -p ${modeldir}/valid_logs

# Marian
MARIAN="/scratch/project_2005815/degibert/marian-dev/build"

# Tokenize distilled data 

#for lang in "arg" "ast" "oci" "ara"; do
#    ${MARIAN}/spm_encode --model $opusmodeldir/$spm_target ${distilldir}/train.out.spa-${lang}.${lang} > ${distilldir}/train.out.spa-${lang}.${lang}.tok
#done

# Concat distilled data in same order as source!!!
# Source order: cat data/train/train.spa-arg.spa.tok data/train/train.spa-ast.spa.tok data/train/train.spa-oci.spa.tok data/train/train.spa-ara.spa.tok > data/train/train.src.tok
#cat ${distilldir}/train.out.spa-arg.arg.tok ${distilldir}/train.out.spa-ast.ast.tok ${distilldir}/train.out.spa-oci.oci.tok ${distilldir}/train.out.spa-ara.ara.tok > ${distilldir}/train.out.trg.tok

# Fine-tune
${MARIAN}/marian --model "${modeldir}/model.npz" \
       -v "${opusmodeldir}/$vocab" "${opusmodeldir}/$vocab" \
       --train-sets "${datadir}/train.src.xxx.ara.tok" ${distilldir}/train.out.trg.tok \
       --valid-sets "${datadir}/dev.src.xxx.ara.tok" "${datadir}/dev.trg.tok"  \
       --valid-translation-output "${modeldir}/valid_logs/validation-output-after-{U}-updates-{E}-epochs.txt" \
       --log "${modeldir}/train.log" --valid-log "${modeldir}/valid.log" \
       --task transformer-base \
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
