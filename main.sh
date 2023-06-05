#!/bin/bash


function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}
eval $(parse_yaml Config.yaml)
export PATH=$( dirname $( dirname $( /usr/bin/which conda ) ) )/bin:$PATH
export PYTHONPATH=$PWD



## TODO  anti_list beore copying to packages usage! make env list

if [ ${Software} == *"PhenotypeSeeker"* ]; then
  source activate ${PhenotypeSeeker_env_name}

   bash ./AMR_software/PhenotypeSeeker/predictor_pts.sh \
   ${species} \
   ${samplePath} \
   ${SampleName} \
   ${folds_setting} \
   ${output_path} \
   ${log_path}




#todo, still need to change dsk location in bash file!
# output:
elif [${Software} == *"Kover"* ]; then
  source activate ${amr_env_name}
   bash ./AMR_software/Kover/predictor_kover.sh \
    ${species} \
    ${samplePath} \
    ${SampleName} \
    ${folds_setting} \
    ${output_path} \
    ${log_path}


elif [ ${Software} == *"ResFinder"* ]; then
  source activate ${resfinder_env}
  echo $CONDA_DEFAULT_ENV
  echo "!!"

  bash ./AMR_software/ResFinder/predictor_res.sh \
      ${species} \
      ${samplePath} \
      ${SampleName} \
      ${output_path} \
      ${log_path}

else
   echo "Please check if you have entered the correct software name in the list."
fi





## todo for future:
### 1. make  a dic that inidicting which software is recommended. And it finally gives results based on that dic.
## 2.  the prediction is made using our software recommendation list, if multiple methods are tied best for a \
## specific targeted species-drug, then we used the methods by order of Point-/ResFinder, Kover, PhenotypeSeeker.
## P. aeruginosa-MEM, and A. baumannii-SXT are predicted by the second best method as Seq2Geno2Pheno and Aytan-Aktug is not yet available.
## 3. ensemble voting
## todo: change SampleName,samplePath, species to text input.


