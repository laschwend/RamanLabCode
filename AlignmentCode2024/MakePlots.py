# -*- coding: utf-8 -*-
"""
Created on Wed Mar 20 15:23:42 2024

@author: laSch

Purpose: Plot Directionality Data accross different conditions
"""

import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import plotly.express as px

#Select which dataset to run through, can add more options or remove options
dataSett = 3.0; #1 = C2C12, #2 = Human

if dataSett == 1.0:
     pathName = "C:/Users/laSch/Desktop/Raman Lab/AligmentProject2024Code/Directionality Tables/"
     saveName = "Summary_Data.csv"
     labelName = "C2C12"
elif dataSett == 3.0:
    pathName = "C:/Users/laSch/Desktop/Raman Lab/RamanlabCode/AlignmentCode2024/Directionality Tables C2C12_2/"
    saveName = "Summary_Tables.csv"
    labelName = "C2C12 Round 2"
else:
    pathName = "C:/Users/laSch/Desktop/Raman Lab/AligmentProject2024Code/Directionality Tables Human/"
    saveName = "Summary_Table_Human.csv"
    labelName = "Human"   
    
        
        

#load the excel file of choice


fileName = pathName+saveName


#open the csv file with pandas
data = pd.read_csv(fileName)


#make a plot comparing mean across stamps
    #a scatterplot
plt.figure()
sns.stripplot(x=data.Stamp_Parameters, y=data.mean_angle, hue=data.location, data = data)
plt.title(labelName+ ' Data')
 
plt.figure()
sns.stripplot(x=data.Stamp_Parameters, y=data.mean_angle, hue=data.rep)
plt.title(labelName+ ' Data')
    
    #polar scatterplot


#make a plot comparing standard deviation across stamps

    #a scatterplot
plt.figure()
sns.stripplot(x=data.Stamp_Parameters, y=data.stdd, hue = data.location)
plt.title(labelName+ ' Data')

plt.figure()
sns.stripplot(x=data.Stamp_Parameters, y=data.stdd, hue=data.rep)
plt.title(labelName+ ' Data')
    
    #polar scatterplot

#make a plot comparing the goodness of fit
#a scatterplot
plt.figure()
sns.stripplot(x=data.Stamp_Parameters, y=data.goodness_of_fit, hue = data.location)
plt.title(labelName+ ' Data')

plt.figure()
sns.stripplot(x=data.Stamp_Parameters, y=data.goodness_of_fit, hue=data.rep)
plt.title(labelName+ ' Data')



#Make a plot with just one location shown
plt.figure()
stringLocation = 'center'
dataSubset = data[data.location == stringLocation]
sns.stripplot(x=dataSubset.Stamp_Parameters, y=dataSubset.mean_angle, hue=data.rep)
plt.title(labelName+ ' Data at ' + stringLocation)


plt.figure()
stringLocation = 'R'
dataSubset = data[data.location == stringLocation]
sns.stripplot(x=dataSubset.Stamp_Parameters, y=dataSubset.mean_angle, hue=data.rep)
plt.title(labelName+ ' Data at ' + stringLocation)


plt.figure()
stringLocation = 'L'
dataSubset = data[data.location == stringLocation]
sns.stripplot(x=dataSubset.Stamp_Parameters, y=dataSubset.mean_angle, hue=data.rep)
plt.title(labelName+ ' Data at ' + stringLocation)


plt.figure()
stringLocation = 'bottom'
dataSubset = data[data.location == stringLocation]
sns.stripplot(x=dataSubset.Stamp_Parameters, y=dataSubset.mean_angle, hue=data.rep)
plt.title(labelName+ ' Data at ' + stringLocation)

plt.figure()
stringLocation = 'top'
dataSubset = data[data.location == stringLocation]
sns.stripplot(x=dataSubset.Stamp_Parameters, y=dataSubset.mean_angle, hue=data.rep)
plt.title(labelName+ ' Data at ' + stringLocation)

#look at one replicate
plt.figure()
stringLocation = 1
dataSubset = data[data.rep == stringLocation]
sns.stripplot(x=dataSubset.Stamp_Parameters, y=dataSubset.mean_angle, hue=data.location)
plt.title(labelName+ ' Data at ' + str(stringLocation))

plt.figure()
stringLocation = 2
dataSubset = data[data.rep == stringLocation]
sns.stripplot(x=dataSubset.Stamp_Parameters, y=dataSubset.mean_angle, hue=data.location)
plt.title(labelName+ ' Data at ' + str(stringLocation))

