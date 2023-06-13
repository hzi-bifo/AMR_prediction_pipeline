#!/bin/bash
BASEDIR=$(dirname "$0")
species="$1"
samplePath="$2"
sampleName="$3"
log_path="$4"




species_split=(${species//_/ })
s1=${species_split[0]}
s2=${species_split[1]}



python3 ${BASEDIR}/run_resfinder.py \
-ifa ${samplePath} \
-o ${log_path}log/software/resfinder/software_output/${sampleName}/${species} \
-s "${s1} ${s2}" \
--min_cov 0.6 --threshold 0.8 --point --acquired \
--db_path_point ${BASEDIR}/db_pointfinder \
--db_path_res ${BASEDIR}/db_resfinder \


