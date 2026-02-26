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
#import superviolin

import statsmodels.api as sm
from statsmodels.formula.api import ols
from statsmodels.stats.multicomp import pairwise_tukeyhsd
# from scipy.stats import kruskal
# from scipy.stats import mannwhitneyu
from statannotations.Annotator import Annotator
from scipy import stats
import scikit_posthocs as sp

import itertools 

# Set the matplotlib parameters for the text to be editable in illustrator.
plt.rcParams['ps.fonttype'] = 42
plt.rcParams['pdf.fonttype'] = 42
plt.rcParams['axes.spines.right'] = False
plt.rcParams['axes.spines.top'] = False


#%% Functions

def addStatAnnot(xlab, ylab, title, pairs, ax, df):
    
   # Extract unique groups from the x-axis variable
    groups = df[xlab].unique()

    # Prepare data for normality test
    group_data = [df[df[xlab] == group][ylab] for group in groups]

    # Perform Shapiro-Wilk normality test on each group
    normal = all(stats.shapiro(data)[1] > 0.05 for data in group_data)

    # Choose the appropriate test based on normality
    if normal:
        # Perform one-way ANOVA
        f_stat, p_value = stats.f_oneway(*group_data)
        print(title + " Anova p-value: ", p_value)
        test = 'ANOVA'
        if p_value < 0.05:
            # Perform Tukey's HSD post hoc test
            posthoc = sp.posthoc_tukey(df, val_col=ylab, group_col=xlab)
            
    else:
        # Perform Kruskal-Wallis test
        h_stat, p_value = stats.kruskal(*group_data)
        test = 'Kruskal-Wallis'
        print(title + " Kruskal-Wallis p-value: ", p_value)
        if p_value < 0.05:
            # Perform Dunn's post hoc test with Bonferroni correction
            posthoc = sp.posthoc_dunn(df, val_col=ylab, group_col=xlab, p_adjust='bonferroni')
            print(posthoc)

    
    if p_value < 0.05:
        # Create a dictionary of p-values for the specified pairs
        p_values = {}
        pairs_new = []
        for pair in pairs:
            if len(pairs) != 1: #use the post hoc test
                group1, group2 = pair
                #if posthoc.loc[group1, group2] < 0.05:
                p_values[pair] = posthoc.loc[group1, group2]
                pairs_new.append(pair)  
            else: #use the Kruskal Wallis or Anova Test
                group1, group2 = pair
                #if posthoc.loc[group1, group2] < 0.05:
                p_values[pair] = p_value
                pairs_new.append(pair) 
                
         # Map the p-values to each pair
        p_values_list = [p_values[pair] for pair in pairs_new]
        #print(p_values_list)
        # Annotate the plot with statistical significance
        annotator = Annotator(ax, pairs_new, data=df, x=xlab, y=ylab)
        # Configure and apply the annotations
        annotator.configure(test=None, text_format='star', loc='inside', verbose=1)
        annotator.set_pvalues_and_annotate(p_values_list)
        #annotator.annotate()
        
    else:
        print(f"No significant differences found with {test} (p = {p_value:.3f})")
        # Create a dictionary of p-values for the specified pairs
        p_values = {}
        pairs_new = []
        
        for pair in pairs:
            group1, group2 = pair
            #set all comparisons to N.S.
            p_values[pair] = .99 
            pairs_new.append(pair)     
                
         # Map the p-values to each pair
        p_values_list = [p_values[pair] for pair in pairs_new]
        #print(p_values_list)
        # Annotate the plot with statistical significance
        annotator = Annotator(ax, pairs_new, data=df, x=xlab, y=ylab)
        # Configure and apply the annotations
        annotator.configure(test=None, text_format='star', loc='inside', verbose=1)
        annotator.set_pvalues_and_annotate(p_values_list)
        #annotator.annotate()
        
        
    print("\n")
        
        
    # annotator = Annotator(ax, pairs, data = df, x = xlab, y = ylab)
    # annotator.configure(test = 'Mann-Whitney', text_format = 'star')
    # annotator.apply_and_annotate()
    
