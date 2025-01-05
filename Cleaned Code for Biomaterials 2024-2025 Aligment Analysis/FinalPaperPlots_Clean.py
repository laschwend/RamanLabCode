# -*- coding: utf-8 -*-
"""
Created on Sat Jan  4 10:54:52 2025

@author: laSch

New More Efficient Plotting Code
"""


#libraries
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import plotly.express as px
import superviolin

import statsmodels.api as sm
from statsmodels.formula.api import ols
from statsmodels.stats.multicomp import pairwise_tukeyhsd
from scipy.stats import kruskal
from scipy.stats import mannwhitneyu
from statannotations.Annotator import Annotator

import itertools 

# Set the matplotlib parameters for the text to be editable in illustrator.
plt.rcParams['ps.fonttype'] = 42
plt.rcParams['pdf.fonttype'] = 42



#%% Functions
def addStatAnnot(xlab, ylab, title, pairs, ax, df):
    annotator = Annotator(ax, pairs, data = df, x = xlab, y = ylab)
    annotator.configure(test = 'Mann-Whitney', text_format = 'star')
    annotator.apply_and_annotate()
    
def makeViolinPlot(df, xvalues, yvalues, xlabelv, ylabelv, title,ylim):
    plt.figure()
    ax = sns.violinplot(data = df, x = xvalues, y = yvalues)
    sns.stripplot(x = xvalues, y = yvalues, data = df, color = "black")
    plt.xlabel(xlabelv)
    plt.ylabel(ylabelv)
    plt.title(title)
    if ylim[0] - ylim[1] != 0:
        plt.ylim(ylim[0], ylim[1])
        print("here")
    return ax
    
    
def savePlot(path, title, UvG):
    plt.savefig(path + title + UvG, dpi=300)
    
def alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, title, pairs, path, UvG, ylim):
    
    ax = makeViolinPlot(df, xvalues, yvalues, xlabelv, ylabelv, title, ylim)
    addStatAnnot(xlab, ylab, title, pairs, ax, df)
    savePlot(path, title,UvG)
    
    
    
#%% Setup Path and shared variables

#where to save the figure pictures
savePath = 'C:/Users/LaSch/MIT Dropbox/Raman Lab/Laura Schwendeman/1_3_2025 Sonikas Stamp Analysis Copy/1_3_24 Revision Plots Round 1/'

#different plot pairings
allLabels = ["12.5", "25", "125", "flat", "unstamped"]
pairAll = list(itertools.combinations(allLabels, 2))

pairUvG = [("ungrooved", "grooved")]

pairGrooved = [("12.5", "25"), ("12.5", "125"), ("25", "125")]

pairUngrooved = [("flat", "unstamped")]


#%% C2C12 Alignment Plots
pathName = "C:/Users/laSch/MIT Dropbox/Raman Lab/Laura Schwendeman/1_3_2025 Sonikas Stamp Analysis Copy/Stamp data analysis/C2C12 4x/Directionality_TablesM/"
saveName = "Summary_Tables.csv"
cellType = "C2C12"
titleName = cellType + " Fitted Mean Alignment Direction"

fileName = pathName+saveName

#open csv
df = pd.read_csv(fileName)
#to remove all 62.5 samples
df = df[df['Stamp_Parameters'] != "62.5"]

pal = sns.color_palette("husl", 8)

##Grooved vs Ungrooved
titleName = cellType + " % Near Mean (\N{DEGREE SIGN})"
xlabelv = "Stamp Condition"
ylabelv = "percent +-20 around mean"
xvalues = df.Category
yvalues = df.percent_near90
xlab = "Category"
ylab = "percent_near90"
pairs = pairUvG
UvG = "UvG"
ylim = [-.09, 1]

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)


##All Conditions
titleName = cellType + " % Near Mean (\N{DEGREE SIGN})"
xlabelv = "Stamp Size (um)"
ylabelv = "percent +-20 around mean"
xvalues = df.Stamp_Parameters
yvalues = df.percent_near90
xlab = "Stamp_Parameters"
ylab = "percent_near90"
pairs = pairAll
UvG = "All"
ylim = [-.09, 1]

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)



##ungrooved Conditions
    #make it so that only ungrooved ones show
conditionVals = ["flat", "unstamped"]
ungrooveddf = df[df["Stamp_Parameters"].isin(conditionVals)]

titleName = cellType + " % Near Mean (\N{DEGREE SIGN})"
xlabelv = "Stamp Size (um)"
ylabelv = "percent +-20 around mean"
xvalues = ungrooveddf.Stamp_Parameters
yvalues = ungrooveddf.percent_near90
xlab = "Stamp_Parameters"
ylab = "percent_near90"
pairs = pairUngrooved
UvG = "Ungrooved"
ylim = [-.09, 1]

