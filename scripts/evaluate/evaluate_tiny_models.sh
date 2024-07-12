#!/bin/bash
#SBATCH --job-name="evaluate_lumi_%j.sh"
#SBATCH --account=project_2001194
#SBATCH --output=logs/evaluate_lumi_%j.out
#SBATCH --error=logs/evaluate_lumi_%j.err
#SBATCH --time=00:15:00
#SBATCH --partition=gputest
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=32G
#SBATCH --gres=gpu:v100:1
#SBATCH --cpus-per-task=10

module load python-data
source venv/bin/activate

# Declare dev set

declare -A SRC=(
	["ara"]="dev.ara.ara.source.tok"
    ["arg"]="dev.arg.source.tok"
    ["ast"]="dev.ast.source.tok"
)

spm_target="models/OPUS-MT+bibles/deu+eng+fra+por+spa-itc/opus+jhubc.trg.spm32k-model"
MARIAN="/scratch/project_2005815/degibert/marian-dev/build"
vocab="models/OPUS-MT+bibles/deu+eng+fra+por+spa-itc/opusTCv20230926max50+bt+jhubc.spm32k-spm32k.vocab.yml"


for model in "tiny_nmt" "tiny_nmt_ft" "tiny_nmt_rbmt" "tiny_nmt_rbmt_ft"; do
    for lang in "${!SRC[@]}"; do
        src="data/FLORES+/${SRC[$lang]}"
        trg="data/FLORES+/dev.${lang}"

        model_dir="models/lumi/${model}"
        modelckp="${model_dir}/final.model.npz.best-bleu.npz"
        outfile="${model_dir}/hyp.${lang}"
        if [ -e ${outfile} ]; then
            echo "Translation file already exists. Remove to overwrite."
        else 
            echo "### Translation"
            ${MARIAN}/marian-decoder -i ${src} -m ${modelckp} --normalize 1 --beam-size 1 -v ${vocab} ${vocab} -d 0 --word-penalty 0 --mini-batch 64 --maxi-batch 100 --maxi-batch-sort src | ${MARIAN}/spm_decode --model ${spm_target} > ${outfile}
        fi
       
        echo "### Evaluation"

        # Get the BLEU score and write it to another temporary file
        bleu=$(sacrebleu ${trg} -i ${outfile} -m bleu -w 4 --score-only)

        echo ${lang} ${bleu} >> "${model_dir}/bleu.txt"

    done
done