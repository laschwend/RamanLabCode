# -*- coding: utf-8 -*-
"""
Created on Tue Mar  5 11:56:46 2024

@author: Tamara
"""

import argparse
import image_analysis_minimal_estim as ia
from pathlib import Path
import matplotlib.pyplot as plt
import plot_MAD as mad
import os

# Function that tests if the user input path contains backslashes and if so, 
# changes them into forward slashes
def normalize_path(folder_path):
    """Normalize folder path to use forward slashes."""
    # Check if the folder path contains backslashes
    if "\\" in folder_path:
        # Replace backslashes with forward slashes
        folder_path = folder_path.replace("\\", "/")
    # If the folder path mistakenly ends with a quotation mark, remove it
    if folder_path.endswith('"'):
       folder_path = folder_path[:-1]
    return folder_path

parser = argparse.ArgumentParser()
parser.add_argument("input_folder", help="the user input folder location")
args = parser.parse_args()
input_folder_str = args.input_folder

# "Normalize" folder name, to ensure that the code will run irrespective of how the path is written in the terminal
input_folder = Path(normalize_path(input_folder_str))

# Get the name of the folder in which the video (i.e. series of tiff) is stored
folder_name = os.path.basename(input_folder)

# Run the tracking
print(f'Running tracking for {folder_name}')
ia.run_tracking(input_folder)

# run the tracking visualization
#col_min_abs = 0 # rescaling for very large displacements
#col_max_abs = 50 # rescaling for very large displacements
col_min_abs = 0 # for medium displacements
col_max_abs = 20 # for medium displacements
col_min_row = -4
col_max_row = 10
col_min_col = -4
col_max_col = 10
col_map = plt.cm.viridis
ia.run_visualization(input_folder, col_min_abs, col_max_abs, col_min_row, col_max_row, col_min_col, col_max_col, col_map = col_map)

plt.close()


# Generate the MAD plots
print(f'Generating MAD plots for {folder_name}')
mad.create_MAD_plots(input_folder)