alignmentPlot(ungrooveddf, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

##Grooved Conditions
    #make it so that only grooved ones show
conditionVals = ["12.5", "25", "125"]
stampeddf = df[df["Stamp_Parameters"].isin(conditionVals)]

titleName = cellType + " % Near Mean (\N{DEGREE SIGN})"
xlabelv = "Stamp Size (um)"
ylabelv = "percent +-20 around mean"
xvalues = stampeddf.Stamp_Parameters
yvalues = stampeddf.percent_near90
xlab = "Stamp_Parameters"
ylab = "percent_near90"
pairs = pairGrooved
UvG = "Grooved"
ylim = [-.09, 1]

alignmentPlot(stampeddf, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

#%% Human Alignment Plots
pathName = "C:/Users/laSch/MIT Dropbox/Raman Lab/Laura Schwendeman/1_3_2025 Sonikas Stamp Analysis Copy/Stamp data analysis/Cook 4x/Directionality_TablesH/"
saveName = "Summary_Tables.csv"
cellType = "Cook"
titleName = cellType + " Fitted Mean Alignment Direction"

fileName = pathName+saveName

#open csv
df = pd.read_csv(fileName)
#to remove all 62.5 samples
df = df[df['Stamp_Parameters'] != "62.5"]

pal = sns.color_palette("husl", 8)

##Grooved vs Ungrooved
titleName = cellType + " % Near Mean (\N{DEGREE SIGN})"
xlabelv = "Stamp Condition"
ylabelv = "percent +-20 around mean"
xvalues = df.Category
yvalues = df.percent_near90
xlab = "Category"
ylab = "percent_near90"
pairs = pairUvG
UvG = "UvG"
ylim = [-.09, 1]

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)


##All Conditions
titleName = cellType + " % Near Mean (\N{DEGREE SIGN})"
xlabelv = "Stamp Size (um)"
ylabelv = "percent +-20 around mean"
xvalues = df.Stamp_Parameters
yvalues = df.percent_near90
xlab = "Stamp_Parameters"
ylab = "percent_near90"
pairs = pairAll
UvG = "All"
ylim = [-.09, 1]

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)



##ungrooved Conditions
    #make it so that only ungrooved ones show
conditionVals = ["flat", "unstamped"]
ungrooveddf = df[df["Stamp_Parameters"].isin(conditionVals)]

titleName = cellType + " % Near Mean (\N{DEGREE SIGN})"
xlabelv = "Stamp Size (um)"
ylabelv = "percent +-20 around mean"
xvalues = ungrooveddf.Stamp_Parameters
yvalues = ungrooveddf.percent_near90
xlab = "Stamp_Parameters"
ylab = "percent_near90"
pairs = pairUngrooved
UvG = "Ungrooved"
ylim = [-.09, 1]

alignmentPlot(ungrooveddf, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

##Grooved Conditions
    #make it so that only grooved ones show
conditionVals = ["12.5", "25", "125"]
stampeddf = df[df["Stamp_Parameters"].isin(conditionVals)]

titleName = cellType + " % Near Mean (\N{DEGREE SIGN})"
xlabelv = "Stamp Size (um)"
ylabelv = "percent +-20 around mean"
xvalues = stampeddf.Stamp_Parameters
yvalues = stampeddf.percent_near90
xlab = "Stamp_Parameters"
ylab = "percent_near90"
pairs = pairGrooved
UvG = "Grooved"
ylim = [-.09, 1]

alignmentPlot(stampeddf, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)



#%%C2C12 Fiber Analysis Plots 
fileName = "C:/Users/laSch/MIT Dropbox/Raman Lab/Laura Schwendeman/1_3_2025 Sonikas Stamp Analysis Copy/Stamp data analysis/C2C12 40x/C2C12_Data_Summarized.xlsx"
cellType = "C2C12"
##Fusion Index
df = pd.read_excel(fileName, sheet_name = "Sheet1")
df = df[df['StampCondition'] != "62.5"]

    ##Grooved vs Ungrooved
titleName = cellType + " Fusion Index"
xlabelv = "Stamp Condition"
ylabelv = "Fusion Index"
xvalues = df.Category
yvalues = df.FusionIndex
xlab = "Category"
ylab = "FusionIndex"
pairs = pairUvG
UvG = "UvG"
ylim = [.09,1]

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

    ##All
titleName = titleName
xlabelv = xlabelv
ylabelv = ylabelv
xvalues = df.StampCondition
yvalues = yvalues
xlab = "StampCondition"
ylab = ylab
pairs = pairAll
UvG = "All"
ylim = ylim

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

## Nuclei per Fiber
df = pd.read_excel(fileName, sheet_name = "Sheet2")
df = df[df['StampCondition'] != "62.5"]

    ##Grooved vs Ungrooved
titleName = cellType + " Nuclei per Fiber"
xlabelv = "Stamp Condition"
ylabelv = "Number of Nuclei per Fiber"
xvalues = df.Category
yvalues = df.NumberOfNuclei
xlab = "Category"
ylab = "NumberOfNuclei"
pairs = pairUvG
UvG = "UvG"
ylim = [-1,-1] #-1,-1 is the flag for not fixing the axes

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

    ##All
titleName = titleName
xlabelv = xlabelv
ylabelv = ylabelv
xvalues = df.StampCondition
yvalues = yvalues
xlab = "StampCondition"
ylab = ylab
pairs = pairAll
UvG = "All"
ylim = ylim

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)



