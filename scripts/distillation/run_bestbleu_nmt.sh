#!/bin/bash
#SBATCH --job-name="bestbleu_%j.sh"
#SBATCH --account=project_2001194
#SBATCH --output=logs/bestbleu_%j.out
#SBATCH --error=logs/bestbleu_%j.err
#SBATCH --time=04:00:00
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:v100:1
#SBATCH --cpus-per-task=40
#SBATCH --mem=32G

module load python-data

source venv/bin/activate

lang=$1

python scripts/distillation/bestbleu.py \
 --nbest data/distillation_old/train.nmt.spa-$lang.$lang.nbest \
 --references data/train/train.spa-$lang.$lang \
 --output data/distillation_old/train.out.nmt.spa-$lang.$lang --metric chrf --debpe