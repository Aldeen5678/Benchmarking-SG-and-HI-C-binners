#!/bin/bash
#SBATCH --job-name=ww_megahit_metawrap       # Job name
#SBATCH --partition=compute1          # Partition
#SBATCH --ntasks=1                    # Number of tasks (processes, always 1 for non-MPI jobs)
#SBATCH --nodes=1                     # Numner of nodes (Alway 1 for non-MPI jobs)
#SBATCH --cpus-per-task=80             # Cores per task
#SBATCH --time=10:00:00               # Time limit (hh:mm:ss)
#SBATCH --output=./logs/ww_megahit_metawrap.log        # Standard output file, or system will create a output file if output is not specified.
#SBATCH --mail-type=ALL
#SBATCH --mail-user=aaron.gonzalez@utsa.edu #Job status (starting, finishing, etc) will be sent to this email address. 

module load anaconda3
conda activate metahit_env


METAHIT_PROJECT_PATH=${1}
bin_refinement_path=${METAHIT_PROJECT_PATH}/modules/6_binning/scripts
OUT=${2}

echo "Switching to directory ${OUT}"
cd ${OUT}

# Define a log file for resource usage
RESOURCE_LOG="resource_usage.log"
echo "--- Metawrap Resource Tracking ---" > $RESOURCE_LOG

# Formatting the /usr/bin/time output: 
# %E = Elapsed time, %M = Max RAM in KB
TIME_CMD="/usr/bin/time -a -o $RESOURCE_LOG --format='Command: %C\nElapsed Time: %E\nPeak RAM: %M KB\n'"

echo "Running metawrap refinment..."

COMEBIN_BIN_PATH=${3}
IMPUTECC_BIN_PATH=${4}
METACC_BIN_PATH=${5}


BASH_CMD="sh ${bin_refinement_path}/bin_refinement.sh -o ./ -t 80 -A ${COMEBIN_BIN_PATH} -B ${IMPUTECC_BIN_PATH} -C ${METACC_BIN_PATH}"
echo "Executing the following command: ${BASH_CMD}"

export LC_ALL=C
echo "LC_ALL is set to: $LC_ALL"

eval $TIME_CMD $BASH_CMD