def addStatAnnot_Tamaras(xlab, ylab, title, pairs, ax, df, displayNS):
    test = None  # Define test variable at the beginning of the function
    if displayNS:
        # Extract unique groups from the x-axis variable
        groups = df[xlab].unique()

        # Prepare data for normality test
        group_data = [df[df[xlab] == group][ylab] for group in groups]

        # Perform Shapiro-Wilk normality test on each group
        normal = all(stats.shapiro(data)[1] > 0.05 for data in group_data)

        # Choose the appropriate test based on normality
        if normal:
            if len(pairs) > 1:
                # Perform one-way ANOVA
                f_stat, p_value = stats.f_oneway(*group_data)
                print(title + " Anova p-value: ", p_value)
                test = 'ANOVA'
                if p_value < 0.05:
                    # Perform Tukey's HSD post hoc test
                    posthoc = sp.posthoc_tukey(df, val_col=ylab, group_col=xlab)
            elif len(pairs) == 1:
                ttest_res = stats.ttest_ind(*group_data)
                p_value = ttest_res.pvalue
                test = 't-test'

        else:
            if len(pairs) > 1:
                # Perform Kruskal-Wallis test
                h_stat, p_value = stats.kruskal(*group_data)
                test = 'Kruskal-Wallis'
                print(title + " Kruskal-Wallis p-value: ", p_value)
                if p_value < 0.05:
                    # Perform Dunn's post hoc test with Bonferroni correction
                    posthoc = sp.posthoc_dunn(df, val_col=ylab, group_col=xlab, p_adjust='bonferroni')
                    print(posthoc)
            elif len(pairs) == 1:
                mw_res = stats.mannwhitneyu(*group_data)
                p_value = mw_res.pvalue
                test = 'Mann-Whitney U'

        if ((p_value < 0.05) & (len(pairs) > 1)):
            # Create a dictionary of p-values for the specified pairs
            p_values = {}
            pairs_new = []
            for pair in pairs:
                group1, group2 = pair
                p_values[pair] = posthoc.loc[group1, group2]
                pairs_new.append(pair)
             # Map the p-values to each pair
            p_values_list = [p_values[pair] for pair in pairs_new]
            # Annotate the plot with statistical significance
            annotator = Annotator(ax, pairs_new, data=df, x=xlab, y=ylab)
            # Configure and apply the annotations
            annotator.configure(test=None, text_format='star', loc='inside', verbose=1)
            annotator.set_pvalues_and_annotate(p_values_list)
        elif ((p_value < 0.05) & (len(pairs) == 1)):
            annotator = Annotator(ax, pairs, data=df, x=xlab, y=ylab)
            # Configure and apply the annotations
            annotator.configure(test=None, text_format='star', loc='inside', verbose=1)
            annotator.set_pvalues_and_annotate([p_value])  # Wrap p_value in a list here
        else:
            p_values_list = np.ones(len(pairs))
            print(f"No significant differences found with {test} (p = {p_value:.3f})")
            annotator = Annotator(ax, pairs, data=df, x=xlab, y=ylab)
            # Configure and apply the annotations
            annotator.configure(test=None, text_format='star', loc='inside', verbose=1)
            annotator.set_pvalues_and_annotate(p_values_list)

    else:
        # Extract unique groups from the x-axis variable
        groups = df[xlab].unique()

        # Prepare data for normality test
        group_data = [df[df[xlab] == group][ylab] for group in groups]

        # Perform Shapiro-Wilk normality test on each group
        normal = all(stats.shapiro(data)[1] > 0.05 for data in group_data)

        # Choose the appropriate test based on normality
        if normal:
            if len(pairs) > 1:
                # Perform one-way ANOVA
                f_stat, p_value = stats.f_oneway(*group_data)
                print(title + " Anova p-value: ", p_value)
                test = 'ANOVA'
                if p_value < 0.05:
                    # Perform Tukey's HSD post hoc test
                    posthoc = sp.posthoc_tukey(df, val_col=ylab, group_col=xlab)
            elif len(pairs) == 1:
                ttest_res = stats.ttest_ind(*group_data)
                p_value = ttest_res.pvalue
                test = 't-test'

        else:
            if len(pairs) > 1:
                # Perform Kruskal-Wallis test
                h_stat, p_value = stats.kruskal(*group_data)
                test = 'Kruskal-Wallis'
                print(title + " Kruskal-Wallis p-value: ", p_value)
                if p_value < 0.05:
                    # Perform Dunn's post hoc test with Bonferroni correction
                    posthoc = sp.posthoc_dunn(df, val_col=ylab, group_col=xlab, p_adjust='bonferroni')
                    print(posthoc)
            elif len(pairs) == 1:
                mw_res = stats.mannwhitneyu(*group_data)
                p_value = mw_res.pvalue
                test = 'Mann-Whitney U'

        if ((p_value < 0.05) & (len(pairs) > 1)):
            # Create a dictionary of p-values for the specified pairs
            p_values = {}
            pairs_new = []
            for pair in pairs:
                group1, group2 = pair
                if posthoc.loc[group1, group2] < 0.05:
                    p_values[pair] = posthoc.loc[group1, group2]
                    pairs_new.append(pair)
             # Map the p-values to each pair
            p_values_list = [p_values[pair] for pair in pairs_new]
            # Annotate the plot with statistical significance
            if pairs_new:
                annotator = Annotator(ax, pairs_new, data=df, x=xlab, y=ylab)
                # Configure and apply the annotations
                annotator.configure(test=None, text_format='star', loc='inside', verbose=1)
                annotator.set_pvalues_and_annotate(p_values_list)
        elif ((p_value < 0.05) & (len(pairs) == 1)):
            annotator = Annotator(ax, pairs, data=df, x=xlab, y=ylab)
            # Configure and apply the annotations
            annotator.configure(test=None, text_format='star', loc='inside', verbose=1)
            annotator.set_pvalues_and_annotate([p_value])  # Wrap p_value in a list here
        else:
            p_values_list = np.ones(len(pairs))
            print(f"No significant differences found with {test} (p = {p_value:.3f})")

    print("\n")
    
