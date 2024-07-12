#!/bin/bash
#SBATCH --job-name="sub_4_%j.sh"
#SBATCH --account=project_2001194
#SBATCH --output=logs/sub_4_%j.out
#SBATCH --error=logs/sub_4_%j.err
#SBATCH --time=02:00:00
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=32G
#SBATCH --gres=gpu:v100:1
#SBATCH --cpus-per-task=10

declare -A CKP=(
	["arg"]="models/distilled/model.iter90000.npz models/distilled/model.iter87500.npz models/distilled/model.iter80000.npz models/distilled/model.iter77500.npz models/distilled/model.iter60000.npz models/distilled/model.iter95000.npz"
    ["ast"]="models/distilled/model.iter40000.npz models/distilled/model.iter37500.npz models/distilled/model.iter35000.npz models/distilled/model.iter30000.npz models/distilled/model.iter27500.npz models/distilled/model.iter25000.npz models/distilled/model.iter22500.npz"
    ["ara"]="models/distilled/model.iter210000.npz models/distilled/model.iter207500.npz"
)

declare -A LANG=(
	["arg"]="arg" ["ara"]="ara.xxx" ["ast"]="ast"
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
    
    hyp="data/submission_4/test.${lang}"

    echo "Translating..."

    if [ -e $hyp ]; then
        echo "Translation file already exists. Remove to overwrite."
    else 
        ${MARIAN}/marian-decoder -m $models -i data/test/flores200.spa-${tag}.tok --normalize 1 --beam-size 6 -v $vocab $vocab | ${MARIAN}/spm_decode --model $spm_target > $hyp
    fi
    
    echo "Done! Good luck with your submission :)"
    
done
