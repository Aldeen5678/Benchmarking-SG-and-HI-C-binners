#!/bin/bash
#SBATCH --job-name=metator_pipeline
#SBATCH --partition=compute1
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=80
#SBATCH --time=10:00:00
#SBATCH --output=./metator_pipeline.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=aaron.gonzalez@utsa.edu


set -e


# Positional Arguments
DAS_TOOL_PATH=${1}
OUTPUT_DIR=${2}
CONTIGS=${3}
FORWARD=${4}
REVERSE=${5}
enzyme="Sau3AI,MluCI"
DB_PATH="/work/dulab/Dia/CheckM2_database/CheckM2_database/uniref100.KO.1.dmnd"


echo "Switching to $OUTPUT_DIR for binning outputs..."
cd $OUTPUT_DIR

# Define a log file for resource usage
RESOURCE_LOG="resource_usage.log"
echo "--- Metator Resource Tracking ---" > $RESOURCE_LOG

#module load anaconda3

source $(conda info --base)/etc/profile.d/conda.sh
conda activate metator_env

export PATH="/work/bni707/miniconda3/envs/metator_env/bin:$PATH"

# Formatting the /usr/bin/time output: 
# %E = Elapsed time, %M = Max RAM in KB
TIME_CMD="/usr/bin/time -a -o $RESOURCE_LOG --format='Command: %C\nElapsed Time: %E\nPeak RAM: %M KB\n'"


echo "Running metator binning..."

eval $TIME_CMD metator pipeline \
--assembly="$CONTIGS" \
--forward="$FORWARD" \
--reverse="$REVERSE" \
--outdir="$OUTPUT_DIR" \
--threads="80" \
--enzyme="$enzyme" \
--size=50000 \
--start=fastq

conda deactivate

# --- CheckM2 & DAS Tool Prep ---
conda activate checkm2
echo "Running CheckM2..."
checkm2 predict --threads 80 --input ./overlapping_bin --output-directory ./checkm2 --database_path "$DB_PATH" -x .fa 

conda deactivate
conda activate das_tool
echo "Generating DAS Tool files..."
bash ${DAS_TOOL_PATH}/src/Fasta_to_Contig2Bin.sh -e fa -i ./overlapping_bin > ./metator_contig_bins.tsv

echo "All tasks complete. Check $RESOURCE_LOG for runtime and RAM stats."




