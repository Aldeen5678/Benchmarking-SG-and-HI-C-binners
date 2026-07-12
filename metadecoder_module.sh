OUTPUT_DIR=${2}
DAS_TOOL_PATH=${1}
BAM_FILE=${4}
CONTIGS=${3}

cd $OUTPUT_DIR


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


