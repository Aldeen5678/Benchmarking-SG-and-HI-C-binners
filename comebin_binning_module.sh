OUT=${1}
CONTIGS=${2}
BAM_FILES_FOLDER=${3}

echo "Changing directory to ${OUT} to run COMEBin..."

# Define a log file for resource usage
RESOURCE_LOG="${OUT}/COMEBin_SRC/COMEBin/resource_usage.log"

BASH_CMD="bash ${OUT}/COMEBin_SRC/bin/run_comebin.sh -a ${CONTIGS} -o ${OUT}/COMEBin_SRC/COMEBin -t 80 -p ${BAM_FILES_FOLDER}"
TIME_CMD="/usr/bin/time -a -o $RESOURCE_LOG --format='Command: %C\nElapsed Time: %E\nPeak RAM: %M KB\n'"

eval $TIME_CMD $BASH_CMD




	
