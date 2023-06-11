import pandas as pd
import argparse

def GetPhenotype_list(anti_list,path_to_pr,SampleName,output):

    '''
    :param anti list: e.g. ['amoxicillin', 'ertapenem','meropenem','tigecycline', 'tobramycin','amoxicillin']
    :param path_to_pr: temp path
    :param SampleName: resfinder output folder name
    :return: 0: susceptible; 1:resistance.
    '''


    temp_file = open(path_to_pr+"log/software/resfinder/software_output/"+str(SampleName)+"/temp.txt", "w+")

    file = open("%slog/software/resfinder/software_output/%s/pheno_table.txt" % (path_to_pr,SampleName), "r")
    for position, line in enumerate(file):
        if "# Antimicrobial	Class" in line:
            start = position
        if "# WARNING:" in line:
            end = position
    file = open("%slog/software/resfinder/software_output/%s/pheno_table.txt" % (path_to_pr,SampleName), "r")
    for position, line in enumerate(file):
        try:
            if (position > start) & (position < end):
                temp_file.write(line)
        except:
            if (position > start):
                temp_file.write(line)

    temp_file.close()
    pheno_table =pd.read_csv(path_to_pr+"log/software/resfinder/software_output/"+str(SampleName)+"/temp.txt", index_col=None, header=None,
                             names=['Antimicrobial', 'Class', 'WGS-predicted phenotype', 'Match', 'Genetic background'],
                            sep="\t")


    dic_anti={'amoxicillin_clavulanic_acid':'amoxicillin+clavulanic acid','fusidic_acid':'fusidic acid',\
              'trimethoprim_sulfamethoxazole':'trimethoprim/sulfamethoxazole','piperacillin_tazobactam':'piperacillin/tazobactam',\
              'ampicillin_sulbactam':'ampicillin/sulbactam'}
    dic_anti2={'amoxicillin+clavulanic acid':'amoxicillin/clavulanic acid'}

    anti_list=[(dic_anti[i] if i in list(dic_anti.keys()) else i)for i in anti_list]


    pheno_table_sub = pheno_table.loc[pheno_table['Antimicrobial'].isin(anti_list), ['Antimicrobial','WGS-predicted phenotype']]
    pheno_table_sub['Phenotype']=pheno_table_sub['WGS-predicted phenotype'].apply(lambda x: "S" if x=='No resistance' else "R")
    pheno_table_sub['antibiotic']=pheno_table_sub['Antimicrobial'].apply(lambda x: dic_anti2[x] if x in list(dic_anti2.keys()) else x)
    ###pheno_table_sub.drop(['WGS-predicted phenotype','Antimicrobial'], axis=1,inplace=True)
    pheno_table_sub = pheno_table_sub[['antibiotic','Phenotype']]
    pheno_table_sub.to_csv(output+ '_result.txt', sep="\t",index=False)
    return pheno_table_sub





if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--species", default='Escherichia_coli', type=str,
                        help='Species to predict. So far, can be  \'Escherichia coli\' or \'Staphylococcus aureus\' ')
    parser.add_argument('-o', '--output', type=str,
                        help='Output of the phenotype table.')
    parser.add_argument('-wd', '--work_path', type=str, required=True,
                        help='working directory.')
    parser.add_argument('-sample', '--SampleName', type=str,
                        help='Sample name.')
    parser.add_argument('-spamplePath', '--SamplePath', type=str,
                        help='Sample path.')
    parser.add_argument('-anti', '--antibiotics', default=[], type=str, nargs='+', help='species to run: e.g.\'amoxicillin\' \
                    \'amoxicillin/clavulanic acid\' \'aztreonam\' , etc.')
    parser.add_argument('-f_all', '--f_all', dest='f_all', action='store_true',
                        help='all the possible antibiotics w.r.t. the species. So far, only possible with this flag.')
    parsedArgs = parser.parse_args()
    GetPhenotype_list(parsedArgs.antibiotics,parsedArgs.work_path,parsedArgs.SampleName,parsedArgs.output)
