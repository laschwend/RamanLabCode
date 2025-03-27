# -*- coding: utf-8 -*-
"""
Created on Thu Jun  6 14:11:41 2024

@author: laSch

Purpose: generate excel data to use with Superviolin plot, makes 1 big spreadsheet with all the bins and direction values 
repeated according to their weights in the histogram (this probably breaks statistics from superviolin as a warning, edit the code later)
The relative shapes and means in the violin plot are correct, need to scale the Stddev appropriately
"""

from scipy.optimize import curve_fit
import numpy as np
import pandas as pd
import os
import matplotlib.pyplot as plt

#functions
def gaussian(x, amplitude, mean, stddev, offset):
    return offset + (amplitude-offset) * np.exp(-((x - mean) / (stddev)) ** 2 / 2)        
         

#the arrays with the data names
#pathName = "C:/Users/laSch/Desktop/Raman Lab/AligmentProject2024Code/Directionality Tables/"
#pathName = "C:/Users/laSch/Desktop/Raman Lab/RamanLabCode/AlignmentCode2024/Directionality Tables Human/"
pathName = "C:/Users/laSch/Desktop/Raman Lab/RamanlabCode/AlignmentCode2024/Directionality Tables Human_2/"
#sizeNames = ["25", "125", "250", "unstamped", "flat"]
sizeNames = ["12pt5", "25", "62pt5", "125", "unstamped", "flat"]
sizeVals = ["12.5", "25", "62.5", "125", "flat", "unstamped"]; 

repNames = [1,2,3]; 

locationNames = [""]#["R", "L", "center", "top", "bottom"]

#note, need to already have this csv made in excel, or write 
#code to make a new .csv file
saveName = "Violin_Summary_Tables.csv"

saveFileN = pathName + saveName


row_counter = 1  #change to add at later rows

#loop through all the conditions
for size in sizeNames:
    for rep in repNames:
        for loc in locationNames:
            
            #get the file name
            fileName = pathName + size+"_rep" + str(rep) + "_4x" + loc + "-MaxIP_table"
            picName = "C:/Users/laSch/Dropbox(MIT)/RamanLab/LauraSchwendeman/20240...dpics/otherreplicates/" + size+"_rep" + str(rep) + "_4x" + loc + "-MaxIP"
            
            #this is from how I saved the files, if you change the imageJ script, you could drop a .csv
            csvFileName = fileName+".csv.csv"
            
            #open the file w/ pandas (note, imagej encodes csvs a little weird)
            tabl = pd.read_csv(csvFileName, encoding = "cp1252")
            
            
            #directionIndx counter
            dirCount = 0
            y = tabl[tabl.columns[1]]
            x = tabl["Direction (°)"]
            
            for dataPt in y:
                #Get the approximate number out of 10000 for each direction
                for i in range(1,round(dataPt*10000)):
                
                     
                    #save the data into the table
                    data = {
                        'direction': x[dirCount],
                        'value': dataPt,
                        'Stamp_Parameters': sizeVals[sizeNames.index(size)], 
                        'rep': rep, 
                        }
                    
                    newTabl = pd.read_csv(saveFileN)
                    newTabl.loc[row_counter] = data
                    
                    newTabl.to_csv(saveFileN, index = False)
                    
                   
                    
                    row_counter = row_counter + 1
                
                dirCount = dirCount + 1
                
            print("done: ", size)    
    
