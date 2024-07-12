#!/bin/bash
#SBATCH --job-name="ensemble_distilled_best_%j.sh"
#SBATCH --account=project_2001194
#SBATCH --output=logs/ensemble_distilled_best_%j.out
#SBATCH --error=logs/ensemble_distilled_best_%j.err
#SBATCH --time=01:00:00
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=32G
#SBATCH --gres=gpu:v100:1
#SBATCH --cpus-per-task=10

# ------- CHECKPOINT SELECTION -----

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <language> <num_top_checkpoints>"
  exit 1
fi

# Assign the arguments to variables
LANG=$1
NUM_TOP=$2

# Temporary file to store all BLEU scores and checkpoints
temp_file="${NUM_TOP}_${LANG}_tmp"
touch $temp_file

# Function to extract the BLEU scores and their corresponding checkpoints
extract_checkpoints() {
  local model_dir=$1
  local lang=$2

  # Check if the BLEU log file exists
  if [ ! -f "$model_dir/valid_logs/dev.$lang.valid.bleu.log" ]; then
    return
  fi

  # Extract BLEU scores and corresponding lines
  grep -Eo '[0-9]+(\.[0-9]+)?' "$model_dir/valid_logs/dev.$lang.valid.bleu.log" > "${model_dir}_${lang}_${NUM_TOP}_bleu_scores.txt"

  # Extract corresponding updates from updates.log
  grep -Eo '[0-9]+' "$model_dir/valid_logs/updates.log" > "${model_dir}_${lang}_${NUM_TOP}_updates.txt"

  # Combine BLEU scores and updates
  paste "${model_dir}_${lang}_${NUM_TOP}_bleu_scores.txt" "${model_dir}_${lang}_${NUM_TOP}_updates.txt" | while IFS=$'\t' read -r bleu update; do
    echo -e "$bleu\t$model_dir/model.iter${update}.npz" >> $temp_file
  
  # Clean up temporary files
  rm -f "${model_dir}_${lang}_${NUM_TOP}_bleu_scores.txt" "${model_dir}_${lang}_${NUM_TOP}_updates.txt"
  done
}

# Iterate through each model directory and extract checkpoints

avail_models="models/distilled"
for model_dir in $avail_models; do
  if [ -d "$model_dir" ]; then
    extract_checkpoints "$model_dir" "$LANG"
  fi
done

# Sort the combined BLEU scores and select the top-k checkpoints
sort -nr $temp_file | head -n $NUM_TOP > ${NUM_TOP}_${LANG}_top_bleu_scores.txt

# Print the top checkpoints with BLEU scores
echo "Top $NUM_TOP checkpoints:"
while IFS=$'\t' read -r bleu checkpoint; do
  echo "Checkpoint $checkpoint with BLEU score $bleu"
done < ${NUM_TOP}_${LANG}_top_bleu_scores.txt

# Print the models separated by whitespace
models=$(awk '{print $2}' "${NUM_TOP}_${LANG}_top_bleu_scores.txt" | tr '\n' ' ')
echo "$models"

# Clean up temporary files
rm -f ${NUM_TOP}_${LANG}_top_bleu_scores.txt $temp_file


# ------- TRANSLATION -----

spm_target="models/OPUS-MT+bibles/deu+eng+fra+por+spa-itc/opus+jhubc.trg.spm32k-model"
vocab="models/OPUS-MT+bibles/deu+eng+fra+por+spa-itc/opusTCv20230926max50+bt+jhubc.spm32k-spm32k.vocab.yml"
MARIAN="/scratch/project_2005815/degibert/marian-dev/build"

src="data/FLORES+/dev.${LANG}.source.tok"

if [ "$LANG" == "ara" ] ; then
  src="data/FLORES+/dev.${LANG}.xxx.source.tok"
fi

trg="data/FLORES+/dev.${LANG}"
hyp="data/ensembles_distilled_best/$NUM_TOP.$LANG"
metric_file="data/ensembles_distilled_best/$LANG.metric"

if [ -e $hyp ]; then
    echo "Translation file already exists. Remove to overwrite."
else 
    ${MARIAN}/marian-decoder -m $models -i $src --normalize 1 --beam-size 6 -v $vocab $vocab | ${MARIAN}/spm_decode --model $spm_target > $hyp
fi

# ------- EVALUATION -----

# Write NUM_TOP to a temporary file
echo "$NUM_TOP" > num_top_${NUM_TOP}_${LANG}.txt

# Get the BLEU score and write it to another temporary file
sacrebleu ${trg} -i $hyp -m bleu -w 4 --score-only > bleu_score_${NUM_TOP}_${LANG}.txt

# Combine the two files side by side and append to the metric file
paste num_top_${NUM_TOP}_${LANG}.txt bleu_score_${NUM_TOP}_${LANG}.txt >> $metric_file

# Clean up temporary files
rm num_top_${NUM_TOP}_${LANG}.txt bleu_score_${NUM_TOP}_${LANG}.txt

echo $SLURM_JOB_ID >> data/ensembles_distilled_best/jobids.txt