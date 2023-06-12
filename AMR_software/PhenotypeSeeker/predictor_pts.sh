#!/bin/bash
BASEDIR=$(dirname "$0")
species="$1"
samplePath="$2"
sampleName="$3"
folds_setting="$4"
output_path="$5"
log_path="$6"




if [ ${folds_setting}="close" ]; then
    folds_file="random"

elif [ ${folds_setting}="low_similarity"  ]; then
  folds_file="kma"


elif [ ${folds_setting}="distant_phylo" ]; then
   folds_file="phylotree"

else
   echo "Please check if you have entered the correct folds setting."
fi




## anti_list, cefoxitin_vocab.npy  and *_feature_vector_13_union.list are the same for the same species-anti combination across 3 folds sets.
readarray -t Anti_List <  ./AMR_software/PhenotypeSeeker/bin/feature/${species}/anti_list
mkdir -p  ${log_path}log/software/phenotypeseeker/software_output/K-mer_lists
mkdir -p  ${output_path}results/${sampleName}/


# 1) extract k-mers
glistmaker ${samplePath} -o ${log_path}log/software/phenotypeseeker/software_output/K-mer_lists/${sampleName}_0 -w 13 -c 1

for anti in ${Anti_List[@]};do
    # prepare temp folders to store temp files and results

    mkdir -p  ${log_path}log/software/phenotypeseeker/software_output/${species}/${anti}_temp/${sampleName}

    #use the ${anti}_feature_vector_13_union.list we provided
    glistquery  ${log_path}log/software/phenotypeseeker/software_output/K-mer_lists/${sampleName}_0_13.list  \
    -l ./AMR_software/PhenotypeSeeker/bin/feature/${species}/${anti}_feature_vector_13_union.list  >   \
    ${log_path}log/software/phenotypeseeker/software_output/${species}/${anti}_temp/${sampleName}/mapped  #mapping samples to feature vector space

    # 2).filtering kmers according to training matrix.------------------
    python ./AMR_software/PhenotypeSeeker/filter_pts.py -s ${species} -anti ${anti} -sample ${sampleName} -wd ${log_path}
done
## 3).predicting------------------

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

