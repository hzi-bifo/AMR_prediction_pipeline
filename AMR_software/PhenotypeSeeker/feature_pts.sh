#!/bin/bash
species="$1"
kmerPath="$2"
sampleName="$3"
log_path="$4"



## anti_list, cefoxitin_vocab.npy  and *_feature_vector_13_union.list are the same for the same species-anti combination across 3 folds sets.
readarray -t Anti_List <  ./AMR_software/PhenotypeSeeker/bin/feature/${species}/anti_list


for anti in ${Anti_List[@]};do
    # prepare temp folders to store temp files and results
    #use the ${anti}_feature_vector_13_union.list we provided
    glistquery  ${kmerPath}  \
    -l ./AMR_software/PhenotypeSeeker/bin/feature/${species}/${anti}_feature_vector_13_union.list  >   \
    ${log_path}log/software/phenotypeseeker/software_output/${sampleName}/${species}/${anti}_mapped  #mapping samples to feature vector space

    # 2).filtering kmers according to training matrix.------------------
    python ./AMR_software/PhenotypeSeeker/filter_pts.py -s ${species} -anti ${anti} -sample ${sampleName} -wd ${log_path}
done


##for pipeline check:
flag=1
for anti in ${Anti_List[@]};do
FILE=${log_path}log/software/phenotypeseeker/software_output/${sampleName}/${species}/${anti}_Test_df.csv
if [ ! -f $FILE ]
then
    flag=0
fi
done
if [[ ${flag} == 1 ]]
then
  touch ${log_path}log/software/phenotypeseeker/software_output/${sampleName}/${species}/check_Test_df.csv
fi
