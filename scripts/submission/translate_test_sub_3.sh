#!/bin/bash
#SBATCH --job-name="sub_3_%j.sh"
#SBATCH --account=project_2001194
#SBATCH --output=logs/sub_3_%j.out
#SBATCH --error=logs/sub_3_%j.err
#SBATCH --time=0:15:00
#SBATCH --partition=gputest
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=32G
#SBATCH --gres=gpu:v100:1
#SBATCH --cpus-per-task=10

models="models/lumi/tiny_nmt_rbmt/final.model.npz.best-bleu.npz"

declare -A LANG=(
	["arg"]="arg" ["ara"]="ara.ara" ["ast"]="ast"
)

spm_source="models/OPUS-MT+bibles/deu+eng+fra+por+spa-itc/opus+jhubc.src.spm32k-model"
spm_target="models/OPUS-MT+bibles/deu+eng+fra+por+spa-itc/opus+jhubc.trg.spm32k-model"
vocab="models/OPUS-MT+bibles/deu+eng+fra+por+spa-itc/opusTCv20230926max50+bt+jhubc.spm32k-spm32k.vocab.yml"
MARIAN="/scratch/project_2005815/degibert/marian-dev/build"
src="data/test/flores200.spa"

for lang in "${!LANG[@]}"; do
    echo "Starting ${lang}..."
    tag=${LANG[$lang]}
    src="data/test/flores200.spa-${tag}.tok"
  
    # ------- TRANSLATION -----
    
    hyp="data/submission_3/test.${lang}"

    echo "Translating..."

    if [ -e $hyp ]; then
        echo "Translation file already exists. Remove to overwrite."
    else 
        ${MARIAN}/marian-decoder -m $models -i $src --normalize 1 --beam-size 1 -v ${vocab} ${vocab} -d 0 --mini-batch 64 --maxi-batch 100 --maxi-batch-sort src | ${MARIAN}/spm_decode --model $spm_target > $hyp
    fi
    
    echo "Done! Good luck with your submission :)"
    
done