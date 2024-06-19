#!/bin/bash
#SBATCH --job-name="valid_curves_%j.sh"
#SBATCH --account=project_462000447
#SBATCH --output=logs/valid_curves_%j.out
#SBATCH --error=logs/valid_curves_%j.err
#SBATCH --time=00:30:00
#SBATCH --partition=dev-g
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus-per-node=1

# Author: Ona de Gibert Bonet
# Datestamp: 14-12-2023
# Usage: bash scripts/train/validate.sh models/opus+bibles_ft_all/valid_logs data/FLORES+/dev.arg data/FLORES+/dev.ast data/FLORES+/dev.ara
# Make sure you have matplotlib installed

module load python-data
source venv/bin/activate


# OPUS+bibles model

modeldir="models/OPUS-MT+bibles/deu+eng+fra+por+spa-itc/"
spm_source="opus+jhubc.src.spm32k-model"
spm_target="opus+jhubc.trg.spm32k-model"

MARIAN="/scratch/project_2005815/degibert/marian-dev/build"


valid_dir="$1"

# Sort valid logs according to their creation time
sorted_valid_logs=($(stat -c "%Y %n" "${valid_dir}"/*txt | sort -n | cut -d' ' -f2))

ref_paths=( "${@:2}" )

idx=0

for data_path in "${ref_paths[@]}"; do
    lang=$(basename "$data_path" | cut -d'.' -f1,2)

    echo "Computing statistics for ${lang}..."
    if [ -e $valid_dir/"${lang}.valid.bleu.log" ]; then
        echo "Output logs already exists. Remove exististing logs to overwrite."
    else
        lines=$(wc -l < ${data_path})
        length=$((idx + lines))

        for file in "${sorted_valid_logs[@]}"; do
            filename=$(basename "${file}")
        
            head -n "${length}" "${file}" | tail -n "${lines}" | ${MARIAN}/spm_decode --model $modeldir/$spm_target > tmp
            
            sacrebleu ${data_path} -i tmp -m bleu --score-only >> $valid_dir/"${lang}.valid.bleu.log"
            sacrebleu ${data_path} -i tmp -m chrf --score-only >> $valid_dir/"${lang}.valid.chrf.log"
            sacrebleu ${data_path} -i tmp -m ter --score-only >> $valid_dir/"${lang}.valid.ter.log"
            echo "File ${filename} has been processed ✓"

            if [ $idx -eq 0 ]; then

                # Extract updates and epochs using regex
                updates="${filename##*after-}"
                updates="${updates%%-*}"

                epochs="${filename##*updates-}"
                epochs="${epochs%%-epochs*}"
                echo "${updates}" >> $valid_dir/updates.log
                echo "${epochs}" >> $valid_dir/epochs.log
            fi
        done
        idx=$((idx + length))
    fi
    rm tmp
done

# Generate plots

if [ -e "$valid_dir/bleu_all_pairs.png" ]; then
    echo "Image already exists. Remove to overwrite"
else
    python scripts/train/plot_bleu_all_pairs.py $valid_dir
fi