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
FORWARD=${3}
REVERSE=${4}
READ_TYPE=${5}


# Determine if --dedup should be used
DEDUP_FLAG=""
if [ "$READ_TYPE" == "HC" ]; then
    DEDUP_FLAG="--dedup"
fi

cd ${METAHIT_PROJECT_PATH}

# Execute command using parameters
python metahit.py preprocessing -p ./ -1 "$FORWARD" -2 "$REVERSE" -o "$OUT" $DEDUP_FLAG