def makeViolinPlot(df, xvalues, yvalues, xlabelv, ylabelv, title,ylim):
    plt.figure()
    
    params = {
    'axes.labelsize': 12,
    'axes.titlesize':12,
    'xtick.labelsize':12,
    'ytick.labelsize':12,
    'axes.titlepad': 1,
    'axes.labelpad': 1,
    'font.size': 12
    }

    plt.rcParams.update(params)
    
    ax = sns.violinplot(data = df, x = xvalues, y = yvalues)
    sns.stripplot(x = xvalues, y = yvalues, data = df, color = "black")
    plt.xlabel(xlabelv)
    plt.ylabel(ylabelv)
    plt.title(title)
    if ylim[0] - ylim[1] != 0:
        plt.ylim(ylim[0], ylim[1])
    return ax
    
    
def savePlot(path, title, UvG):
    plt.savefig(path + title + UvG + ".pdf", dpi=300)
    
def alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, title, pairs, path, UvG, ylim):
    
    ax = makeViolinPlot(df, xvalues, yvalues, xlabelv, ylabelv, title, ylim)
    addStatAnnot_Tamaras(xlab, ylab, title, pairs, ax, df, 0)
    savePlot(path, title,UvG)
    
    
    
#%% Setup Path and shared variables

#where to save the figure pictures
savePath = 'C:/Users/laSch/MIT Dropbox/Raman Lab/Laura Schwendeman/2_13_24 Fliped 40x Muscle only experiment confocal/FusionIndexPlots/'

#different plot pairings
allLabels = ["RGECO_R3", "WT_R4", "WT_R4NDM"]
pairAll = list(itertools.combinations(allLabels, 2))

pairUvG = [("ungrooved", "grooved")]

pairGrooved = [("RGECO_R3", "WT_R4"), ("RGECO_R3", "WT_R4NDM"), ("WT_R4", "WT_R4NDM")]

pairUngrooved = [("flat", "unstamped")]

#for plot aesthetics
print(plt.style.available)

plt.style.use('seaborn-v0_8-white')




#%%C2C12 Fiber Analysis Plots 
fileName = "C:/Users/laSch/MIT Dropbox/Raman Lab/Laura Schwendeman/2_13_24 Fliped 40x Muscle only experiment confocal/FusionIndexData.xlsx"
cellType = "NMJMuscleOnlyExperiment"
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

#alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, savePath, UvG, ylim)

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

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, savePath, UvG, ylim)

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

#alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, savePath, UvG, ylim)

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

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, savePath, UvG, ylim)



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

#alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, savePath, UvG, ylim)

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

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, savePath, UvG, ylim)

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

#alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, savePath, UvG, ylim)

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

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, savePath, UvG, ylim)

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

#alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, savePath, UvG, ylim)

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

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, savePath, UvG, ylim)

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

#alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, savePath, UvG, ylim)

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

alignmentPlot(df, xvalues, yvalues,xlabelv, ylabelv, xlab, ylab, titleName, pairs, savePath, UvG, ylim)

