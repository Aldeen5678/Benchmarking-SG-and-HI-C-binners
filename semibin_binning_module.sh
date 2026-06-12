#!/bin/bash
#SBATCH --job-name=hg_megahit_semibin2       # Job name
#SBATCH --partition=compute1          # Partition
#SBATCH --ntasks=1                    # Number of tasks (processes, always 1 for non-MPI jobs)
#SBATCH --nodes=1                     # Numner of nodes (Alway 1 for non-MPI jobs)
#SBATCH --cpus-per-task=80             # Cores per task
#SBATCH --time=24:00:00               # Time limit (hh:mm:ss)
#SBATCH --output=./logs/hg_megahit_semibin2.log        # Standard output file, or system will create a output file if output is not specified.
#SBATCH --mail-type=ALL
#SBATCH --mail-user=aaron.gonzalez@utsa.edu #Job status (starting, finishing, etc) will be sent to this email address. 

module load anaconda3
#source $(conda info --base)/etc/profile.d/conda.sh
#conda activate semibin_env
conda activate SemiBin2

CONTIGS=${2}
BAM_FILE=${3}
OUT=${1}
MODEL=${4}

echo "Removing output path ${OUT}/checkm2 to ensure new run"
rm -rf ${OUT}/checkm2
rm -rf ${OUT}/output_bins
rm  ${OUT}/contig_bins.tsv

# Define a log file for resource usage
RESOURCE_LOG="${OUT}/resource_usage.log"
echo "---  Semibin2 Resource Tracking ---" > $RESOURCE_LOG

BASH_CMD="SemiBin2 single_easy_bin -i ${CONTIGS} -b ${BAM_FILE} -o ${OUT} --environment ${MODEL}"
TIME_CMD="/usr/bin/time -a -o $RESOURCE_LOG --format='Command: %C\nElapsed Time: %E\nPeak RAM: %M KB\n'"

echo "Executing the following command: ${BASH_CMD}"

eval $TIME_CMD $BASH_CMD

echo "SemiBin2 completed successfully. Decompressing the output bin files..."
gunzip -r ${OUT}/output_bins

echo "Removing header from contig-to-bin file..."
sed -i '1d' ${OUT}/contig_bins.tsv


echo "Output bins decompressed. Running CheckM2 on bins..."
conda deactivate

conda activate checkm2
checkm2 predict --threads 80 --input ${OUT}/output_bins --output-directory ${OUT}/checkm2 -x .fa


