#!/bin/bash
#SBATCH --job-name="sub_2_%j.sh"
#SBATCH --account=project_2001194
#SBATCH --output=logs/sub_2_%j.out
#SBATCH --error=logs/sub_2_%j.err
#SBATCH --time=02:00:00
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=32G
#SBATCH --gres=gpu:v100:1
#SBATCH --cpus-per-task=10

declare -A CKP=(
	["arg"]="models/distilled_nmt_rbmt/model.iter145000.npz"
    ["ast"]="models/distilled_nmt/model.iter25000.npz"
    ["ara"]="models/distilled_nmt/model.iter205000.npz models/distilled_nmt/model.iter202500.npz models/distilled_nmt/model.iter207500.npz models/distilled_nmt/model.iter197500.npz"
)

declare -A LANG=(
	["arg"]="arg" ["ara"]="ara.ara" ["ast"]="ast"
)

spm_source="models/OPUS-MT+bibles/deu+eng+fra+por+spa-itc/opus+jhubc.src.spm32k-model"
spm_target="models/OPUS-MT+bibles/deu+eng+fra+por+spa-itc/opus+jhubc.trg.spm32k-model"
vocab="models/OPUS-MT+bibles/deu+eng+fra+por+spa-itc/opusTCv20230926max50+bt+jhubc.spm32k-spm32k.vocab.yml"
MARIAN="/scratch/project_2005815/degibert/marian-dev/build"
src="data/test/flores200.spa"

for lang in "${!CKP[@]}"; do
    echo "Starting ${lang}..."
    models=${CKP[$lang]}
    tag=${LANG[$lang]}

    # ------- TOKENIZATION -----

    #if [ "$lang" == "ara" ]; then
    #    cat $src | ${MARIAN}/spm_encode --model $spm_source | sed "s/^/>>${tag}<< /" > data/FLORES+/test.spa-ara.xxx.tok
    
    #    echo "Created data/FLORES+/test.spa-ara.xxx.tok file..."
    #fi
    
    # ------- TRANSLATION -----
    
    hyp="data/submission_2/test.${lang}"

    echo "Translating..."

    if [ -e $hyp ]; then
        echo "Translation file already exists. Remove to overwrite."
    else 
        ${MARIAN}/marian-decoder -m $models -i data/test/flores200.spa-${tag}.tok  --normalize 1 --beam-size 6 -v $vocab $vocab | ${MARIAN}/spm_decode --model $spm_target > $hyp
    fi
    
    echo "Done! Good luck with your submission :)"
    
done
