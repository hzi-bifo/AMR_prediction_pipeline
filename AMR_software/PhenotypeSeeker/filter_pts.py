#!/usr/bin/env/python
import sys
import os
sys.path.append('../')
sys.path.insert(0, os.getcwd())
import pandas as pd
import numpy as np
import argparse


def get_ML_dataframe_testset(species,anti,sampleName,wd):

    meta_temp_f= './AMR_software/PhenotypeSeeker/bin/'+ str(species.replace(" ", "_"))  + '/' +  str(anti.translate(str.maketrans({'/': '_', ' ': '_'})))
    meta_temp= wd+'/log/software/phenotypeseeker/software_output/'+ str(species.replace(" ", "_"))  + '/' +  \
               str(anti.translate(str.maketrans({'/': '_', ' ': '_'}))) +'_temp/'+str(sampleName)

    vocab=np.load(meta_temp_f+'_vocab.npy',allow_pickle=True)
    data = np.zeros((len(vocab), 1), dtype='uint16')
    feature_matrix = pd.DataFrame(data, index=vocab, columns=['initializer'])  # delete later
    feature_matrix.index.name = 'feature'
    # print(feature_matrix)
    # print('-----')
    f = pd.read_csv(meta_temp+'/mapped',
                    names=['combination', str(sampleName)], sep="\t")
    f = f.set_index('combination')
    feature_matrix = pd.concat([feature_matrix, f], axis=1, join="inner")
    feature_matrix = feature_matrix.drop(['initializer'], axis=1)  # delete initializer column
    feature_matrix[feature_matrix > 0] = 1
    feature_matrix = feature_matrix.T
    feature_matrix.index.name = 'genome_id'
    feature_matrix.to_csv(meta_temp +'_Test_df.csv')
    # print(feature_matrix)



if __name__== '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument('-anti', '--anti', type=str, required=True,
                        help='antibiotics.')
    parser.add_argument('-s', '--species', type=str, required=True, help='species to run: e.g. \'Escherichia coli\' \'Staphylococcus aureus\'.')
    parser.add_argument('-sample', '--sampleName', type=str,
                        help='Sample name.')
    parser.add_argument('-wd', '--wd', type=str, required=True,
                        help='working directory.')
    parsedArgs=parser.parse_args()
    # print(parsedArgs)
    get_ML_dataframe_testset(parsedArgs.species,parsedArgs.anti,parsedArgs.sampleName,parsedArgs.wd)
