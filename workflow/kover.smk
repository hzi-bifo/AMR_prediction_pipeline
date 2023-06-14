import yaml,os

SAMPLE_INFO_FILE = "sample.txt"
CONFIG_FILE= "Config.yaml"
CONDA_FILE="envs/amr_env.yml"

def read_output_path():
    with open(CONFIG_FILE, "r") as file:
        config = yaml.safe_load(file)
        return config["output_path"],config["log_path"], config["folds_setting"]

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



rule all:
    input:
        expand( "{output_path}results/{sample_name}/{species}_kover_{folds_setting}_result.txt",folds_setting=FOLDS,\
            output_path=OUTPUT_PATH,sample_name=[info[0] for info in SAMPLE_INFO],\
        species=[info[2] for info in SAMPLE_INFO])

# rule feature_kmer:
#     input:
#         input_path=lambda wildcards: SAMPLE_dic[wildcards.sample_name]
#     params:
#         input_species=lambda wildcards: wildcards.species,
#         input_name=lambda wildcards: wildcards.sample_name,
#         para_out=OUTPUT_PATH,
#         para_log=LOG_PATH,
#
#     output:
#         output_file=LOG_PATH+"log/software/kover/software_output/{sample_name}/{species}/kmer.txt"
#     conda:
#         CONDA_FILE
#     shell:
#         '''
#         set +eu
#         bash ./AMR_software/Kover/feature_kover.sh\
#       {params.input_species} {input.input_path} {params.input_name}{params.para_out} {params.para_log}
#
#         '''

rule predict:
    input:
        input_path=lambda wildcards: SAMPLE_dic[wildcards.sample_name]
    params:
        input_species=lambda wildcards: wildcards.species,
        input_name=lambda wildcards: wildcards.sample_name,
        para_out=OUTPUT_PATH,
        para_log=LOG_PATH,
        para_folds=FOLDS
    output:
        output_file="{output_path}results/{sample_name}/{species}_kover_{folds_setting}_result.txt"
    conda:
        CONDA_FILE
    shell:
        '''
        set +eu
        bash ./AMR_software/Kover/predictor_kover.sh\
      {params.input_species}  {input.input_path} {params.input_name} {params.para_folds} {params.para_out} {params.para_log} 
      
        '''

