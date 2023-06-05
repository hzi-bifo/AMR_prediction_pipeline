#!/usr/bin/env python3


import os
import sys
from tqdm import tqdm
import shutil
from Processes import Process
import UserOptions
from CollectResults import collect_results
import LogGenerator
import create_config

# ensure the core environment variable
assert 'AMR_HOME' in os.environ, 'AMR_HOME not available'
sys.path.append(os.environ['AMR_HOME'])
sys.path.append(os.path.join(os.environ['AMR_HOME'], 'main'))



def filter_procs(args, logger):
    # Determine which procedures to include
    config_files = {}
    # accept config files
    try:
        config_files = create_config.main(args, logger)
    except FileNotFoundError as e:
        logger.error(e)
        sys.exit()

    all_processes = []
    # >>>
    # initiate processes

    # expr
    if args.expr == 'Y':
        # ensure required data
        all_processes.append(SGProcess(
            args.wd, 'expr',
            config_f=config_files['expr'],
            dryrun=args.dryrun,
            mem_mb=int(args.mem_mb),
            max_cores=int(args.cores)))
    else:
        logger.info('Skip counting expression levels')

    # snps
    if args.snps == 'Y':
        # ensure required data
        all_processes.append(
            SGProcess(args.wd, 'snps',
                      config_f=config_files['snps'],
                      dryrun=args.dryrun,
                      mem_mb=int(args.mem_mb),
                      max_cores=int(args.cores)))
    else:
        logger.info('Skip calling single nucleotide variants')

    # denovo
    if args.denovo == 'Y':
        # ensure required data
        all_processes.append(
            SGProcess(args.wd, 'denovo',
                      config_f=config_files['denovo'],
                      dryrun=args.dryrun,
                      mem_mb=int(args.mem_mb),
                      max_cores=int(args.cores)))
    else:
        logger.info('Skip creating de novo assemblies')



    return({'selected': all_processes, 'config_files': config_files})


def main(args, logger):
    determined_procs = filter_procs(args, logger)
    config_files = determined_procs['config_files']
    all_processes = determined_procs['selected']
    # >>>
    # start running processes
    processes_num = len(all_processes)+1
    pbar = tqdm(total=processes_num,
                desc="\namr")
    for p in all_processes:
        p.run_proc(logger)
        pbar.update(1)
    if args.dryrun != 'Y':
        # collect_results #todo
        pass
    logger.info('Working directory {} {}'.format(
        args.wd, 'updated' if args.dryrun != 'Y' else 'unchanged'))
    pbar.update(1)

    pbar.close()


if __name__ == '__main__':
    # create logger
    logger = LogGenerator.make_logger(primary_args.log_f)
    # check those primary arguments
    logger.info('Parse arguments')
    args = UserOptions.parse_arg_yaml(primary_args.yml_f)
    args.print_args()
    exit()
    # display the primary arguments only
    if primary_args.dsply_args:
        sys.exit(0)

    # run in local machine
    main(args, logger)


    logger.info('DONE (local mode)')
