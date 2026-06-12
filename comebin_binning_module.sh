#!/bin/bash
#SBATCH --job-name=hg_megahit_comebin       # Job name
#SBATCH --partition=compute1          # Partition
#SBATCH --ntasks=1                    # Number of tasks (processes, always 1 for non-MPI jobs)
#SBATCH --nodes=1                     # Numner of nodes (Alway 1 for non-MPI jobs)
#SBATCH --cpus-per-task=80             # Cores per task
#SBATCH --time=40:00:00               # Time limit (hh:mm:ss)
#SBATCH --output=./logs/hg_megahit_comebin.log        # Standard output file, or system will create a output file if output is not specified.
#SBATCH --mail-type=ALL
#SBATCH --mail-user=aaron.gonzalez@utsa.edu #Job status (starting, finishing, etc) will be sent to this email address. 

module load anaconda3
#source $(conda info --base)/etc/profile.d/conda.sh
conda activate comebin_env

OUT=${1}
CONTIGS=${2}
BAM_FILES_FOLDER=${3}

echo "Changing directory to ${OUT} to run COMEBin..."

# Define a log file for resource usage
RESOURCE_LOG="${OUT}/COMEBin_SRC/COMEBin/resource_usage.log"
echo "---  ComeBIN Resource Tracking ---" > $RESOURCE_LOG

BASH_CMD="bash ${OUT}/COMEBin_SRC/bin/run_comebin.sh -a ${CONTIGS} -o ${OUT}/COMEBin_SRC/COMEBin -t 80 -p ${BAM_FILES_FOLDER}"
TIME_CMD="/usr/bin/time -a -o $RESOURCE_LOG --format='Command: %C\nElapsed Time: %E\nPeak RAM: %M KB\n'"

echo "Running the following bash command ${BASH_CMD}"

eval $TIME_CMD $BASH_CMD
rc=$?

if [[ $rc -eq 0 ]]; then
    echo "COMEBin successfully ran. Running CheckM2 on bins..."
    conda deactivate

	conda activate checkm2
	checkm2 predict --threads 80 --input ${OUT}/COMEBin_SRC/COMEBin/comebin_res/comebin_res_bins/ --output-directory ${OUT}/COMEBin_SRC/COMEBin/comebin_res/checkm2 -x .fa

else
    echo "Command failed (return code is not 0)"
    # Add commands to run on failure
    exit 1
fi
