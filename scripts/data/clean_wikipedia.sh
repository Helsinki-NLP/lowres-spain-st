#!/bin/bash
#SBATCH --job-name="clean_wikipedia"
#SBATCH -o logs/clean_wikipedia_oci_%j.out
#SBATCH -e logs/clean_wikipedia_oci_%j.err
#SBATCH --partition=small
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=8000
#SBATCH --account=project_2001194
#SBATCH --time=04:00:00

module load python-data
source venv/bin/activate

python scripts/clean_wikipedia_mono_nottranslated.py oci