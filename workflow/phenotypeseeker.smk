import yaml,os
import numpy as np

SAMPLE_INFO_FILE = "sample.txt"
CONFIG_FILE= "Config.yaml"
CONDA_FILE="envs/phenotypeseeker_env.yml"

def read_output_path():
    with open(CONFIG_FILE, "r") as file:
        config = yaml.safe_load(file)
        return config["output_path"],config["log_path"],config["folds_setting"]

OUTPUT_PATH, LOG_PATH,FOLDS= read_output_path()
if OUTPUT_PATH=='./':
    OUTPUT_PATH=os.getcwd()+'/'
if LOG_PATH=='./':
    LOG_PATH=os.getcwd()+'/'



SAMPLE_dic={}
def read_sample_info():
    sample_info = []
    with open(SAMPLE_INFO_FILE, "r") as file:
        for line in file:
            sample_name, input_file, species = line.strip().split(" ")
            sample_info.append((sample_name, input_file, species))
            SAMPLE_dic[sample_name]=input_file
    return sample_info

SAMPLE_INFO = read_sample_info()


def read_species_available_anti(species):
    anti_list=np.genfromtxt('./AMR_software/PhenotypeSeeker/bin/feature/'+species+'/anti_list', dtype="str")
    return anti_list

rule all:
    input:
        expand( "{output_path}results/{sample_name}/{species}_phenotypeseeker_{folds_setting}_result.txt",folds_setting=FOLDS,
            output_path=OUTPUT_PATH,sample_name=[info[0] for info in SAMPLE_INFO],
        species=[info[2] for info in SAMPLE_INFO])

rule kmer:
    input:
        input_path=lambda wildcards: SAMPLE_dic[wildcards.sample_name]
    params:
        input_species=lambda wildcards: wildcards.species,
        input_name=lambda wildcards: wildcards.sample_name,
        para_log=LOG_PATH,
        para_7=FOLDS
    output:
        output_file="{log_path}log/software/phenotypeseeker/software_output/{sample_name}/{species}/K-mer_lists/kmer_0_13.list"
    conda:
        CONDA_FILE
    shell:
        '''
        set +eu
        mkdir -p  {params.para_log}log/software/phenotypeseeker/software_output/{params.input_name}/{params.input_species}/K-mer_lists/
        glistmaker ${samplePath} -o {params.para_log}log/software/phenotypeseeker/software_output/{params.input_name}/{params.input_species}/K-mer_lists/kmer_0 \
        -w 13 -c 1
        '''


rule feature:
    input:
        input_kmer=LOG_PATH+"log/software/phenotypeseeker/software_output/{sample_name}/{species}/K-mer_lists/kmer_0_13.list"
    params:
        input_species=lambda wildcards: wildcards.species,
        input_name=lambda wildcards: wildcards.sample_name,
        para_log=LOG_PATH,
        para_7=FOLDS
    output:
        # output_file="{output_path}results/{sample_name}/{species}_phenotypeseeker_{folds_setting}_result.txt"
        output_file="{log_path}log/software/phenotypeseeker/software_output/{sample_name}/{species}/"++"_Test_df.csv"
    conda:
        CONDA_FILE
    shell:
        '''
        set +eu
        
        mkdir -p {params.para_log}log/software/phenotypeseeker/software_output/{params.input_name}/{params.input_species}
        bash ./AMR_software/PhenotypeSeeker/feature_pts.sh\
      {params.input_species}  {input.input_path} {params.input_name} {params.para_log}\
      # >  {params.para_log}log/software/phenotypeseeker/software_output/{params.input_name}/{params.input_species}/log_{params.para_7}
      
      
        '''


rule predict:
    input:
        # input_file2=lambda wildcards: SAMPLE_dic[wildcards.sample_name]
        input_file0=LOG_PATH+"log/software/resfinder/software_output/{sample_name}/{species}/pheno_table.txt" #todo
    params:
        input_species=lambda wildcards: wildcards.species,
        input_name=lambda wildcards: wildcards.sample_name,
        para_out=OUTPUT_PATH,
        para_log=LOG_PATH,
        para_folds=FOLDS
    output:
        output_file="{output_path}results/{sample_name}/{species}_phenotypeseeker_{folds_setting}_result.txt"
    conda:
        CONDA_FILE
    shell:
        '''
        set +eu
        
        bash ./AMR_software/PhenotypeSeeker/predictor_pts.sh\
      {params.input_species}  {params.input_name} {params.para_folds}  {params.para_out} {params.para_log}\
      # >  {params.para_log}log/software/phenotypeseeker/software_output/{params.input_name}/log_{params.para_folds}
      
      
        '''
