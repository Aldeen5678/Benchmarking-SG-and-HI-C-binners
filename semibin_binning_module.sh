CONTIGS=${2}
BAM_FILE=${3}
OUT=${1}
MODEL=${4}


rm -rf ${OUT}/output_bins
rm  ${OUT}/contig_bins.tsv

# Define a log file for resource usage
RESOURCE_LOG="${OUT}/resource_usage.log"


BASH_CMD="SemiBin2 single_easy_bin -i ${CONTIGS} -b ${BAM_FILE} -o ${OUT} --environment ${MODEL}"
TIME_CMD="/usr/bin/time -a -o $RESOURCE_LOG --format='Command: %C\nElapsed Time: %E\nPeak RAM: %M KB\n'"

echo "Executing the following command: ${BASH_CMD}"

eval $TIME_CMD $BASH_CMD

gunzip -r ${OUT}/output_bins

echo "Removing header from contig-to-bin file..."
sed -i '1d' ${OUT}/contig_bins.tsv





