# -*- coding: utf-8 -*-
"""
Created on Wed Mar 20 07:09:56 2024

@author: laSch

Purpose: Fit Gaussians to the data from image J and make a new table with summary data in one .csv
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
pathName = "C:/Users/laSch/MIT Dropbox/Raman Lab/Laura Schwendeman/1_3_2025 Sonikas Stamp Analysis Copy/Stamp data analysis/C2C12 4x/Directionality_TablesM/"
pathName = "C:/Users/laSch/MIT Dropbox/Raman Lab/Laura Schwendeman/1_3_2025 Sonikas Stamp Analysis Copy/Stamp data analysis/Cook 4x/Directionality_TablesH/"

pathName = "C:/Users/laSch/MIT Dropbox/Raman Lab/Laura Schwendeman/1_3_2025 Sonikas Stamp Analysis Copy/Stamp data analysis/C2C12 4x/Directionality_TablesM_withoutFilter/"
pathName = "C:/Users/laSch/MIT Dropbox/Raman Lab/Laura Schwendeman/1_3_2025 Sonikas Stamp Analysis Copy/Stamp data analysis/Cook 4x/Directionality_TablesH_withoutFilter/"

#pathName = "C:/Users/laSch/Desktop/Raman Lab/RamanlabCode/AlignmentCode2024/Directionality Tables C2C12_2/"
#pathName = "C:/Users/laSch/Desktop/Raman Lab/RamanlabCode/AlignmentCode2024/Directionality Tables Human_3/"
#pathName = "C:/Users/laSch/Desktop/Raman Lab/RamanlabCode/AlignmentCode2024/Directionality Tables C2C12_3/"
#sizeNames = ["25", "125", "250", "unstamped", "flat"]
sizeNames = ["12pt5", "25", "125", "unstamped", "flat"]
sizeVals = ["12.5", "25", "125", "flat", "unstamped"]; 

#for First Pass
repNames = [1,2,3]; 

#for Revisions
C2C12Bool = 0

if C2C12Bool:
    #C2C12 Dictionary
    replicateDictionary = {
                "12pt5": [1,2,3,5,6],
                "25": [2, 3,4,5], 
                "125": [1,2,4,5],
                "unstamped": [1,2,3,4,5,6,7,8], 
                "flat": [1,2,3,4,5,6,7,8]
        
        }
else:
    #Human Dictionary
    replicateDictionary = {
                "12pt5": [1,2,4,6,7,8],
                "25": [1,2,5,6,7,9], 
                "125": [1,2,3,5],
                "unstamped": [1,2,3,4,5,6,7,8], 
                "flat": [1,2,3,4,5,6]
        
        }

locationNames = [""]#["R", "L", "center", "top", "bottom"]

#note, need to already have this csv made in excel, or write 
#code to make a new .csv file
saveName = "Summary_Tables.csv"

saveFileN = pathName + saveName


row_counter = 0  #change to add at later rows

#loop through all the conditions
for size in sizeNames:
    
    #
    repNames = replicateDictionary[size]
    
    for rep in repNames:
        for loc in locationNames:
            
            #get the file name
            if C2C12Bool: 
                fileName = pathName + "C2C12_4x_"+ size+"_rep" + str(rep) + "_fullWellFiltered_table"
            else: 
                fileName = pathName + "Cook_4x_"+ size+"_rep" + str(rep) + "_fullWellFiltered_table"
                
            #for new data with no filtering 1/8/2025
            if C2C12Bool: 
                fileName = pathName + "C2C12_4x_"+ size+"_rep" + str(rep) + "-MaxIP_table"
            else: 
                fileName = pathName + "Cook_4x_"+ size+"_rep" + str(rep) + "-MaxIP_table"
            # picName = "C:/Users/laSch/Dropbox(MIT)/RamanLab/LauraSchwendeman/20240...dpics/otherreplicates/" + size+"_rep" + str(rep) + "_4x" + loc + "-MaxIP"
            # picName = "C:/Users/laSch/Dropbox(MIT)/RamanLab/LauraSchwendeman/20240...itchedpics/otherreplicates/12pt5_rep14x_fullWellFiltered"
            # picName = "C:/Users/SonikaKohli/MITDropbox/RamanLab/SonikaKohli/Data...ataanalysis/C2C124x/C2C12_4x_" +size + "_rep" +str(rep) +"_fullWellFiltered"
            #this is from how I saved the files, if you change the imageJ script, you could drop a .csv
            csvFileName = fileName+".csv.csv"
            
            #open the file w/ pandas (note, imagej encodes csvs a little weird)
            tabl = pd.read_csv(csvFileName, encoding = "cp1252")
            
            #fit the data to a gaussian
            x = tabl["Direction (°)"]
            y = tabl[tabl.columns[1]]#tabl["frame_0210"]
            
            #if you want to fit different gaussian peeks, might want to play with these numbers
            #[amplitude, mean location, std, y offset], change everything besides mean location 
            #as needed if you don't find reasonable fits
            init_guess = [.05,x[np.argmax(y)],20,.001];
            
            params, covariance = curve_fit(gaussian, x,y,p0=init_guess, bounds = (0,np.inf))
            
            #get the mean and std and goodness of fit
            amplitude_fit, mean_fit, stddev_fit, offset_fit = params
            print(mean_fit)
            
            #for debugging, plot the gaussian fit
            plt.figure()
            plt.scatter(x, y, label='Data')
            plt.plot(x, gaussian(x, *params), color='red', label='Fit')
            plt.legend()
            plt.xlabel('X')
            plt.ylabel('Y')
            plt.title('Gaussian Fit to Data ' + size +" "+str(rep)+" "+loc)
            plt.show()
            
            
            #calculate the goodness of fit
            # Calculate the residuals
            residuals = y - gaussian(x, *params)
            
            # Calculate R-squared
            mean_y = np.mean(y)
            total_sum_of_squares = np.sum((y - mean_y) ** 2)
            residual_sum_of_squares = np.sum(residuals ** 2)
            r_squared = 1 - (residual_sum_of_squares / total_sum_of_squares)
            
            #calculate the cdf between 70-110 deg - in a cursed way bc I don't understand python logical indexing
            boundPercent = 20
            #arithmetic mean?
            mean_center = np.dot(x,y)
            print(mean_center)
            maxVal = x[np.argmax(y)]
            print(maxVal)
            y_70andup = y[x >= mean_center-boundPercent]
            x_70andup = x[x>= mean_center-boundPercent]
            
            y_70to110 = y_70andup[x_70andup <= mean_center+boundPercent]
            
            percentnear90 = sum(y_70to110)
            print(percentnear90)
            
            #also determine whether the sheet corresponds to grooved or not grooved
            if size == "flat" or size == "unstamped":
                cate = 'ungrooved'
            else:
                cate = 'grooved'
            
            #save the data into the table
            data = {
                'Stamp_Parameters': sizeVals[sizeNames.index(size)], 
                'rep': rep, 
                'location': loc,
                'mean_angle': mean_fit, 
                'stdd':stddev_fit,
                'goodness_of_fit': r_squared,
                'percent_near90': percentnear90,
                'Category': cate
                }
            
            newTabl = pd.read_csv(saveFileN)
            newTabl.loc[row_counter] = data
            
            newTabl.to_csv(saveFileN, index = False)
            
            print('Done: ', row_counter)
            
            row_counter = row_counter + 1
            
            
            
            
            
            
            
   
            
            
            
            
            
            
            
            
            