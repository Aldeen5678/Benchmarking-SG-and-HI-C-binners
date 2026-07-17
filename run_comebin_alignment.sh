
free_mem=$(free -h | awk '/^Mem:/ {print $4}')
echo "[FREE MEMORY]: $free_mem"


help_message () {
    echo ""
    echo "Usage: Generate aligned BAM files from shotgun read contigs"
    echo "Options:"
    echo "    -a STR          Metagenome assembled file"
    echo "    -o STR          Output directory"
    echo "    -b STR          Path for aligned BAM Files"
    echo "    -m INT          RAM available (GB); defaults to 80% capacity"
    echo "    -l INT          Minimum length of assembled contigs (default=1000)"
    echo "--single-end        Non-paired reads mode (provide *.fastq files)"
    echo "--interleaved       Input read files contain interleaved paired-end reads"  
    echo "    -f STR          Forward reads FASTQ file path"
    echo "    -r INT          Reverse reads FASTQ file path"
    echo "    -p STR          COMEBin Project path"
}


# Parse command-line arguments
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -p) path=$2; shift 2;;
        -a|--contigs)
            CONTIGS_PATH="$2"
            shift 2
            ;;
        -o|--ouput)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -b|--bam)
            BAM_OUT_PATH="$2"
            shift 2
            ;;
        -t|--threads)
            THREADS="$2"
            shift 2
            ;;
        -m|--memory)
            MEM="$2"
            shift 2
            ;;
        -f|--forward)
            FORWARD_READ="$2"
            shift 2
            ;;
        -r|--reverse)
            REVERSE_READ="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --) # end of all options
            shift
            break
            ;;
        -*|--*)
            echo "Unknown option $1"
            usage
            exit 1
            ;;
        *) # positional argument
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done


# Default parameters instantiated
available_mem_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM=$((available_mem_kb * 800)) # 80% in bytes

BASH_CMD="bash ${path}/gen_cov_file.sh -a ${CONTIGS_PATH} -o ${OUTPUT_DIR} -m ${MEM} -t ${THREADS} ${FORWARD_READ} ${REVERSE_READ}"
echo "Executing bash command: ${BASH_CMD}"

rc=$(eval $BASH_CMD)
