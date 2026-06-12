#!/bin/bash
#SBATCH --partition=compute1          
#SBATCH --ntasks=1                    
#SBATCH --nodes=1                     
#SBATCH --cpus-per-task=80             
#SBATCH --time=24:00:00             
#SBATCH --mail-type=ALL
#SBATCH --mail-user=aaron.gonzalez@utsa.edu

module load anaconda3
conda activate metahit_env

# Assign parameters

METAHIT_PROJECT_PATH=${1}
OUT=${2}
CONTIGS=${3}
FORWARD=${4}
REVERSE=${5}
ASSEMBLER=${6}


cd ${METAHIT_PROJECT_PATH}

python metahit.py alignment -p ./ -r ${CONTIGS} -1 ${FORWARD} -2 ${REVERSE} -o ${OUT} -t 80