##Average Nuclei per Fiber
df = pd.read_excel(fileName, sheet_name = "Sheet5")
df = df[df['StampCondition'] != "62.5"]

    ##Grooved vs Ungrooved
titleName = cellType + " Nuclei per Fiber"
xlabelv = "Stamp Condition"
ylabelv = "Average Number of Nuclei per Fiber"
xvalues = df.Category
yvalues = df.AverageCount
xlab = "Category"
ylab = "AverageCount"
pairs = pairUvG
UvG = "UvG"
ylim = [-1,-1]

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

    ##All
titleName = titleName
xlabelv = xlabelv
ylabelv = ylabelv
xvalues = df.StampCondition
yvalues = yvalues
xlab = "StampCondition"
ylab = ylab
pairs = pairAll
UvG = "All"
ylim = ylim

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

##Fiber Width
df = pd.read_excel(fileName, sheet_name = "Sheet3")
df = df[df['StampCondition'] != "62.5"]
df.AverageWidthperFiber = df.AverageWidthperFiber*0.2157919

    ##Grooved vs Ungrooved
titleName = cellType + " Fiber Width per Fiber"
xlabelv = "Stamp Condition"
ylabelv = "Average Fiber Width per Fiber (um)"
xvalues = df.Category
yvalues = df.AverageWidthperFiber
xlab = "Category"
ylab = "AverageWidthperFiber"
pairs = pairUvG
UvG = "UvG"
ylim = [-1,-1]

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

    ##All
titleName = titleName
xlabelv = xlabelv
ylabelv = ylabelv
xvalues = df.StampCondition
yvalues = yvalues
xlab = "StampCondition"
ylab = ylab
pairs = pairAll
UvG = "All"
ylim = ylim

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

##Fiber Width Averaged
df = pd.read_excel(fileName, sheet_name = "Sheet4")
df = df[df['StampCondition'] != "62.5"]
df.AverageWidth = df.AverageWidth*0.257919

    ##Grooved vs Ungrooved
titleName = cellType + " Average Fiber Width"
xlabelv = "Stamp Condition"
ylabelv = "Average Fiber Width (um)"
xvalues = df.Category
yvalues = df.AverageWidth
xlab = "Category"
ylab = "AverageWidth"
pairs = pairUvG
UvG = "UvG"
ylim = [-1,-1]

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

    ##All
titleName = titleName
xlabelv = xlabelv
ylabelv = ylabelv
xvalues = df.StampCondition
yvalues = yvalues
xlab = "StampCondition"
ylab = ylab
pairs = pairAll
UvG = "All"
ylim = ylim

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

#Nuclei Circularity
df = pd.read_excel(fileName, sheet_name = "Sheet8")
df = df[df['StampCondition'] != "62.5"]

##Grooved vs Ungrooved
titleName = cellType + " Nuclei Circularity"
xlabelv = "Stamp Condition"
ylabelv = "Nuclei Circularity"
xvalues = df.Category
yvalues = df.AverageCircularity
xlab = "Category"
ylab = "AverageCircularity"
pairs = pairUvG
UvG = "UvG"
ylim = [0.09,1]

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

    ##All
titleName = titleName
xlabelv = xlabelv
ylabelv = ylabelv
xvalues = df.StampCondition
yvalues = yvalues
xlab = "StampCondition"
ylab = ylab
pairs = pairAll
UvG = "All"
ylim = ylim

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

#%% Human Fiber Analysis
fileName = "C:/Users/laSch/MIT Dropbox/Raman Lab/Laura Schwendeman/1_3_2025 Sonikas Stamp Analysis Copy/Stamp data analysis/Cook 40x/Cook_Data_Summarized.xlsx"
cellType = "Cook"

##Fusion Index
df = pd.read_excel(fileName, sheet_name = "Sheet1")
df = df[df['StampCondition'] != "62.5"]

    ##Grooved vs Ungrooved
