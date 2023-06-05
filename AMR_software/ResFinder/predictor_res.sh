#!/bin/bash
BASEDIR=$(dirname "$0")
species="$1"
samplePath="$2"
sampleName="$3"
OutPath="$4"
log_path="$5"


readarray -t Anti_List <  ${BASEDIR}/bin/${species}/anti_list
mkdir -p  ${OutPath}/results/${sampleName}_${species}/resfinder/
mkdir -p  ${log_path}log/software/resfinder/software_output/${sampleName}

#if [[ -d ${OutPath}/results/${sampleName}_${species} ]] || [[ -d ${log_path}log/software/resfinder/software_output/${sampleName} ]]
#then
#    DATE=$(date +%F)
#    new_sampleName=${sampleName}_${DATE}
#    echo "${sampleName} exists on your filesystem. We renamed your sample as ${new_sampleName}"
#    sampleName=${new_sampleName}
#fi


species_split=(${species//_/ })
s1=${species_split[0]}
s2=${species_split[1]}

python3 ${BASEDIR}/run_resfinder.py \
-ifa ${samplePath} \
-o ${log_path}log/software/resfinder/software_output/${sampleName} \
-s "${s1} ${s2}" \
--min_cov 0.6 --threshold 0.8 --point --acquired \
--db_path_point ${BASEDIR}/db_pointfinder \
--db_path_res ${BASEDIR}/db_resfinder \

echo "Point-/ResFinder finished. Now extract results..."

python ${BASEDIR}/resfinder_output.py  -f_all -sample ${sampleName} -wd ${log_path} -o ${OutPath}/results/${sampleName}_${species} \
-anti ${Anti_List[@]}

