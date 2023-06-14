#!/bin/bash
BASEDIR=$(dirname "$0")

pheno_table="$1"
species="$2"
sampleName="$3"
OutPath="$4"
log_path="$5"



mkdir -p  ${OutPath}results/${sampleName}/

python ${BASEDIR}/resfinder_output.py  -f_all -s ${species} -table ${pheno_table} -wd ${log_path}log/software/resfinder/software_output/${sampleName}/${species} \
 -o ${OutPath}results/${sampleName}/${species}_resfinder \

