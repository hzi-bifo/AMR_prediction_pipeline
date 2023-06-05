
import os
import shutil
import pandas as pd
import logging
configfile: "../../Config.yaml"

rule all:
    input:
        expand("{sample}.{param}.output.pdf", sample=config["samples"], param=config["yourparam"])

