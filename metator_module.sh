DAS_TOOL_PATH=${1}
OUTPUT_DIR=${2}
CONTIGS=${3}
FORWARD=${4}
REVERSE=${5}
enzyme="Sau3AI,MluCI"


cd $OUTPUT_DIR

# Define a log file for resource usage
RESOURCE_LOG="resource_usage.log"

export PATH="/path/to/your/env"

TIME_CMD="/usr/bin/time -a -o $RESOURCE_LOG --format='Command: %C\nElapsed Time: %E\nPeak RAM: %M KB\n'"

eval $TIME_CMD metator pipeline \
--assembly="$CONTIGS" \
--forward="$FORWARD" \
--reverse="$REVERSE" \
--outdir="$OUTPUT_DIR" \
--threads="80" \
--enzyme="$enzyme" \
--size=50000 \
--start=fastq







