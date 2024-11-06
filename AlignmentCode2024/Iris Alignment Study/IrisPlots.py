# -*- coding: utf-8 -*-
"""
Created on Fri Jul 26 15:45:18 2024

@author: laSch

Purpose: Make plots of the Iris Alignment directionality distributions

"""
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import plotly.express as px

plt.rcParams['ps.fonttype'] = 42
plt.rcParams['pdf.fonttype'] = 42

folderName = ''
#fileNames = ['Radial', 'Circumfrential', 'Interface']
fileNames = ['Iris_Flor_circumfrential_top', 'Iris_Flor_boundary','Iris_Flor_radial' ]
fileTypeName = '.tif_table.csv'

for name in fileNames:
    
    #put together the file name
    fullName = folderName + name + fileTypeName
    
    #open the file w/ pandas (note, imagej encodes csvs a little weird)
    tabl = pd.read_csv(fullName, encoding = "cp1252")
    
    #fit the data to a gaussian
    x = tabl["Direction (°)"]
    y = tabl[tabl.columns[1]]#tabl["frame_0210"]
    
    
    #plot the results
    plt.figure()
    plt.plot(x,y)
    plt.xlabel("direction ()")
    plt.ylabel("amount")
    plt.title(name)
    plt.xlim(0, 90)
    
    #historgram?
    plt.figure()
    plt.bar(x,y)
    plt.xlabel("direction ()")
    plt.ylabel("normalized intensity")
    plt.title(name)
    plt.xlim(0, 90)
    plt.ylim(0,0.03)
    
    
    #save the plot
    plt.savefig( name +'.pdf', dpi=300)
    