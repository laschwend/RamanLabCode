# -*- coding: utf-8 -*-
"""
Created on Mon Jul 28 09:28:09 2025

@author: laura schwendeman

Purpose: To view a volume image of a z-stack interactively

"""

import numpy as np
import napari
from nd2reader import ND2Reader
import matplotlib.pyplot as plt


# Load the file
directory = 'C:/Users/laSch/MIT Dropbox/Raman Lab/Laura Schwendeman/7_25_25 leak test r1 - 11-8-345/'
name = '11-8-3_AB_channel_20x.nd2'
file_path = directory + name

with ND2Reader(file_path) as images:
    plt.show(images[0])

