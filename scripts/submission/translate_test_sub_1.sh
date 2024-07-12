#!/bin/bash
#SBATCH --job-name="sub_1_%j.sh"
#SBATCH --account=project_2001194
#SBATCH --output=logs/sub_1_%j.out
#SBATCH --error=logs/sub_1_%j.err
#SBATCH --time=02:00:00
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=32G
#SBATCH --gres=gpu:v100:1
#SBATCH --cpus-per-task=10

declare -A CKP=(
	["arg"]="models/opus+bibles_ft_all_2_bleu/model.iter15000.npz models/opus+bibles_ft_all_2_bleu/model.iter17500.npz models/opus+bibles_ft_all_2_bleu/model.iter10000.npz"
    ["ast"]="models/opus+bibles_ft_all_2_bleu/model.iter10000.npz models/opus+bibles_ft_all_2_bleu/model.iter12500.npz models/opus+bibles_ft_no_oci_bleu/model.iter5000.npz"
    ["ara"]="models/opus+bibles_ft_no_oci_bleu/model.iter55000.npz models/opus+bibles_ft_no_oci_bleu/model.iter62500.npz models/opus+bibles_ft_no_oci_bleu/model.iter57500.npz models/opus+bibles_ft_no_oci_bleu/model.iter52500.npz models/opus+bibles_ft_no_oci_bleu/model.iter60000.npz models/opus+bibles_ft_no_oci_bleu/model.iter37500.npz"
)


declare -A LANG=(
	["arg"]="arg" ["ara"]="oci" ["ast"]="ast"
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

    #cat $src | ${MARIAN}/spm_encode --model $spm_source | sed "s/^/>>${tag}<< /" > data/test/flores200.spa-${lang}.tok
    
    #echo "Created data/test/flores200.spa-${lang}.tok file..."

    # ------- TRANSLATION -----
    
    hyp="data/submission_1/test.${lang}"

    echo "Translating..."

    if [ -e $hyp ]; then
        echo "Translation file already exists. Remove to overwrite."
    else 
        #${MARIAN}/marian-decoder -m $models -i data/test/flores200.spa-${lang}.tok --normalize 1 --beam-size 6 -d 0 -v $vocab $vocab --n-best > $hyp # | ${MARIAN}/spm_decode --model $spm_target > $hyp
        ${MARIAN}/marian-decoder -m $models -i data/test/flores200.spa-${lang}.tok --normalize 1 --beam-size 5 -d 0 -v $vocab $vocab | ${MARIAN}/spm_decode --model $spm_target > $hyp
    fi
    
    echo "Done! Good luck with your submission :)"
    
done