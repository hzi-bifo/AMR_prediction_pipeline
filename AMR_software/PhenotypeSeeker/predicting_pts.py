import pickle,argparse
import numpy as np
import pandas as pd

def GetPheno( species, f_all, anti_list,sampleName,output,wd,f_phylotree,f_kma):
    '''
    Save the phenotype table to ${output}_result.txt
    '''

    if f_all:
        anti_list=np.genfromtxt('./AMR_software/PhenotypeSeeker/bin/feature/'+species+'/anti_list', dtype="str")

    pheno_table= pd.DataFrame(index=anti_list,columns=['Phenotype'])

    for anti in anti_list:

        feature_path=wd+'log/software/phenotypeseeker/software_output/'+str(sampleName)+ '/'+str(species.replace(" ", "_"))  + '/' +  \
                     str(anti.translate(str.maketrans({'/': '_', ' ': '_'}))) +'_Test_df.csv'
        feature=pd.read_csv(feature_path,dtype={sampleName: object}, sep=",")
        X=feature.iloc[0].to_list()
        X=X[1:]
        X=np.array(X)
        X=X.reshape(1, -1)

        if f_phylotree:
            f_folder="phylotree"
        elif f_kma:
            f_folder="kma"
        else:
            f_folder="random"

        model_path='./AMR_software/PhenotypeSeeker/bin/model/'+f_folder+'/'+ str(species.replace(" ", "_"))+'/'\
                   +str(species.replace(" ", "_"))+'_'+str(anti.translate(str.maketrans({'/': '_', ' ': '_'})))
        loaded_model = pickle.load(open(model_path+'_f1_macro_finalized_model.sav', 'rb'))
        y_pre=loaded_model.predict(X)
        pheno_table.loc[anti,'Phenotype']=y_pre[0]


    dic_anti={'amoxicillin_clavulanic_acid':'amoxicillin/clavulanic acid','fusidic_acid':'fusidic acid',\
              'trimethoprim_sulfamethoxazole':'trimethoprim/sulfamethoxazole','piperacillin_tazobactam':'piperacillin/tazobactam',\
              'ampicillin_sulbactam':'ampicillin/sulbactam'}


    pheno_table['antibiotic']=pheno_table.index.map(lambda x: dic_anti[x] if x in list(dic_anti.keys()) else x)
    pheno_table = pheno_table[['antibiotic','Phenotype']]
    dic_phenotype={0:"S",1:"R"}
    pheno_table=pheno_table.replace({"Phenotype": dic_phenotype})
    pheno_table.to_csv(output+ '_result.txt', sep="\t",index=False)
    ## pheno_table.to_csv(output+ '_result.txt', sep="\t")
    return pheno_table

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--species", default='Escherichia coli', type=str,
                        help='Species to predict. So far, can be  \'Escherichia coli\' or \'Staphylococcus aureus\' ')
    parser.add_argument('-o', '--output', type=str,
                        help='Output of the phenotype table.')
    parser.add_argument('-wd', '--wd', type=str, required=True,
                        help='working directory.')
    parser.add_argument('-sample', '--sampleName', type=str,
                        help='Sample name.')
    parser.add_argument('-anti', '--antibiotics', default=[], type=str, nargs='+', help='species to run: e.g.\'amoxicillin\' \
                    \'amoxicillin/clavulanic acid\' \'aztreonam\' , etc.')
    parser.add_argument('-f_phylotree', '--f_phylotree', dest='f_phylotree', action='store_true',
                        help=' phylo-tree based cv folders.')
    parser.add_argument('-f_kma', '--f_kma', dest='f_kma', action='store_true',
                        help='kma based cv folders.')
    parser.add_argument('-f_all', '--f_all', dest='f_all', action='store_true',
                        help='all the possible antibiotics w.r.t. the species.')
    parser.add_argument('--n_jobs', default=1, type=int, help='Number of jobs to run in parallel.')
    parsedArgs = parser.parse_args()
    GetPheno(parsedArgs.species,parsedArgs.f_all,parsedArgs.antibiotics,parsedArgs.sampleName,parsedArgs.output,parsedArgs.wd,
             parsedArgs.f_phylotree,parsedArgs.f_kma)
