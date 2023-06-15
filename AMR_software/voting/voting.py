import argparse
import numpy as np
import pandas as pd

def GetPheno(species,output,f_phylotree,f_kma):
    '''
    Save the phenotype table to ${output}_result.txt
    '''


    if f_phylotree:
        f_folder="distant_phylo"
    elif f_kma:
        f_folder="low_similarity"
    else:
        f_folder="close"

    dic_phenotype={"S":0,"R":1}


    pheno_pts=pd.read_csv(output+ species+'_phenotypeseeker_'+f_folder+'_result.txt', sep="\t",index_col=0,header=0)
    pheno_pts=pheno_pts.replace({"Phenotype": dic_phenotype})
    pheno_pts=pheno_pts.rename(columns={'Phenotype':'pts'})

    pheno_kover=pd.read_csv(output+ species+'_kover_'+f_folder+'_result.txt', sep="\t",index_col=0,header=0)
    pheno_kover=pheno_kover.replace({"Phenotype": dic_phenotype})
    pheno_kover=pheno_kover.rename(columns={'Phenotype':'kover'})

    pheno_res=pd.read_csv(output+ species+'_resfinder_result.txt', sep="\t",index_col=0,header=0)
    pheno_res=pheno_res.replace({"Phenotype": dic_phenotype})
    pheno_res=pheno_res.rename(columns={'Phenotype':'resfinder'})


    PHENO = pd.concat([pheno_pts, pheno_kover,pheno_res], axis=1, join="inner")
    PHENO['voting_temp'] = PHENO.apply(lambda row: row.pts + row.kover+ row.resfinder, axis=1)

    PHENO['voting'] = PHENO['voting_temp'].apply( lambda x: "R" if x>1 else "S")
    pheno_table = PHENO[['voting']]
    pheno_table.to_csv(output+ species+'_voting_'+f_folder+'_result.txt', sep="\t",index=True)

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--species", default='Escherichia coli', type=str,
                        help='Species to predict. So far, can be  \'Escherichia coli\' or \'Staphylococcus aureus\' ')
    parser.add_argument('-o', '--output', type=str,
                        help='Output of the phenotype table.')
    parser.add_argument('-f_phylotree', '--f_phylotree', dest='f_phylotree', action='store_true',
                        help=' phylo-tree based cv folders.')
    parser.add_argument('-f_kma', '--f_kma', dest='f_kma', action='store_true',
                        help='kma based cv folders.')
    parsedArgs = parser.parse_args()
    GetPheno(parsedArgs.species,parsedArgs.output,parsedArgs.f_phylotree,parsedArgs.f_kma)
