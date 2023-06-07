# AMR phenotype prediction 


An integrated tool for AMR phenotype prediction, based on  [PhenotypeSeeker 0.7.3](https://github.com/bioinfo-ut/PhenotypeSeeker), [Kover 2.0](https://github.com/aldro61/kover), and [ResFinder 4.0](https://bitbucket.org/genomicepidemiology/resfinder/src/master/). Prediction range of <a href="https://github.com/hzi-bifo/AMR_benchmarking/wiki/Species-and-antibiotics">species and antibiotics<a> and  <a href="https://github.com/hzi-bifo/AMR_benchmarking/wiki/Recommendation-software"> recommendation software<a>  for each species-antibiotic combination is based on our <a href="https://github.com/hzi-bifo/AMR_benchmarking">benchmarking work<a>. The <a href="https://github.com/hzi-bifo/AMR_benchmarking/wiki/Species-and-antibiotics"> "Number of genomes"<a>  column indicates the data size for training ML models.



## Prerequirements

- Linux (tested version: AlmaLinux 8.5 )
- Conda (tested version: Miniconda2 4.8.4)
- C++/11 capable compiler (e.g. gcc 4.7+, clang 3.5+, Apple/clang 6.0+).
  
  
  
## <a name="input"></a>Input file
The input file is a yaml file `Config.yaml` at the root folder where all options are described:

**A. Basic/required parameters setting**

- Please change everything in A after the ":" to your own.

| option | action | values ([default])|
| ------------- | ------------- |------------- |
|samplePath|Sample to be tested. each genome should be stored in one fna file. | |
|output_path| To where to generate the `Results` folder for the direct results of each software and further visualization. | ./|
|log_path| To where to generate the `log` folder for the intermediate files, which you can delete by hand afterward.| ./|
|n_jobs| CPU cores to use.| 1 |
|species|||
|SampleName|||
|folds_setting|Phylogeny background.Can be one of: close, low_similarity, distant_phylo||
|Software| Can be one or multiple (separated by ",") of: PhenotypeSeeker, Kover, ResFinder||

**B.Optional parameters setting**

- Please change the conda environment names if the same names already exist in your working PC.




## Install

```
cd install
bash ./install.sh amr_env
```





## Reference
1. DSK https://github.com/GATB/dsk accessed on April 2022

2. ResFinder 4.0 https://bitbucket.org/genomicepidemiology/resfinder/src/master/ accessed on May 2021
  
3. Kover2.0 
  
4. PhenotypeSeeker 0.7.3
 
