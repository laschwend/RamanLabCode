# -*- coding: utf-8 -*-
"""
Created on Sun Jul  7 15:39:28 2024

@author: Laura Schwendeman

Purpose: to format the data for superviolin
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
pathName = "C:/Users/laSch/Desktop/Raman Lab/RamanlabCode/AlignmentCode2024/Directionality Tables C2C12_2/"
pathName = "C:/Users/laSch/Desktop/Raman Lab/RamanlabCode/AlignmentCode2024/Directionality Tables Human_2/"
#pathName = "C:/Users/laSch/Desktop/Raman Lab/RamanlabCode/AlignmentCode2024/Directionality Tables C2C12_3/"
#pathName = "C:/Users/laSch/Desktop/Raman Lab/RamanlabCode/AlignmentCode2024/Directionality Tables Human_3/"
#sizeNames = ["25", "125", "250", "unstamped", "flat"]
sizeNames = ["12pt5", "25", "125", "unstamped", "flat"]
sizeVals = ["12.5", "25", "125", "flat", "unstamped"]; 

repNames = [1,2,3]; 

locationNames = [""]#["R", "L", "center", "top", "bottom"]

#note, need to already have this csv made in excel, or write 
#code to make a new .csv file
saveName = "Violin_Human_Angles.csv"
savePathName = "C:/Users/laSch/Desktop/Raman Lab/RamanlabCode/superviolin-master/superviolin/superviolin/res/"

saveFileN = savePathName + saveName


row_counter = 1  #change to add at later rows

numRepeatsTotal = 1000 #this is the total number of "samples" that the code will put into a spreadsheet for each condition


#initialize the dataframe with all the info
dataLogged = pd.DataFrame({
    'Angle': [], 
    'rep': [],
    'category': [],
    'condition': []
     })

#loop through all the conditions
for size in sizeNames:
    for rep in repNames:
        for loc in locationNames:
            
            #get the file name
            #fileName = pathName + size+"_rep" + str(rep) + "_4x_stitched_stack" + loc + "-MaxIP_table"
            fileName = pathName + size+"_rep" +str(rep) + "4x_fullWellFiltered_table"
            #picName = "C:/Users/laSch/Dropbox(MIT)/RamanLab/LauraSchwendeman/20240...dpics/otherreplicates/" + size+"_rep" + str(rep) + "_4x" + loc + "-MaxIP"
            picName = "C:/Users/laSch/Dropbox(MIT)/RamanLab/LauraSchwendeman/20240...itchedpics/otherreplicates/12pt5_rep14x_fullWellFiltered"
           
            #this is from how I saved the files, if you change the imageJ script, you could drop a .csv
            csvFileName = fileName+".csv.csv"
            
            #open the file w/ pandas (note, imagej encodes csvs a little weird)
            tabl = pd.read_csv(csvFileName, encoding = "cp1252")
            
            #fit the data to a gaussian
            x = tabl["Direction (°)"]
            y = tabl[tabl.columns[1]]#tabl["frame_0210"]
            
            #convert the x values into repeats for superviolin
            counts = y * numRepeatsTotal
            counts = counts.astype(int)  # Convert to integer counts
            
            #also determine whether the sheet corresponds to grooved or not grooved
            if size == "flat" or size == "unstamped":
                cate = 'ungrooved'
            else:
                cate = 'grooved'

            # Repeat the x-values according to their counts
            repeated_x_values = np.repeat(x.to_numpy(), counts)
            numRep = len(repeated_x_values)
            repeated_rep_values = np.repeat(rep, numRep)
            repeated_category_values = np.repeat(cate, numRep)
            repeated_condition_values = np.repeat(size, numRep)

            # Create a DataFrame
            data = pd.DataFrame({
                'Angle': repeated_x_values, 
                'rep': repeated_rep_values,
                'category': repeated_category_values,
                'condition': repeated_condition_values
                })
            
            dataLogged = pd.concat([dataLogged, data])
            
            
            print('Done: ', size + str(rep))
            
           # row_counter = row_counter + numRep
            

dataLogged.to_csv(saveFileN, index = False)
            
            