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

# Double tags, xxx for Occitan
#sed "s/^>>xxx<< />>oci<< >>xxx<< /" data/train/train.spa-oci.spa.xxx.tok > data/train/train.spa-oci.spa.oci-xxx.tok
#sed "s/^>>xxx<< />>oci<< >>oci<< /" data/train/dev.src.xxx.ara.tok > data/train/dev.src.oci-oci.ara.tok
#sed "s/^>>oci<< />>oci<< >>oci<< /" data/train/train.spa-ara.spa.tok > data/train/train.spa-ara.spa.oci-oci.tok

# Concat all train data with xxx tag for Aranese
#cat data/train/train.spa-arg.spa.tok data/train/train.spa-ast.spa.tok data/train/train.spa-oci.spa.oci-xxx.tok data/train/train.spa-ara.spa.oci-oci.tok > data/train/train.src.oci-oci.ara.tok

# OPUS+bibles model
opusmodeldir="models/OPUS-MT+bibles/deu+eng+fra+por+spa-itc/"
opusmodelname="opusTCv20230926max50+bt+jhubc.spm32k-spm32k.transformer-big.model1.npz.best-perplexity.npz"
vocab="opusTCv20230926max50+bt+jhubc.spm32k-spm32k.vocab.yml"

# Output model
modeldir="models/opus+bibles_ft_all_xxx_4_bleu"
datadir="data/train"

mkdir -p $modeldir
mkdir -p ${modeldir}/valid_logs

# Marian
MARIAN="/scratch/project_2005815/degibert/marian-dev/build"

# Fine-tune
${MARIAN}/marian --model "${modeldir}/model.npz" \
       --pretrained-model "${opusmodeldir}/${opusmodelname}" \
       -v "${opusmodeldir}/$vocab" "${opusmodeldir}/$vocab" \
       --valid-sets "${datadir}/dev.src.oci-oci.ara.tok" "${datadir}/dev.trg.tok"  \
       --train-sets "${datadir}/train.src.oci-oci.ara.tok" "${datadir}/train.trg.tok" \
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