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
pathName = "C:/Users/laSch/Desktop/Raman Lab/RamanLabCode/AlignmentCode2024/Directionality Tables Human/"

#sizeNames = ["25", "125", "250", "unstamped", "flat"]
sizeNames = ["12pt5", "62pt5", "125", "unstamped", "flat"]

repNames = [1,2,3]; 

locationNames = ["R", "L", "center", "top", "bottom"]

#note, need to already have this csv made in excel, or write 
#code to make a new .csv file
saveName = "Summary_Table_Human.csv"

saveFileN = pathName + saveName


row_counter = 1  #change to add at later rows

#loop through all the conditions
for size in sizeNames:
    for rep in repNames:
        for loc in locationNames:
            
            #get the file name
            fileName = pathName + size+"_rep" + str(rep) + "_10x_" + loc + "_7.0-10.0sectable"
            
            #this is from how I saved the files, if you change the imageJ script, you could drop a .csv
            csvFileName = fileName+".csv.csv"
            
            #open the file w/ pandas (note, imagej encodes csvs a little weird)
            tabl = pd.read_csv(csvFileName, encoding = "cp1252")
            
            #fit the data to a gaussian
            x = tabl["Direction (°)"]
            y = tabl["frame_0210"]
            
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
            
            #save the data into the table
            data = {
                'Stamp_Parameters': size, 
                'rep': rep, 
                'location': loc,
                'mean_angle': mean_fit, 
                'stdd':stddev_fit,
                'goodness_of_fit': r_squared
                }
            
            newTabl = pd.read_csv(saveFileN)
            newTabl.loc[row_counter] = data
            
            newTabl.to_csv(saveFileN, index = False)
            
            print('Done: ', row_counter)
            
            row_counter = row_counter + 1
            
            
            
            
            
            
            
   
            
            
            
            
            
            
            
            
            