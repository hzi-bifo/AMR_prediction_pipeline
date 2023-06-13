#!/bin/bash
BASEDIR=$(dirname "$0")
species="$1"
sampleName="$2"
OutPath="$3"
log_path="$4"



mkdir -p  ${OutPath}results/${sampleName}/

python ${BASEDIR}/resfinder_output.py  -f_all -s ${species} -wd ${log_path}log/software/resfinder/software_output/${sampleName}/${species} \
 -o ${OutPath}results/${sampleName}/${species}_resfinder \

