#!/bin/bash
#SBATCH --job-name="tokenize_data"
#SBATCH -o logs/tokenize_data_%j.out
#SBATCH -e logs/tokenize_data_%j.err
#SBATCH --partition=test
#SBATCH --account=project_2001194
#SBATCH --time=00:15:00

declare -A LANG=(
	["arg"]="arg" ["ast"]="ast" ["oci"]="oci" ["ara"]="oci" # In case we want to add a different target language tag for aranese
)

# OPUS+bibles model

modeldir="models/OPUS-MT+bibles/deu+eng+fra+por+spa-itc/"
spm_source="opus+jhubc.src.spm32k-model"
spm_target="opus+jhubc.trg.spm32k-model"

MARIAN="/scratch/project_2005815/degibert/marian-dev/build"

### Dev data ##

# Concat train data per language pair, tokenize add target language tag
for lang in "${!LANG[@]}"; do
    echo "Processing development data for ${lang}..."
    tag=${LANG[$lang]}
    # Tokenize data and translate
    cat data/FLORES+/dev.spa | ${MARIAN}/spm_encode --model $modeldir/$spm_source |  sed "s/^/>>${tag}<< /" > data/FLORES+/dev.${lang}.source.tok
    cat data/FLORES+/dev.${lang} | ${MARIAN}/spm_encode --model $modeldir/$spm_target > data/FLORES+/dev.${lang}.target.tok
    echo "Done!"
done

# Concat all dev data
cat data/FLORES+/dev.arg.source.tok  data/FLORES+/dev.ast.source.tok data/FLORES+/dev.ara.source.tok > data/train/dev.src.tok
cat data/FLORES+/dev.arg.target.tok  data/FLORES+/dev.ast.target.tok data/FLORES+/dev.ara.target.tok > data/train/dev.trg.tok

### Training data ###

# Concat train data per language pair, tokenize add target language tag
for lang in "${!LANG[@]}"; do
    echo "Processing training data for ${lang}..."
    tag=${LANG[$lang]}
    cat data/train/tatoeba.clean.spa-${lang}.spa data/train/synt.clean.spa-${lang}.spa | ${MARIAN}/spm_encode --model $modeldir/$spm_source | sed "s/^/>>${tag}<< /" > data/train/train.spa-${lang}.spa.tok
    cat data/train/tatoeba.clean.spa-${lang}.${lang} data/train/synt.clean.spa-${lang}.${lang} | ${MARIAN}/spm_encode --model $modeldir/$spm_target > data/train/train.spa-${lang}.${lang}.tok
    echo "Done!"
done

# Concat all train data
cat data/train/train.spa-arg.spa.tok data/train/train.spa-ast.spa.tok data/train/train.spa-oci.spa.tok data/train/train.spa-ara.spa.tok > data/train/train.src.tok
cat data/train/train.spa-arg.arg.tok data/train/train.spa-ast.ast.tok data/train/train.spa-oci.oci.tok data/train/train.spa-ara.ara.tok > data/train/train.trg.tok