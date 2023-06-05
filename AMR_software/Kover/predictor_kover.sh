#!/bin/bash
BASEDIR=$(dirname "$0")
species="$1"
samplePath="$2"
sampleName="$3"
folds_setting="$4"
OutPath="$5"
log_path="$6"




mkdir -p   ${log_path}log/software/kover/software_output/K-mer_lists/${sampleName}
mkdir -p  ${outPath}/results/kover/
#if [[ -d ${OutPath}/results/${sampleName}_${folds_setting}_${species} ]] || [[ -d ${log_path}log/software/kover/software_output/K-mer_lists/${sampleName} ]]
#then
#    new_sampleName=${sampleName}_${date +”%d-%b-%Y”}_
#    echo "${sampleName} exists on your filesystem. We renamed your sample as ${new_sampleName}"
#    sampleName=${new_sampleName}
#fi

### 1) extract k-mers
##conda activate python36
###kmc -k31 -b -m24 -fm -ci1 -cs1677215 ${samplePath}   ${outPath}/log/temp/K-mer_lists/${sampleName}/NA.res    ${outPath}/log/temp/K-mer_lists/${sampleName}
###kmc_dump -ci1 -cs1677215   ${outPath}/log/temp/K-mer_lists/${sampleName}/NA.res   ${outPath}/log/temp/K-mer_lists/${sampleName}.txt

${BASEDIR}/dsk/build/bin/dsk -out  ${log_path}log/software/kover/software_output/K-mer_lists/${sampleName}/output.h5 \
-out-tmp  ${outPath}/log/temp/K-mer_lists/${sampleName}/ -abundance-min 1 -kmer-size 31 \
-file ${samplePath} -verbose False

${BASEDIR}/dsk/build/bin/dsk2ascii -file  ${log_path}log/software/kover/software_output/K-mer_lists/${sampleName}/output.h5 \
-out  ${log_path}log/software/kover/software_output/K-mer_lists/${sampleName}.txt

#### 2)

if [ ${folds_setting}="close" ]; then
    python ${BASEDIR}/model_kover.py -s ${species} -f_all -sample ${sampleName} -wd ${log_path} \
-o ${outPath}/results/${sampleName}_${folds_setting}_${species} \
-sd ${BASEDIR}


elif [ ${folds_setting}="low_similarity"  ]; then
  python ${BASEDIR}/model_kover.py -s ${species} -f_all -sample ${sampleName} -wd ${log_path} \
-o ${outPath}/results/${sampleName}_${folds_setting}_${species} \
-sd ${BASEDIR} -f_kma


elif [ ${folds_setting}="distant_phylo" ]; then
   python ${BASEDIR}/model_kover.py -s ${species} -f_all -sample ${sampleName} -wd ${log_path} \
-o ${outPath}/results/${sampleName}_${folds_setting}_${species} \
-sd ${BASEDIR} -f_phylotree

else
   echo "Please check if you have entered the correct folds setting."
fi
