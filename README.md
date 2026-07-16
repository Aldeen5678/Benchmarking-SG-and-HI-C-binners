# Benchmarking SG and Hi-C Binners

This repository contains the modules used to benchmark shotgun (SG) and Hi-C-based binning methods with metagenomic datasets.

## Description

We compared three Shot gun based binners: COMEBin, Semibin2 and Metadecoder with three Hi-C based binners: bin3c, Metacc and ImputeCC to evaluate bin quality of shot gun and Hi-C based datasets across five different environments- human gut, pig gut, wastewater, hydrothermal mats and bovine rumen.Three bin refinements: MAGScoT, Metawrap and DASTool were used to examine the overall improvement of MAG recovery.GTDBTK software was used to assess MAG taxonomy recovery across the binners and bin refinements tools.

## Getting Started

### 1. Clone the repository

Clone the repository and make the modules executable:

```bash
git clone https://github.com/Aldeen5678/Benchmarking-SG-and-HI-C-binners.git
cd Benchmarking-SG-and-HI-C-binners
chmod +x *.sh
```

Install METAHIT software using the following link https://github.com/dyxstat/METAHIT#installation for steps 2,3 and 4

### 2. Preprocessing

Preprocess shotgun and Hi-C paired-end reads with `metahit_preprocessing.sh`.

```bash
./metahit_preprocessing.sh METAHIT_PROJECT_PATH OUTPUT_PATH FORWARD_READS REVERSE_READS READ_TYPE
```

| Argument | Description |
| --- | --- |
| `METAHIT_PROJECT_PATH` | Path to the MetaHiT installation. |
| `OUTPUT_PATH` | Output directory for preprocessed reads. |
| `FORWARD_READS` | Read 1 FASTQ file. |
| `REVERSE_READS` | Read 2 FASTQ file. |
| `READ_TYPE` | Use `SG` for shotgun reads or `HC` for Hi-C reads. |
| `dedup` |enables deduplication for Hi-c reads. |


Example:

```bash
./metahit_preprocessing.sh /path/to/MetaHiT results/sg_preprocessed \
  reads/sg_R1.fastq.gz reads/sg_R2.fastq.gz SG

./metahit_preprocessing.sh /path/to/MetaHiT results/hic_preprocessed \
  reads/hic_R1.fastq.gz reads/hic_R2.fastq.gz HC --dedup
```


### 3. Assembly

Assemble the cleaned shotgun reads with `metahit_assembly_module.sh`:

```bash
./metahit_assembly_module.sh METAHIT_PROJECT_PATH OUTPUT_PATH FORWARD_READS REVERSE_READS ASSEMBLER
```

| Argument | Description |
| --- | --- |
| `METAHIT_PROJECT_PATH` | Path to the MetaHiT installation. |
| `OUTPUT_PATH` | Assembly output directory. |
| `FORWARD_READS` | Preprocessed shotgun read 1 file. |
| `REVERSE_READS` | Preprocessed shotgun read 2 file. |
| `ASSEMBLER` | `megahit` or `metaspades` -choose one assembler. |

Example:

```bash
./metahit_assembly_module.sh /path/to/MetaHiT results/assembly \
  /path/to/sg_clean_R1.fastq.gz /path/to/sg_clean_R2.fastq.gz megahit
```


```bash
./metahit_assembly_module.sh /path/to/MetaHiT results/assembly \
  /path/to/sg_clean_R1.fastq.gz /path/to/sg_clean_R2.fastq.gz metaspades
```

### 4. Hi-C alignment

Align cleaned Hi-C reads to the assembly using `metahit_alignment_module.sh`

```bash
./metahit_alignment_module.sh METAHIT_PROJECT_PATH OUTPUT_PATH CONTIGS FORWARD_READS REVERSE_READS 
```
| Argument | Description |
| --- | --- |
| `METAHIT_PROJECT_PATH` | Path to the MetaHiT installation. |
| `OUTPUT_PATH` | Assembly output directory. |
| `FORWARD_READS` | Preprocessed shotgun read 1 file. |
| `REVERSE_READS` | Preprocessed shotgun read 2 file. |
| `CONTIGS` | Path to the assembled contigs.|
 
Example:

```bash
 ./metahit_alignment_module.sh /path/to/MetaHiT results/alignment "$CONTIGS" \
  /path/to/hic_clean_R1.fastq.gz /path/to/hic_clean_R2.fastq.gz 
```

### 5. COMEBin
Install COMEBin by following the https://github.com/ziyewang/COMEBin#install-comebin-via-bioconda
Run COMEBin with an assembly and a directory containing BAM files:

```bash
./comebin_binning_module.sh OUTPUT_PATH CONTIGS BAM_FILES_FOLDER
```

Example:

```bash
./comebin_binning_module.sh results/comebin "$CONTIGS" /path/to/bam_files
```

The module writes COMEBin results to `OUTPUT_PATH/COMEBin_SRC/COMEBin` and records run time and peak RAM in `resource_usage.log`.

### 6. SemiBin2
Install Semibin2 by following https://github.com/BigDataBiology/SemiBin#installation-with-conda
Run SemiBin2 in `single_easy_bin` mode:

```bash
./semibin_binning_module.sh OUTPUT_PATH CONTIGS BAM_FILE MODEL
```

Example:

```bash
./semibin_binning_module.sh results/semibin "$CONTIGS" "$HIC_BAM" human_gut/pig_gut/wastewater/global
```

| Argument | Description |
| --- | --- |
| `OUTPUT_PATH` | Output directory. |
| `CONTIGS` | Assembly FASTA file. |
| `BAM_FILE` | Alignment BAM file. |
| `MODEL` | SemiBin2 model appropriate to the sample. |

