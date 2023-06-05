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



export AMR_HOME=$( dirname $( dirname $( realpath ${BASH_SOURCE[0]} ) ) )
export PATH=$AMR_HOME:$AMR_HOME/main:$PATH
echo 'AMR_HOME is '$AMR_HOME



####  1. install dsk for Kover ##########################################################################
#### https://github.com/GATB/dsk
### Requirements
### CMake 3.1+; see http://www.cmake.org/cmake/resources/software.html#
### C++/11 capable compiler (e.g. gcc 4.7+, clang 3.5+, Apple/clang 6.0+).
cd ./AMR_software/Kover/dsk
sh INSTALL

###testing
cd ../scripts  # we suppose you are in the build directory
./simple_test.sh
echo "dsk installed."

cd ${AMR_HOME}

########################################################################################################
####  2. install dsk for Kover ##########################################################################




check_conda_channels () {
	## ensure conda channels
	echo '+check conda channels...'
	for c in conda-forge/label/broken bioconda conda-forge defaults; do
		echo '+'$c
		if [ $(conda config --get channels | grep $c | wc -l) -eq 0 ]; then
			conda config --add channels $c
		fi
	done
	cd ${AMR_HOME}
}


# user's input
core_env_name=''
if [ "$#" -lt 1 ]; then
  core_env_name='snakemake_env10'
else
  core_env_name=$1
fi
echo 'Creating environment "'$core_env_name'" for snakemake pipeline.'


####  3. install conda  env ##################################################################################
# ensure the conda channels

check_conda_channels ||{ echo "Errors in setting conda channels"; exit; }
if [ -d $( dirname $( dirname $( /usr/bin/which conda ) ) )/envs/$core_env_name ]; then
  echo '-----'
  echo 'Naming conflict: an existing environment with same name found: '
  echo $( dirname $( dirname $( /usr/bin/which conda ) ) )/envs/$core_env_name
  exit
else
  # start creating the environment
  conda env create -n ${core_env_name} --file=snakemake_env.yml || { echo "Errors in downloading the core environment"; exit; }

#  conda env create -n  --file=snakemake_env.yml || { echo "Errors in downloading the core environment"; exit; }

#  conda env create -n ${resfinder_env} --file=./install/res_env.yml || { echo "Errors in creating ResFinder envs"; exit; }




fi

########################################################################################################
