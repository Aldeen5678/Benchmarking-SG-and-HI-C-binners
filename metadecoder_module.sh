#!/bin/bash
#SBATCH --job-name=aog_metadecoder       # Job name
#SBATCH --partition=compute1          # Partition
#SBATCH --ntasks=1                    # Number of tasks (processes, always 1 for non-MPI jobs)
#SBATCH --nodes=1                     # Numner of nodes (Alway 1 for non-MPI jobs)
#SBATCH --cpus-per-task=80             # Cores per task
#SBATCH --time=72:00:00               # Time limit (hh:mm:ss)
#SBATCH --output=./logs/metadecoder.log        # Standard output file, or system will create a output file if output is not specified.
#SBATCH --mail-type=ALL
#SBATCH --mail-user=aaron.gonzalez@utsa.edu #Job status (starting, finishing, etc) will be sent to this email address. 

module load anaconda3
#source $(conda info --base)/etc/profile.d/conda.sh
conda activate metadecoder_env

OUTPUT_DIR=${2}
DAS_TOOL_PATH=${1}
BAM_FILE=${4}
CONTIGS=${3}

cd $OUTPUT_DIR

#RESOURCE_LOG="resource_usage.log"
#echo "---  Metadecoder Resource Tracking ---" > $RESOURCE_LOG
#TIME_CMD="/usr/bin/time -a -o $RESOURCE_LOG --format='Command: %C\nElapsed Time: %E\nPeak RAM: %M KB\n'"

# Start timer for internal logging
START_TIME=$(date +%s)

if [ -f "METADECODER.COVERAGE" ]; then
    echo "METADECODER.COVERAGE exists and is a regular file... Proceeding with SEED file generator..."
else
    echo "The file METADECODER.COVERAGE does not exist..."
    echo "Generating coverage file.."
    echo "Generating resource usage  for coverage" >> $RESOURCE_LOG
    BASH_CMD="metadecoder coverage -b ${BAM_FILE} -o ./METADECODER.COVERAGE"
    echo "Executing command: ${BASH_CMD}"
    eval $BASH_CMD
fi

if [ -f "METADECODER.SEED" ]; then
    echo "METADECODER.SEED exists and is a regular file... Proceeding with Metadecoder algorithm..."
else
    echo "The file METADECODER.COVERAGE does not exist..."
    echo "Generating seed file.."
    BASH_CMD="metadecoder seed --threads 80 -f ${CONTIGS} -o ./METADECODER.SEED"

    echo "Executing command: ${BASH_CMD}"
    echo "Generating resource usage for seed value generation"
    eval $BASH_CMD
fi


echo "Running METADECODER binning algorithm..."
BASH_CMD="metadecoder cluster -f ${CONTIGS} -c ./METADECODER.COVERAGE -s ./METADECODER.SEED -o METADECODER"
echo "Executing command: ${BASH_CMD}"
echo "Generating resource usage for clustering" >> $RESOURCE_LOG
eval $BASH_CMD

# --- RESOURCE REPORTING SECTION ---
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
echo "------------------------------------------------"
echo "JOB RESOURCE STATISTICS"
echo "------------------------------------------------"
echo "Script-calculated Duration: $((DURATION / 60)) minutes"
sleep 20
echo "Slurm Official Metrics for Job $SLURM_JOB_ID:"
sacct -j $SLURM_JOB_ID --format=JobID,JobName,Elapsed,MaxRSS,State
echo "------------------------------------------------"

echo "Creating output_bins folder for FASTA files..."
mkdir -p ./output_bins
mv *.fasta output_bins/

conda deactivate
conda activate checkm2

echo "Running CheckM2 on output_bins folder"
checkm2 predict --threads 80 --input ./output_bins --output-directory ./checkm2  -x .fasta

echo "Generating contig-to-bin file from output_bins..."
conda deactivate
conda activate das_tool
${DAS_TOOL_PATH}/src/Fasta_to_Contig2Bin.sh -e fasta -i ./output_bins > ./contig_bins.tsv