The module decompresses `output_bins` and removes the header from `contig_bins.tsv`.

### 7. MetaDecoder
Install MetaDecoder by following the https://github.com/liu-congcong/MetaDecoder#installation


```bash
./metadecoder_module.sh DAS_TOOL_PATH OUTPUT_PATH CONTIGS BAM_FILE
```

Example:

```bash
./metadecoder_module.sh /path/to/das_tool results/metadecoder "$CONTIGS" "$HIC_BAM"
```

The module generates coverage and seed files, runs clustering, writes FASTA bins to `output_bins`, evaluates them with CheckM2, and creates `contig_bins.tsv` using DAS Tool.

### 8. MetaCC
Install MetaCC by following the https://github.com/dyxstat/MetaCC#installation-guide


```bash
 ./metacc_module.sh METACC_PATH OUTPUT_PATH CONTIGS BAM_FILE DASTOOL_PATH
```

Example:

```bash
./metacc_module.sh /path/to/MetaCC results/metacc "$CONTIGS" "$HIC_BAM" /path/to/das_tool
```

| Argument | Description |
| --- | --- |
| `METACC_PATH` | Path to the MetaCC installation. |
| `OUTPUT_PATH` | Output directory. |
| `CONTIGS` | Assembly FASTA file. |
| `BAM_FILE` | Hi-C alignment BAM file. |
| `DASTOOL_PATH` | Path to the DAS Tool installation. |

The module uses `Sau3AI` by default. Change the `ENZYME` variable if your Hi-C library used a different enzyme. Results are written to `metacc_results/`, including `BIN/`, CheckM2 output, and `contig_bins.tsv`.

### 9. ImputeCC
Install ImputeCC by following the https://github.com/dyxstat/ImputeCC#installation-guide
Prepare the contig-information file and Hi-C matrix from MetaCC required by ImputeCC, then run:

```bash
./imputecc_module.sh IMPUTE_CC_PATH OUTPUT_PATH CONTIGS CONTIG_INFO HIC_MATRIX 
```

Example:

```bash
./imputecc_module.sh /path/to/ImputeCC results/imputecc "$CONTIGS" \
  /path/to/contig_info.csv /path/to/hic_matrix.npz 
```


### 10. MetaTOR
Install Metator by following the https://github.com/koszullab/metaTOR#installation
MetaTOR starts from the assembly and cleaned Hi-C FASTQ files:

```bash
./metator_module.sh  OUTPUT_PATH CONTIGS FORWARD_READS REVERSE_READS
```

Example:

```bash
./metator_module.sh  results/metator "$CONTIGS" \
  /path/to/hic_clean_R1.fastq.gz /path/to/hic_clean_R2.fastq.gz
```

The module currently uses `Sau3AI,MluCI`, 80 threads, a 50,000-bp size threshold, and `--start=fastq`. Update the environment `PATH` placeholder and enzyme setting before execution.

### 11. bin3C
Install bin3c by following the 
Set `BIN3C_PATH` in `module_bin3c.sh` to the location of `bin3C.py`, then run:

```bash
./module_bin3c.sh OUTPUT_PATH CONTIGS HIC_BAM
```

Example:

```bash
./module_bin3c.sh results/bin3c "$CONTIGS" "$HIC_BAM"
```

### 12. MetaWRAP refinement
Install Metawrap by following the 
Use MetaWRAP to refine bins from BINNER1, BINNER2, and BINNER3:

```bash
./metawrap_module.sh METAHIT_PROJECT_PATH OUTPUT_PATH COMEBIN_BIN_PATH IMPUTECC_BIN_PATH METACC_BIN_PATH
```

Example:

```bash
 ./metawrap_module.sh /path/to/MetaHiT results/metawrap \
  /path/to/comebin_bins /path/to/imputecc_bins /path/to/metacc_bins
```

### 13. MAGScoT refinement
Install MAGScoT by the following the 
Use MAGScoT to refine contig-to-bin assignments from BINNER1, BINNER2 and BINNER3:

```bash
./magscot_module.sh MAGSCOT_SRC OUTPUT_PATH CONTIGS BINNER1_CONTIG2BIN BINNER2_CONTIG2BIN BINNER3_CONTIG2BIN
```

Example:

```bash
./magscot_module.sh /path/to/MAGScoT results/magscot "$CONTIGS" \
  /path/to/BINNER1_contig_bins.tsv /path/to/BINNER2_contig_bins.tsv \
  /path/to/BINNER3_contig_bins.tsv
```

The module generates proteins with Prodigal, runs HMMER and MAGScoT, creates FASTA bins in `FINAL_BINS/`. Update the hard-coded path to `magscot_bins.py` in the module before running.

### 14.DASTool
Install DASTool by following the

```bash
./das_tool_module.sh  OUTPUT_PATH CONTIGS BINNER1_CONTIG2BIN BINNER2_CONTIG2BIN BINNER3_CONTIG2BIN
```
Example:

```bash
./das_tool_module.sh  results/magscot "$CONTIGS" \
  /path/to/BINNER1_contig_bins.tsv /path/to/BINNER2_contig_bins.tsv \
  /path/to/BINNER3_contig_bins.tsv
```

### 15. Assess bin quality with CheckM2
CheckM2 is installed by following the CheckM2 GitHub repository.  
Run CheckM2 on each binner's or bin refinement's final bin directory. Use the file extension that matches the bins being assessed:

```bash
checkm2 predict --threads 80 --input /path/to/bins \
  --output-directory /path/to/checkm2_output -x .fa
```
License

This project is licensed under the terms in the [LICENSE](LICENSE) file.
