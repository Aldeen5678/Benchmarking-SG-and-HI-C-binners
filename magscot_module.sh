#!/bin/bash
#SBATCH --job-name=aog_prodigal       # Job name
#SBATCH --partition=compute1          # Partition
#SBATCH --ntasks=1                    # Number of tasks (processes, always 1 for non-MPI jobs)
#SBATCH --nodes=1                     # Numner of nodes (Alway 1 for non-MPI jobs)
#SBATCH --cpus-per-task=80             # Cores per task
#SBATCH --time=10:00:00               # Time limit (hh:mm:ss)
#SBATCH --output=./logs/prodigal.log        # Standard output file, or system will create a output file if output is not specified.
#SBATCH --mail-type=ALL
#SBATCH --mail-user=aaron.gonzalez@utsa.edu #Job status (starting, finishing, etc) will be sent to this email address. 

module load anaconda3
#source $(conda info --base)/etc/profile.d/conda.sh
conda activate magscot

MAGSCOT_SRC=${1}
OUT=${2}
CONTIGS=${3}
COMEBIN_CONTIG2BIN=${4}
METACC_CONTIG2BIN=${5}
IMPUTECC_CONTIG2BIN=${6}

process_tsv() {
    local file_path="$1"
    local binner_name="$2"
    local output_file="preprocessed_${binner_name}_$(basename "$file_path")"

    # Check if file exists
    if [[ ! -f "$file_path" ]]; then
        echo "Error: File '$file_path' not found."
        return 1
    fi

    # Use awk to process the columns
    # 1. Sets input and output field separator to Tab (\t)
    # 2. Prints: Original Col 2, Original Col 1, and the New Value
    awk -v binner="$binner_name" 'BEGIN {FS="\t"; OFS="\t"} {print $2, $1, binner}' "$file_path" > "$output_file"

    echo "Success! Processed file saved as: $output_file"
}


echo "Switching to directory ${OUT} for magscot processing"
cd $OUT


if [ -f "proteins.faa" ]; then
    echo "proteins.faa exists and is a regular file... Proceeding with HMM"
else
    echo "The file proteins.faa does not exist..."
    echo "Generating prodigal protein file..."
	BASH_CMD="cat ${CONTIGS}| prodigal -p meta -a ${OUT}/proteins.faa -d ${OUT}/nucleotides.ffn -o ${OUT}/gene_coordinates.gpk"

	echo "Executing command: ${BASH_CMD}"
	eval $BASH_CMD
fi


if [ -f "out.hmm" ]; then
    echo "out.hmm exists and is a regular file. Proceeding with MAGScot processing..."
else

	echo "Running hmm against ${OUT}/proteins.faa"

	hmmsearch -o hmm_raw.tigr.out --tblout hmm_tbl.tigr.hit.out --noali --notextw --cut_nc --cpu 8 ${MAGSCOT_SRC}/hmm/gtdbtk_rel207_tigrfam.hmm ./proteins.faa
	hmmsearch -o hmm_raw.pfam.out --tblout hmm_tbl.pfam.hit.out --noali --notextw --cut_nc --cpu 8 ${MAGSCOT_SRC}/hmm/gtdbtk_rel207_Pfam-A.hmm ./proteins.faa

	echo "Combining hmm into combined output..."

	cat hmm_tbl.tigr.hit.out | grep -v "^#" | awk '{print $1"\t"$3"\t"$5}' > hmm_tmp.tigr
	cat hmm_tbl.pfam.hit.out | grep -v "^#" | awk '{print $1"\t"$4"\t"$5}' > hmm_tmp.pfam

	cat hmm_tmp.pfam hmm_tmp.tigr > out.hmm
fi


	echo "Generating custom contig-to-bins for MAGScot processing..."

	process_tsv $COMEBIN_CONTIG2BIN "comebin"
	process_tsv $METACC_CONTIG2BIN "metacc"
	process_tsv $IMPUTECC_CONTIG2BIN "imputecc"

	cat  "preprocessed_comebin_$(basename "$COMEBIN_CONTIG2BIN")" "preprocessed_metacc_$(basename "$METACC_CONTIG2BIN")" "preprocessed_imputecc_$(basename "$IMPUTECC_CONTIG2BIN")" > magscot_contig_to_bins.tsv


Rscript ${MAGSCOT_SRC}/MAGScoT.R -i magscot_contig_to_bins.tsv --hmm out.hmm

echo "Generating MAGScot bins..."
cd /work/dulab/Shared/ablation_study_automated_scripts/magscot
python ./magscot_bins.py --fasta ${CONTIGS} --ctg2bin "${OUT}/MAGScoT.refined.contig_to_bin.out" --outdir "${OUT}/FINAL_BINS"


conda deactivate
conda activate checkm2

echo "Running CheckM2 on MAGScot generated bins..."
checkm2 predict --threads 80 --input ${OUT}/FINAL_BINS --output-directory ${OUT}/checkm2 -x .fa
