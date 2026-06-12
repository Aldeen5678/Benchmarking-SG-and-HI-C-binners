OUT_DIR=${1}
CONTIGS=${2}
HIC_BAM=${3}


BIN3C_PATH="/path/to/your/bin3C/bin3C.py"
ENZYME="Sau3AI"

MAP_OUT="${OUT_DIR}/contact_map"
rm -rf "$MAP_OUT"
echo "Starting Stage 1: mkmap at $(date)"
python2 "$BIN3C_PATH" mkmap -v -e "$ENZYME" "$CONTIGS" "$HIC_BAM" "$MAP_OUT" 2>&1

# Step 2: cluster
PGZ_FILE="${MAP_OUT}/contact_map.p.gz"
FINAL_BINS="${OUT_DIR}/final_bins"

if [ -f "$PGZ_FILE" ]; then
    python2 "$BIN3C_PATH" cluster -v  "$PGZ_FILE"  "$FINAL_BINS" 2>&1
else
    echo "ERROR: Contact map .p.gz file not found."
    exit 1
fi


