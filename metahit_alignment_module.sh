METAHIT_PROJECT_PATH=${1}
OUT=${2}
CONTIGS=${3}
FORWARD=${4}
REVERSE=${5}
ASSEMBLER=${6}


cd ${METAHIT_PROJECT_PATH}

python metahit.py alignment -p ./ -r ${CONTIGS} -1 ${FORWARD} -2 ${REVERSE} -o ${OUT} -t 80
