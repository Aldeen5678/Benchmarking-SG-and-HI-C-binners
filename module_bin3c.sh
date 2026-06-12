#!/bin/bash
#SBATCH --partition=compute1          
#SBATCH --ntasks=1                    
#SBATCH --nodes=1                     
#SBATCH --cpus-per-task=40             
#SBATCH --time=72:00:00                
#SBATCH --output=bin3c__%j.out
#SBATCH --error=bin3c__%j.err

# Load environment
source $(conda info --base)/etc/profile.d/conda.sh
#module load anaconda3
conda activate bin3c_env

# Start timer for internal logging
START_TIME=$(date +%s)

# Capture variables
OUT_DIR=${1}
CONTIGS=${2}
HIC_BAM=${3}


BIN3C_PATH="/work/dulab/Dia/Download2/bin3C/bin3C.py"
ENZYME="Sau3AI"
DB_PATH="/work/dulab/Dia/CheckM2_database/CheckM2_database/uniref100.KO.1.dmnd"

# Step 1: mkmap
MAP_OUT="${OUT_DIR}/contact_map"
rm -rf "$MAP_OUT"
echo "Starting Stage 1: mkmap at $(date)"
python2 "$BIN3C_PATH" mkmap -v -e "$ENZYME" "$CONTIGS" "$HIC_BAM" "$MAP_OUT" 2>&1

# Step 2: cluster
PGZ_FILE="${MAP_OUT}/contact_map.p.gz"
FINAL_BINS="${OUT_DIR}/final_bins"

if [ -f "$PGZ_FILE" ]; then
    echo "Starting Stage 2: cluster at $(date)"
    python2 "$BIN3C_PATH" cluster -v  "$PGZ_FILE"  "$FINAL_BINS" 2>&1
else
    echo "ERROR: Contact map .p.gz file not found."
    exit 1
fi

# --- RESOURCE REPORTING SECTION ---
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
echo "------------------------------------------------"
echo "JOB RESOURCE STATISTICS"
echo "------------------------------------------------"
echo "Script-calculated Duration: $((DURATION / 60)) minutes"
sleep 5
echo "Slurm Official Metrics for Job $SLURM_JOB_ID:"
sacct -j $SLURM_JOB_ID --format=JobID,JobName,Elapsed,MaxRSS,State
echo "------------------------------------------------"

echo "Running checkm2 on output bins..."
conda deactivate
conda activate checkm2

checkm2 predict --threads 80 --input ${FINAL_BINS}/fasta --output-directory ${OUT_DIR}/checkm2 --database_path "$DB_PATH"  -x .fna

