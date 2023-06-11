import pandas as pd
import argparse,json,pickle


''' Use learned model by Kover 2.0 for prediction. 
Model learned using Kover 2.0 : https://github.com/aldro61/kover [Alexandre Drouin, Gaël Letarte, Frédéric Raymond, Mario Marchand, Jacques Corbeil, and François
Laviolette. Interpretable genotype-to-phenotype classifiers with performance guarantees. Scientific reports, 9(1):1–13, 2019]
We encoded model based on Kover's output for prediction using python. Contact us for the encoding scripts. 
One time one sample.
'''


def predictor(SampleName,species,work_path,software_path,f_all,output,f_phylotree,f_kma):
    if f_all:
        f = open(software_path+'/bin/'+species+'/Dict_' + str(species.replace(" ", "_"))+ '_kma_' + str(f_kma) + '_tree_' + str(f_phylotree)+'_classifier.json')
        dic_cl=json.load(f)
        anti_list=list(dic_cl.keys())

    test_file=work_path+"log/software/kover/software_output/K-mer_lists/"+SampleName+".txt"
    kmer_P_df=  pd.read_csv(test_file,names=['combination', 'count'],dtype={'genome_id': object}, sep=" ")
    kmer_P=kmer_P_df['combination'].to_list()
    pheno_table= pd.DataFrame(index=anti_list,columns=['Phenotype'])

    for anti in anti_list:

        chosen_cl=dic_cl[anti]
        meta_dir=software_path+'/bin/'+species+'/'+str(anti.translate(str.maketrans({'/': '_', ' ': '_','+': '_'})))+'_temp/'+chosen_cl+'_b_0'
        #==============
        #  1
        #==============
        if chosen_cl=='scm':
            with open(meta_dir+'/results.json') as f:
                data = json.load(f)
            model_rules = data["model"]["rules"]
            model_type = data["cv"]["best_hp"]["values"]["model_type"]
            rule_binary_list = []
            for rule in model_rules:
                if rule.startswith("Presence"):
                    kmer = rule.replace("Presence(", "").replace(")", "")
                    rule_binary_list.append(kmer in kmer_P)
                else:
                    kmer = rule.replace("Absence(", "").replace(")", "")
                    rule_binary_list.append(kmer not in kmer_P)

            if model_type == "disjunction":
                check_func = any
            elif model_type == "conjunction":
                check_func =all
            else:
                print('error 1.')
            pheno_table.loc[anti, 'Phenotype'] = 1 if check_func(
                rule_binary_list) else 0




        #==============
        #     2
        #==============
        #Greedy
        elif chosen_cl=='tree':
            loaded_model = pickle.load(open(meta_dir+'_finalized_model.sav', 'rb'))
            [Path_id,node_marker,dic_pheno,dic_node_lf,dic_node_rf,dic_node_marker]=loaded_model

            current=Path_id[0][0] #the main parent node. Start from here!
            # print(current)
            f_pa=[]
            while 'leaf' not in current:
                if dic_node_marker[current] in kmer_P:
                    f_pa.append('l')
                    current=dic_node_lf[current]
                else:
                    f_pa.append('r')
                    current=dic_node_rf[current]

            Phenotype=dic_pheno[tuple(f_pa)]
            pheno_table.loc[anti,'Phenotype']=Phenotype
        # print(Phenotype)
    dic_anti={'amoxicillin_clavulanic_acid':'amoxicillin/clavulanic acid','fusidic_acid':'fusidic acid',\
              'trimethoprim_sulfamethoxazole':'trimethoprim/sulfamethoxazole','piperacillin_tazobactam':'piperacillin/tazobactam',\
              'ampicillin_sulbactam':'ampicillin/sulbactam'}
    pheno_table['antibiotic']=pheno_table.index.map(lambda x: dic_anti[x] if x in list(dic_anti.keys()) else x)
    pheno_table = pheno_table[['antibiotic','Phenotype']]
    # print(pheno_table)
    dic_phenotype={0:"S",1:"R"}
    pheno_table=pheno_table.replace({"Phenotype": dic_phenotype})
    pheno_table.to_csv(output+ '_result.txt', sep="\t",index=False)
    # pheno_table.to_csv(output+ '_result.txt', sep="\t")










if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--species", default='Escherichia_coli', type=str,
                        help='Species to predict. So far, can be  \'Escherichia coli\' or \'Staphylococcus aureus\' ')
    parser.add_argument('-o', '--output', type=str,
                        help='Output of the phenotype table.')
    parser.add_argument('-wd', '--work_path', type=str, required=True,
                        help='Working directory.')
    parser.add_argument('-sd', '--software_path', type=str,  default='./AMR_software/Kover',required=True,
                        help='Software directory.')
    parser.add_argument('-sample', '--SampleName', type=str,
                        help='Sample name.')
    parser.add_argument('-f_all', '--f_all', dest='f_all', action='store_true',
                        help='All the possible antibiotics w.r.t. the species. So far, only possible with this flag.')
    parser.add_argument('-f_phylotree', '--f_phylotree', dest='f_phylotree', action='store_true',
                        help=' phylo-tree based cv folders.')
    parser.add_argument('-f_kma', '--f_kma', dest='f_kma', action='store_true',
                        help='kma based cv folders.')
    parsedArgs = parser.parse_args()
    predictor(parsedArgs.SampleName,parsedArgs.species,parsedArgs.work_path,parsedArgs.software_path,parsedArgs.f_all,
              parsedArgs.output,parsedArgs.f_phylotree,parsedArgs.f_kma)
