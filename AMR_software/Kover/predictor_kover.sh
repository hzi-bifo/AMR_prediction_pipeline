#!/bin/bash
BASEDIR=$(dirname "$0")
species="$1"
samplePath="$2"
sampleName="$3"
folds_setting="$4"
output_path="$5"
log_path="$6"






mkdir -p  ${output_path}results/${sampleName}/
mkdir -p   ${log_path}log/software/kover/software_output/${sampleName}/${species}



### 1) extract k-mers

${BASEDIR}/dsk/build/bin/dsk -out  ${log_path}log/software/kover/software_output/${sampleName}/${species}/output.h5 \
-out-tmp  ${log_path}log/software/kover/software_output/${sampleName}/${species} -abundance-min 1 -kmer-size 31 \
-file ${samplePath} -verbose False

${BASEDIR}/dsk/build/bin/dsk2ascii -file  ${log_path}log/software/kover/software_output/${sampleName}/${species}/output.h5 \
-out  ${log_path}log/software/kover/software_output/${sampleName}/${species}/kmer.txt


### 2) predict


if [ ${folds_setting} == "close" ]; then
    python ${BASEDIR}/model_kover.py -s ${species} -f_all -sample ${sampleName} -wd ${log_path} \
-o ${output_path}results/${sampleName}/${species}_kover_${folds_setting} \
-sd ${BASEDIR} \
-test_file ${log_path}log/software/kover/software_output/${sampleName}/${species}/kmer.txt


elif [ ${folds_setting} == "low_similarity"  ]; then
  python ${BASEDIR}/model_kover.py -s ${species} -f_all -sample ${sampleName} -wd ${log_path} \
-o ${output_path}results/${sampleName}/${species}_kover_${folds_setting} \
-sd ${BASEDIR} -f_kma \
-test_file ${log_path}log/software/kover/software_output/${sampleName}/${species}/kmer.txt


elif [ ${folds_setting} == "distant_phylo" ]; then
   python ${BASEDIR}/model_kover.py -s ${species} -f_all -sample ${sampleName} -wd ${log_path} \
-o ${output_path}results/${sampleName}/${species}_kover_${folds_setting} \
-sd ${BASEDIR} -f_phylotree \
-test_file ${log_path}log/software/kover/software_output/${sampleName}/${species}/kmer.txt

else
   echo "Please check if you have entered the correct folds setting."
fi
