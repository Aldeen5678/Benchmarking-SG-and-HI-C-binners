METAHIT_PROJECT_PATH=${1}
OUT=${2}
FORWARD=${3}
REVERSE=${4}
ASSEMBLER=${5}


cd ${METAHIT_PROJECT_PATH}

python metahit.py assembly -p ./ -1 ${FORWARD} -2 ${REVERSE} -o ${OUT} -t 80 "--${ASSEMBLER}"
