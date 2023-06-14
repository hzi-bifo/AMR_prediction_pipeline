#!/bin/bash
BASEDIR=$(dirname "$0")
species="$1"
sampleName="$2"
folds_setting="$3"
output_path="$4"
log_path="$5"





mkdir -p  ${output_path}results/${sampleName}/




if [ ${folds_setting} == "close" ]; then
    python ${BASEDIR}/predicting_pts.py  -s ${species} -f_all -sample ${sampleName} -wd ${log_path} \
-o ${output_path}results/${sampleName}/${species}_phenotypeseeker_${folds_setting}  \



elif [ ${folds_setting} == "low_similarity"  ]; then
  python ${BASEDIR}/predicting_pts.py  -s ${species} -f_all -sample ${sampleName} -wd ${log_path} \
-o ${output_path}results/${sampleName}/${species}_phenotypeseeker_${folds_setting}  -f_kma


elif [ ${folds_setting} == "distant_phylo" ]; then
   python ${BASEDIR}/predicting_pts.py  -s ${species} -f_all -sample ${sampleName} -wd ${log_path} \
-o ${output_path}results/${sampleName}/${species}_phenotypeseeker_${folds_setting} -f_phylotree

else
   echo "Please check if you have entered the correct folds setting."
fi

