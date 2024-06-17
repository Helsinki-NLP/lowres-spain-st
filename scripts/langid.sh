#!/bin/bash
#SBATCH --job-name=langid
#SBATCH --account=project_2001194
#SBATCH --time=24:15:00
#SBATCH --mem-per-cpu=16G
#SBATCH --partition=small
#SBATCH --output=packages/logs/langid_%j.out
#SBATCH --error=packages/logs/langid_%j.err
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mikko.aulamo@helsinki.fi
#SBATCH --gres=nvme:100

module load python-data
source /scratch/project_2001194/lowres-spain/packages/langid_env/bin/activate

#file_prefix=$1
data_path=$1
file_name=$2
lid=$3

#zcat ${file_prefix}.gz | split -C 150M - $LOCAL_SCRATCH/spa-${lid}_${lid}
split -C 150M ${data_path}/${file_name} ${LOCAL_SCRATCH}/${file_name}.${lid}

for tmp_file in `ls ${LOCAL_SCRATCH}/${file_name}.${lid}*`
do
    cat ${tmp_file} | python packages/idiomata_cognitor/lang_identification.py --model packages/idiomata_cognitor/model.pkl > ${tmp_file}.lid
done

cat ${LOCAL_SCRATCH}/${file_name}.${lid}*.lid > ${data_path}/${file_name}.lid

echo ${data_path}/${file_name}.lid
awk -F'\t' '{print $2}' ${data_path}/${file_name}.lid | sort | uniq -c | sort -n -r
