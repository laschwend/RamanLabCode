# -*- coding: utf-8 -*-
"""
Created on Wed Mar  6 14:56:50 2024

@author: Tamara
"""

import os
import argparse
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser() # could add a description here
parser.add_argument("directory_name", help="the user input directory location")
args = parser.parse_args()

directory_name = args.directory_name
directory = Path(directory_name)

# Get a list of all the filenames of the videos to convert
all_subfolders = os.listdir(directory)

# Convert each video of the folder into a series of tiff
for i in range(len(all_subfolders)):
    current_path = directory.joinpath(all_subfolders[i]).resolve()
    subprocess.run(f'python RamanlabCode/Copy_Of_Tamaras_Code/faster_minimal_estim_analysis_code/run_minimal_code_estim.py "{current_path}"', shell=True)
    #subprocess.run(f'python run_code_estim.py "{current_path}"') # Did not work on Ronald's computer