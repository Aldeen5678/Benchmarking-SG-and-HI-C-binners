#!/bin/bash
#SBATCH --job-name=aog_imputecc       # Job name
#SBATCH --partition=compute1          # Partition
#SBATCH --ntasks=1                    # Number of tasks (processes, always 1 for non-MPI jobs)
#SBATCH --nodes=1                     # Numner of nodes (Alway 1 for non-MPI jobs)
#SBATCH --cpus-per-task=80             # Cores per task
#SBATCH --time=24:00:00               # Time limit (hh:mm:ss)
#SBATCH --output=./logs/metacc.log        # Standard output file, or system will create a output file if output is not specified.
#SBATCH --mail-type=ALL
#SBATCH --mail-user=aaron.gonzalez@utsa.edu #Job status (starting, finishing, etc) will be sent to this email address. 

module load anaconda3
#source $(conda info --base)/etc/profile.d/conda.sh
conda activate ImputeCC_env


IMPUTE_CC_PATH=${1}
OUTPUT_DIR=${2}
CONTIGS=${3}
CONTIG_INFO=${4}
HIC_MATRIX=${5}
DAS_TOOL_PATH=${6}

# Start timer for internal logging
START_TIME=$(date +%s)


echo "Running ImputeCC  binning algorithm..."
RESULTS_DIR="${OUTPUT_DIR}/imputecc_results"

rm -rf ${RESULTS_DIR}

# Define a log file for resource usage
RESOURCE_LOG="${OUTPUT_DIR}/resource_usage.log"
echo "---  ImputeCC Resource Tracking ---" > $RESOURCE_LOG


BASH_CMD="python ${IMPUTE_CC_PATH}/ImputeCC.py pipeline ${CONTIGS} ${CONTIG_INFO} ${HIC_MATRIX} ${RESULTS_DIR}"
TIME_CMD="/usr/bin/time -a -o $RESOURCE_LOG --format='Command: %C\nElapsed Time: %E\nPeak RAM: %M KB\n'"

echo "Executing command: ${BASH_CMD}"
eval $TIME_CMD $BASH_CMD

echo "ImputeCC completed successfully.. Running Checkm2 on output bins"
conda deactivate
conda activate checkm2
checkm2 predict --threads 80 --input ${RESULTS_DIR}/FINAL_BIN --output-directory ${RESULTS_DIR}/checkm2 -x .fa


echo "CheckM2 completed successfully.. Generating contig-to-bin files..."
conda deactivate
conda activate das_tool
${DAS_TOOL_PATH}/src/Fasta_to_Contig2Bin.sh -e fa -i ${RESULTS_DIR}/FINAL_BIN > ${RESULTS_DIR}/contig_bins.tsv

