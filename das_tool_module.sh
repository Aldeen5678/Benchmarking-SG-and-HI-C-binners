#!/bin/bash
#SBATCH --job-name=aog_das_tool       # Job name
#SBATCH --partition=compute1          # Partition
#SBATCH --ntasks=1                    # Number of tasks (processes, always 1 for non-MPI jobs)
#SBATCH --nodes=1                     # Numner of nodes (Alway 1 for non-MPI jobs)
#SBATCH --cpus-per-task=80             # Cores per task
#SBATCH --time=10:00:00               # Time limit (hh:mm:ss)
#SBATCH --output=./logs/dastool.log        # Standard output file, or system will create a output file if output is not specified.
#SBATCH --mail-type=ALL
#SBATCH --mail-user=aaron.gonzalez@utsa.edu #Job status (starting, finishing, etc) will be sent to this email address. 

module load anaconda3
#source $(conda info --base)/etc/profile.d/conda.sh
conda activate das_tool

CONTIGS=${2}
COMEBIN_CONTIG2BIN=${3}
METACC_CONTIG2BIN=${4}
IMPUTECC_CONTIG2BIN=${5}
OUT=${1}/

CMD="DAS_Tool -i ${COMEBIN_CONTIG2BIN},${METACC_CONTIG2BIN},${IMPUTECC_CONTIG2BIN} -l "COMEBin","MetaCC","ImputeCC" -c ${CONTIGS} -o ${OUT} --write_bins"
echo "Running the following command: ${CMD}"

eval $CMD

echo "DasTool successfully ran. Running CheckM2 on bins..."
conda deactivate
conda activate checkm2
checkm2 predict --threads 80 --input ${OUT}_DASTool_bins --output-directory ${OUT}checkm2 -x .fa
