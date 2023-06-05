import yaml
import os
from pprint import pprint
import sys
import argparse
import re



class arguments:
    # The object of arguments, as argparse is replaced
    def add_opt(self, **entries):
        self.__dict__.update(entries)
    def print_args(self):
        pprint(vars(self))



def parse_arg_yaml(yml_f):
    # read the arguments
    opt_dict = {}
    with LoadFile(yml_f) as yml_fh:
        opt_dict = yaml.safe_load(yml_fh)
    args = arguments() #get arguments
    try:
        args.add_opt(**opt_dict['samplePath'])
        args.add_opt(**opt_dict['species'])
        args.add_opt(**opt_dict['folds_setting'])
        args.add_opt(**opt_dict['Software'])
    except KeyError as e:
        sys.exit('ERROR: {} not found in the input file'.format(str(e)))



def make_parser():
    # Find the yaml file of arguments
    parser = argparse.ArgumentParser(
        prog='AMR_predictor',
        formatter_class=argparse.RawTextHelpFormatter,
        description=''' ''')
    parser.add_argument('-f', dest='yml_f', required=False, default='',
                        help='the yaml file where the arguments are listed')

    return(parser)


def main():
    parser = make_parser()
    primary_args = parser.parse_args()

    args = parse_arg_yaml(primary_args.yml_f)
    # display the primary arguments only
    if primary_args.dsply_args:
        args.print_args()
        sys.exit(0)

    return(args)
