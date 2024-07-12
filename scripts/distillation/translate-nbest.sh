#!/bin/bash
#SBATCH --job-name="distill"
#SBATCH -o logs/distill_%j.out
#SBATCH -e logs/distill_%j.err
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:v100:4
#SBATCH --cpus-per-task=40
#SBATCH --mem=32G
#SBATCH --account=project_2001194
#SBATCH --time=5:00:00

#!/bin/bash
##
# Translates files generating n-best lists as output
#

input=$1
output=$2
model=$3
vocab=$4

MARIAN="/scratch/project_2005815/degibert/marian-dev/build"

"${MARIAN}/marian-decoder" \
  -c scripts/distillation/decoder.yml \
  -m "${model}" \
  -v "${vocab}" "${vocab}" \
  -i "${input}" \
  -o "${output}" \
  --n-best \
  -d 0 1 2 3 \
  -w 25000

test "$(wc -l <"${output}")" -eq "$(( $(wc -l <"${input}") * 8 ))"