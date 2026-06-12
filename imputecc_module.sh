IMPUTE_CC_PATH=${1}
OUTPUT_DIR=${2}
CONTIGS=${3}
CONTIG_INFO=${4}
HIC_MATRIX=${5}
DAS_TOOL_PATH=${6}


RESULTS_DIR="${OUTPUT_DIR}/imputecc_results"

rm -rf ${RESULTS_DIR}
RESOURCE_LOG="${OUTPUT_DIR}/resource_usage.log"
BASH_CMD="python ${IMPUTE_CC_PATH}/ImputeCC.py pipeline ${CONTIGS} ${CONTIG_INFO} ${HIC_MATRIX} ${RESULTS_DIR}"
TIME_CMD="/usr/bin/time -a -o $RESOURCE_LOG --format='Command: %C\nElapsed Time: %E\nPeak RAM: %M KB\n'"

eval $TIME_CMD $BASH_CMD

