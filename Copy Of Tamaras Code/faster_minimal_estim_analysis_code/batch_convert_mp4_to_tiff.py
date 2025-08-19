# -*- coding: utf-8 -*-
"""
For batch conversion of mp4 videos to tiff (need to be stored in a single folder,
which only contains these videos and no other file)

Created on Fri Mar  1 15:14:57 2024
@author: Tamara
"""

import mp4_to_tiff as convert
import os
import argparse
from pathlib import Path

parser = argparse.ArgumentParser() # could add a description here
parser.add_argument("directory_name", help="the user input directory location")
parser.add_argument("-start", "--start_timepoint", type=float, required=False)
parser.add_argument("-end", "--end_timepoint", type=float, required=False)
args = parser.parse_args()

directory_name = args.directory_name
start_timepoint = args.start_timepoint
end_timepoint = args.end_timepoint

# Get a list of all the filenames of the videos to convert
all_files = os.listdir(directory_name)

# Convert each video of the folder into a series of tiff
for i in range(len(all_files)):
    # defines the current filename, without the .mp4 extension (last 4 characters)
    current_filename = Path(all_files[i]).stem
    convert.mp4_to_tiff(directory_name, current_filename, start_timepoint, end_timepoint)
