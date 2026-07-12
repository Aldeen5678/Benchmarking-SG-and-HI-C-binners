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

BINNER1_BIN_PATH=${3}
BINNER2_BIN_PATH=${4}
BINNER3_BIN_PATH=${5}


BASH_CMD="sh ${bin_refinement_path}/bin_refinement.sh -o ./ -t 80 -A ${BINNER1_BIN_PATH} -B ${BINNER2_BIN_PATH} -C ${BINNER3_BIN_PATH}"
echo "Executing the following command: ${BASH_CMD}"

export LC_ALL=C
echo "LC_ALL is set to: $LC_ALL"

eval $TIME_CMD $BASH_CMD