titleName = cellType + " Fusion Index"
xlabelv = "Stamp Condition"
ylabelv = "Fusion Index"
xvalues = df.Category
yvalues = df.FusionIndex
xlab = "Category"
ylab = "FusionIndex"
pairs = pairUvG
UvG = "UvG"
ylim = [.09,1]

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

    ##All
titleName = titleName
xlabelv = xlabelv
ylabelv = ylabelv
xvalues = df.StampCondition
yvalues = yvalues
xlab = "StampCondition"
ylab = ylab
pairs = pairAll
UvG = "All"
ylim = ylim

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

## Nuclei per Fiber
df = pd.read_excel(fileName, sheet_name = "Sheet2")
df = df[df['StampCondition'] != "62.5"]

    ##Grooved vs Ungrooved
titleName = cellType + " Nuclei per Fiber"
xlabelv = "Stamp Condition"
ylabelv = "Number of Nuclei per Fiber"
xvalues = df.Category
yvalues = df.NumberOfNuclei
xlab = "Category"
ylab = "NumberOfNuclei"
pairs = pairUvG
UvG = "UvG"
ylim = [-1,-1] #-1,-1 is the flag for not fixing the axes

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

    ##All
titleName = titleName
xlabelv = xlabelv
ylabelv = ylabelv
xvalues = df.StampCondition
yvalues = yvalues
xlab = "StampCondition"
ylab = ylab
pairs = pairAll
UvG = "All"
ylim = ylim

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)



##Average Nuclei per Fiber
df = pd.read_excel(fileName, sheet_name = "Sheet5")
df = df[df['StampCondition'] != "62.5"]

    ##Grooved vs Ungrooved
titleName = cellType + " Nuclei per Fiber"
xlabelv = "Stamp Condition"
ylabelv = "Average Number of Nuclei per Fiber"
xvalues = df.Category
yvalues = df.AverageCount
xlab = "Category"
ylab = "AverageCount"
pairs = pairUvG
UvG = "UvG"
ylim = [-1,-1]

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

    ##All
titleName = titleName
xlabelv = xlabelv
ylabelv = ylabelv
xvalues = df.StampCondition
yvalues = yvalues
xlab = "StampCondition"
ylab = ylab
pairs = pairAll
UvG = "All"
ylim = ylim

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

##Fiber Width
df = pd.read_excel(fileName, sheet_name = "Sheet3")
df = df[df['StampCondition'] != "62.5"]
df.AverageWidthperFiber = df.AverageWidthperFiber*0.2157919

    ##Grooved vs Ungrooved
titleName = cellType + " Fiber Width per Fiber"
xlabelv = "Stamp Condition"
ylabelv = "Average Fiber Width per Fiber (um)"
xvalues = df.Category
yvalues = df.AverageWidthperFiber
xlab = "Category"
ylab = "AverageWidthperFiber"
pairs = pairUvG
UvG = "UvG"
ylim = [-1,-1]

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

    ##All
titleName = titleName
xlabelv = xlabelv
ylabelv = ylabelv
xvalues = df.StampCondition
yvalues = yvalues
xlab = "StampCondition"
ylab = ylab
pairs = pairAll
UvG = "All"
ylim = ylim

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

##Fiber Width Averaged
df = pd.read_excel(fileName, sheet_name = "Sheet4")
df = df[df['StampCondition'] != "62.5"]
df.AverageWidth = df.AverageWidth*0.257919

    ##Grooved vs Ungrooved
titleName = cellType + " Average Fiber Width"
xlabelv = "Stamp Condition"
ylabelv = "Average Fiber Width (um)"
xvalues = df.Category
yvalues = df.AverageWidth
xlab = "Category"
ylab = "AverageWidth"
pairs = pairUvG
UvG = "UvG"
ylim = [-1,-1]

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

    ##All
titleName = titleName
xlabelv = xlabelv
ylabelv = ylabelv
xvalues = df.StampCondition
yvalues = yvalues
xlab = "StampCondition"
ylab = ylab
pairs = pairAll
UvG = "All"
ylim = ylim

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

#Nuclei Circularity
df = pd.read_excel(fileName, sheet_name = "Sheet8")
df = df[df['StampCondition'] != "62.5"]

##Grooved vs Ungrooved
titleName = cellType + " Nuclei Circularity"
xlabelv = "Stamp Condition"
ylabelv = "Nuclei Circularity"
xvalues = df.Category
yvalues = df.AverageCircularity
xlab = "Category"
ylab = "AverageCircularity"
pairs = pairUvG
UvG = "UvG"
ylim = [0.09,1]

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)

    ##All
titleName = titleName
xlabelv = xlabelv
ylabelv = ylabelv
xvalues = df.StampCondition
yvalues = yvalues
xlab = "StampCondition"
ylab = ylab
pairs = pairAll
UvG = "All"
ylim = ylim

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, pathName, UvG, ylim)


