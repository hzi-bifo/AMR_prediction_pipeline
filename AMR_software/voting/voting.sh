#!/bin/bash
BASEDIR=$(dirname "$0")
species="$1"
sampleName="$2"
folds_setting="$3"
output_path="$4"






mkdir -p  ${output_path}results/${sampleName}/




if [ ${folds_setting} == "close" ]; then
    python ${BASEDIR}/voting.py  -s ${species} \
-o ${output_path}results/${sampleName}/ \


elif [ ${folds_setting} == "low_similarity"  ]; then
  python ${BASEDIR}/voting.py  -s ${species}  \
-o ${output_path}results/${sampleName}/ -f_kma


elif [ ${folds_setting} == "distant_phylo" ]; then
   python ${BASEDIR}/voting.py  -s ${species} \
-o ${output_path}results/${sampleName}/ -f_phylotree

else
   echo "Please check if you have entered the correct folds setting."
fi

