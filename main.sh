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

export AMR_HOME=$( dirname $( realpath ${BASH_SOURCE[0]} ) )
export PATH=$AMR_HOME:$AMR_HOME/main:$PATH
echo 'AMR_HOME is '$AMR_HOME




#echo "Software: ${Software} "
source activate ${main_env}

if [[ ${dryrun} == "Y" ]]; then
      ########################################################################################################################
      if [[ ${Software} == *"PhenotypeSeeker"* ]]; then
      snakemake --cores ${n_jobs} -s ./workflow/phenotypeseeker.smk  --directory $AMR_HOME --use-conda --dry-run
      fi

      if [[ ${Software} == *"Kover"* ]]; then
      snakemake --cores ${n_jobs} -s ./workflow/kover.smk  --directory $AMR_HOME --use-conda --dry-run
      fi

      if [[ ${Software} == *"ResFinder"* ]]; then
      snakemake --cores ${n_jobs} -s ./workflow/resfinder.smk --directory $AMR_HOME --use-conda --dry-run
      fi

      ########################################################################################################################


else
      ########################################################################################################################
      if [[ ${Software} == *"PhenotypeSeeker"* ]]; then
          echo "Software: PhenotypeSeeker "
      snakemake --cores ${n_jobs} -s ./workflow/phenotypeseeker.smk  --directory $AMR_HOME --use-conda
      fi

      if [[ ${Software} == *"Kover"* ]]; then
        echo "Software: Kover "
      snakemake --cores ${n_jobs} -s ./workflow/kover.smk  --directory $AMR_HOME --use-conda
      fi

      if [[ ${Software} == *"ResFinder"* ]]; then
        echo "Software: ResFinder "
      snakemake --cores ${n_jobs} -s ./workflow/resfinder.smk --directory $AMR_HOME --use-conda
      fi

      if [[ ${Software} == *"voting"* ]]; then
        echo "Software: voting "
      snakemake --cores ${n_jobs} -s ./workflow/voting.smk --directory $AMR_HOME --use-conda
      fi
      ########################################################################################################################

fi


#todo progress bar check if --verbose work

##--conda-prefix=$AMR_HOME/workflow/envs
##--conda-prefix=$AMR_HOME/workflow/envs --dry-run --conda-base-path=$( dirname $( dirname $( /usr/bin/which conda ) ) )



## todo for future:
### 1. make  a dic that inidicting which software is recommended. And it finally gives results based on that dic.
## 2.  the prediction is made using our software recommendation list, if multiple methods are tied best for a \
## specific targeted species-drug, then we used the methods by order of Point-/ResFinder, Kover, PhenotypeSeeker.
## P. aeruginosa-MEM, and A. baumannii-SXT are predicted by the second best method as Seq2Geno2Pheno and Aytan-Aktug is not yet available.
## 3. ensemble voting



