METACC_PATH=${1}
OUTPUT_DIR=${2}
CONTIGS=${3}
BAM_FILE=${4}
DASTOOL_PATH=${5}
ENZYME=""

echo "Running METADECODER binning algorithm..."
RESULTS_DIR="${OUTPUT_DIR}/metacc_results"

rm -rf ${RESULTS_DIR}

BASH_CMD="python ${METACC_PATH}/MetaCC.py norm -e ${ENZYME} ${CONTIGS} ${BAM_FILE} ${RESULTS_DIR}"
echo "Executing command: ${BASH_CMD}"
eval $BASH_CMD

BASH_CMD="python ${METACC_PATH}/MetaCC.py bin --cover ${CONTIGS} ${RESULTS_DIR}"
echo "Executing command: ${BASH_CMD}"
eval $BASH_CMD

# --- RESOURCE REPORTING SECTION ---
-----------------------------------------"

echo "Creating contig-to-bin files"
conda deactivate
conda activate das_tool
${DASTOOL_PATH}/src/Fasta_to_Contig2Bin.sh -e fa -i ${RESULTS_DIR}/BIN > ${RESULTS_DIR}/contig_bins.tsv


