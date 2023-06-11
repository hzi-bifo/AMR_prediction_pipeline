import yaml,os

SAMPLE_INFO_FILE = "sample.txt"
CONFIG_FILE= "Config.yaml"


def read_output_path():
    with open(CONFIG_FILE, "r") as file:
        config = yaml.safe_load(file)
        return config["output_path"],config["log_path"], config["resfinder_env"], config["folds_setting"]

OUTPUT_PATH, LOG_PATH,resfinder_ENV,FOLDS= read_output_path()
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
        expand( "{output_path}results/{sample_name}/{species}_phenotypeseeker_{folds_setting}_result.txt",folds_setting=FOLDS,
            output_path=OUTPUT_PATH,sample_name=[info[0] for info in SAMPLE_INFO],
        species=[info[2] for info in SAMPLE_INFO])

rule process_sample:
    input:
        ### input_file1=lambda wildcards: wildcards.species,
        input_file2=lambda wildcards: SAMPLE_dic[wildcards.sample_name]
        ### input_file3=lambda wildcards: wildcards.sample_name
    params:
        input_file1=lambda wildcards: wildcards.species,
        input_file3=lambda wildcards: wildcards.sample_name,
        para_4=OUTPUT_PATH,
        para_5=LOG_PATH,
        para_6=resfinder_ENV,
        para_7=FOLDS
    output:
        output_file="{output_path}results/{sample_name}/{species}_phenotypeseeker_{folds_setting}_result.txt"
    conda:
        'env/phenotypeseeker_env.yml'
    shell:
        '''
        set +eu
        # source activate {params.para_6}    
        echo $CONDA_DEFAULT_ENV
        mkdir -p {params.para_5}log/software/phenotypeseeker/software_output/{params.input_file3}/
        bash ./AMR_software/PhenotypeSeeker/predictor_pts.sh\
      {params.input_file1}  {input.input_file2} {params.input_file3} {params.para_4} {params.para_5} >  \
       {params.para_5}log/software/phenotypeseeker/software_output/{params.input_file3}/log_{params.para_7}
      # conda deactivate
      
        '''


