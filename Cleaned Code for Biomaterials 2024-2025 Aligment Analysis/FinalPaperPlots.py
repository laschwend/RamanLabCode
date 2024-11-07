# -*- coding: utf-8 -*-
"""
Created on Thu Jun  6 11:05:00 2024

@author: laSch

Purpose: Make final Figures and Plots for Biomaterials 2024 Paper
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

# Set the matplotlib parameters for the text to be editable in illustrator.
plt.rcParams['ps.fonttype'] = 42
plt.rcParams['pdf.fonttype'] = 42





#make plot for c2c12 alignment data
pathName = "C:/Users/laSch/Desktop/Raman Lab/RamanlabCode/AlignmentCode2024/Directionality Tables C2C12_2/"
saveName = "Summary_Tables.csv"
titleName = "C2C12 Fitted Mean Alignment Direction"

fileName = pathName+saveName

df = pd.read_csv(fileName)

#to remove all 62.5 samples
df = df[df['Stamp_Parameters'] != "62.5"]


pal = sns.color_palette("husl", 8)


####look at percent between 70 and 90 deg
    
#boxplot option - grooved vs ungrooved
plt.figure()
ax = sns.violinplot(data = df, x = df.Category, y = df.percent_near90)
sns.stripplot(x=df.Category, y=df.percent_near90, data = df, color = "black")
plt.xlabel("Stamp Size (um)")
plt.ylabel("percent +-20 around mean")
plt.title("C2C12 % Near Mean (\N{DEGREE SIGN})")
plt.ylim(-0.09, 1)

#add stat annotations
print("\n Percent Near C2C12 Mann-Whitney Results")
pairs = [("ungrooved", "grooved")]
annotator = Annotator(ax, pairs, data = df, x = "Category", y = "percent_near90")
annotator.configure(test = 'Mann-Whitney', text_format = 'star')
annotator.apply_and_annotate()

print(df.groupby('Category')['percent_near90'].mean())
print(df.groupby('Category')['percent_near90'].std())

plt.savefig(pathName + 'C2C1270110anglegvug.pdf', dpi=300)


    #stats - Mann Whitney
# group1 = df[df['Category'] == "grooved"]
# group2 = df[df['Category'] == "ungrooved"]
# stat,p_value = mannwhitneyu(group1.percent_near90, group2.percent_near90)


# print(f'Statistic: {stat}')
# print(f'P-value: {p_value}')

#also looking at all stamp conditions
plt.figure()
ax = sns.violinplot(data = df, x = df.Stamp_Parameters, y = df.percent_near90)
sns.stripplot(x=df.Stamp_Parameters, y=df.percent_near90, data = df, color = "black")
plt.xlabel("Stamp Size (um)")
plt.ylabel("percent +-20 around mean")
plt.title("C2C12 % Near Mean All (\N{DEGREE SIGN})")
plt.ylim(-0.09, 1)

plt.savefig(pathName + 'C2C1270110angleAll.pdf', dpi=300)

    #stats - Mann Whitney
print('C2C12 Alignment Angle mean stats \n')
model = ols('percent_near90 ~ C(Stamp_Parameters)', data=df).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)

if anova_table['PR(>F)'][0] < 0.05:
    tukey = pairwise_tukeyhsd(endog=df['percent_near90'], groups=df['Stamp_Parameters'], alpha=0.05)
    print(tukey)    

print(df.groupby('Stamp_Parameters')['percent_near90'].mean())
print(df.groupby('Stamp_Parameters')['percent_near90'].mean())


#look at just the stamped conditions
conditionVals = ["12.5", "25", "125"]
stampeddf = df[df["Stamp_Parameters"].isin(conditionVals)]
conditionVals = ["flat", "unstamped"]
ungrooveddf = df[df["Stamp_Parameters"].isin(conditionVals)]

df = stampeddf

plt.figure()
ax = sns.violinplot(data = df, x = df.Stamp_Parameters, y = df.percent_near90)
sns.stripplot(x=df.Stamp_Parameters, y=df.percent_near90, data = df, color = "black")
plt.xlabel("Stamp Size (um)")
plt.ylabel("percent +-20 \N{DEGREE SIGN} around mean")
plt.title("C2C12 % Near Mean Grooved (\N{DEGREE SIGN})")
plt.ylim(-0.09, 1)
print("\n Percent Near C2C12 Mann-Whitney Results grooved")
pairs = [("12.5", "25"), ("12.5", "125"), ("25", "125")]
annotator = Annotator(ax, pairs, data = df, x = "Stamp_Parameters", y = "percent_near90")
annotator.configure(test = 'Mann-Whitney', text_format = 'star')
annotator.apply_and_annotate()

plt.savefig(pathName + 'C2C1270110angleGrooved.pdf', dpi=300)

    #stats - Anova
print('C2C12 Alignment Angle mean stats Grooved \n')
model = ols('percent_near90 ~ C(Stamp_Parameters)', data=df).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)

if anova_table['PR(>F)'][0] < 0.05:
    tukey = pairwise_tukeyhsd(endog=df['percent_near90'], groups=df['Stamp_Parameters'], alpha=0.05)
    print(tukey)   
    
    #stats - kruskal wallis
#add statistics - kruskal
kruskal_result = kruskal(*[group["percent_near90"].values for name, group in df.groupby('Stamp_Parameters')])
print(f'Kruskal-Wallis H-statistic: {kruskal_result.statistic}, p-value: {kruskal_result.pvalue}')

print(df.groupby('Stamp_Parameters')['percent_near90'].mean())


print('/n /n /n /n')
#look at just the unstamped conditions
df = ungrooveddf

plt.figure()
ax = sns.violinplot(data = df, x = df.Stamp_Parameters, y = df.percent_near90)
sns.stripplot(x=df.Stamp_Parameters, y=df.percent_near90, data = df, color = "black")
plt.xlabel("stamp size (um)")
plt.ylabel("percent +-20 \N{DEGREE SIGN} around mean")
plt.title("C2C12 % Near Mean Ungrooved (\N{DEGREE SIGN})")
plt.ylim(-0.09, 1)
print("\n Percent Near C2C12 Mann-Whitney Results unGrooved")
pairs = [("flat", "unstamped")]
annotator = Annotator(ax, pairs, data = df, x = "Stamp_Parameters", y = "percent_near90")
annotator.configure(test = 'Mann-Whitney', text_format = 'star')
annotator.apply_and_annotate()
kruskal_result = kruskal(*[group["percent_near90"].values for name, group in df.groupby('Stamp_Parameters')])
print(f'Kruskal-Wallis H-statistic: {kruskal_result.statistic}, p-value: {kruskal_result.pvalue}')
manresult = mannwhitneyu(df[df['Stamp_Parameters'].isin(['flat'])].percent_near90, df[df['Stamp_Parameters'].isin(['unstamped'])].percent_near90)
print(f'ManResult: {manresult.pvalue}')
print('\n\n\n\n')
plt.savefig(pathName + 'C2C1270110angleUngrooved.pdf', dpi=300)

    #stats - Anova
print('C2C12 Alignment Angle mean stats Grooved \n')
model = ols('percent_near90 ~ C(Stamp_Parameters)', data=df).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)

if anova_table['PR(>F)'][0] < 0.05:
    tukey = pairwise_tukeyhsd(endog=df['percent_near90'], groups=df['Stamp_Parameters'], alpha=0.05)
    print(tukey)    

print(df.groupby('Stamp_Parameters')['percent_near90'].mean())

#superviolin plot



##########make plot for C2C12 Fusion Index
fileName = "C:/Users/laSch\Desktop/Raman Lab/RamanlabCode/AlignmentCode2024/FiberAnalysis/C2C12FiberData40x.xlsx"
df = pd.read_excel(fileName, sheet_name = "Sheet1")
df = df[df['StampCondition'] != "62.5"]

#make plot for c2c12 fusion index based off groove groups
plt.figure()
ax = sns.violinplot(data = df, x = df.Category, y = df.FusionIndex)
sns.stripplot(x = df.Category, y = df.FusionIndex, data = df, color = "black")
plt.xlabel("Condition")
plt.ylabel("Fusion Index")
plt.title("C2C12 Fusion Index")

    #add stat annotations
print("\n C2C12 Fusion Index")
pairs = [("ungrooved", "grooved")]
annotator = Annotator(ax, pairs, data = df, x = "Category", y = "FusionIndex")
annotator.configure(test = 'Mann-Whitney', text_format = 'star')
annotator.apply_and_annotate()

plt.savefig(pathName + 'C2C12fusionindexgvug.pdf', dpi=300)
print(df.groupby('Category')['FusionIndex'].mean())

#stats - Mann Whitney

# group1 = df[df['Category'] == "grooved"]
# group2 = df[df['Category'] == "ungrooved"]
# stat,p_value = mannwhitneyu(group1.FusionIndex, group2.FusionIndex)


# print(f'Statistic: {stat}')
# print(f'P-value: {p_value}')


#make violin plots for c2c12 nuclei fiber count
df = pd.read_excel(fileName, sheet_name = "Sheet2")
df = df[df['StampCondition'] != "62.5"]
plt.figure(figsize=(4, 6))
ax = sns.violinplot(data = df, x = "NumberOfNuclei", y = "Category")
#sns.stripplot(x = df.NumberOfNuclei, y = df.Category, data = df, color = "black")
plt.xlabel("Number of Nuclei per Fiber")
plt.ylabel("Stamp Size (um)")
plt.title("C2C12 Nuclei per Fiber")

#add stat annotations
print("\n C2C12 Fiber Nuclei Count")
pairs = [("ungrooved", "grooved")]
annotator = Annotator(ax, pairs, data = df, x = "NumberOfNuclei", y = "Category", orient = 'h')
annotator.configure(test = 'Mann-Whitney', text_format = 'star', loc = 'outside')
annotator.apply_and_annotate()

print(df.groupby('Category')['NumberOfNuclei'].mean())

plt.savefig(pathName + 'C2C12FiberCountgvug.pdf', dpi=300)

    #print the stats

model = ols('NumberOfNuclei ~ C(Category)', data=df).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)




#make barplot for the averages of nuclei counts for each replicate
df = pd.read_excel(fileName, sheet_name = "Sheet5")
df = df[df['StampCondition'] != "62.5"]
plt.figure()
ax = sns.violinplot(data = df, x = df.Category, y = df.AverageCount)
sns.stripplot(x = df.Category, y = df.AverageCount, data = df, color = "black")
plt.xlabel("Condition")
plt.ylabel("Average Nuclei per Fiber per Replicate")
plt.title("C2C12 Average Nuclei")

    #add stat annotations
print("\n C2C12 Average Nuclei Per Fiber")
pairs = [("ungrooved", "grooved")]
annotator = Annotator(ax, pairs, data = df, x = "Category", y = "AverageCount")
annotator.configure(test = 'Mann-Whitney', text_format = 'star')
annotator.apply_and_annotate()

print(df.groupby('Category')['AverageCount'].mean())

plt.savefig(pathName + 'C2C12AverageCountgvug.pdf', dpi=300)

#stats - Mann Whitney

group1 = df[df['Category'] == "grooved"]
group2 = df[df['Category'] == "ungrooved"]
stat,p_value = mannwhitneyu(group1.AverageCount, group2.AverageCount)


print(f'Statistic: {stat}')
print(f'P-value: {p_value}')


    
#make plot for c2c12 fiber widths
df = pd.read_excel(fileName, sheet_name = "Sheet3")
df = df[df['StampCondition'] != "62.5"]
df.AverageWidthperFiber = df.AverageWidthperFiber*0.2157919
plt.figure(figsize=(4, 6))
ax = sns.violinplot(data = df, x = "AverageWidthperFiber", y = "Category")
plt.xlabel("Fiber Width (um)")
plt.ylabel("Stamp Size (um)")
plt.title("C2C12 Width per Fiber")

print("\n C2C12 Fiber Widths")
pairs = [("ungrooved", "grooved")]
annotator = Annotator(ax, pairs, data = df, x = "AverageWidthperFiber", y = "Category", orient = "h")
annotator.configure(test = 'Mann-Whitney', text_format = 'star', loc = 'outside')
annotator.apply_and_annotate()



plt.savefig(pathName + 'C2C12FiberWidthgvug.pdf', dpi=300)

    #print the stats

model = ols('AverageWidthperFiber ~ C(Category)', data=df).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)
print("\n")



#make plot for c2c12 average fiber widths
df = pd.read_excel(fileName, sheet_name = "Sheet4")
df = df[df['StampCondition'] != "62.5"]

plt.figure()
df.AverageWidth = df.AverageWidth*0.257919
ax = sns.violinplot(data = df, x = df.Category, y = df.AverageWidth)
sns.stripplot(x = df.Category, y = df.AverageWidth, data = df, color = "black")
plt.xlabel("Stamp Size (um)")
plt.ylabel("Average Fiber Width (um)")
plt.title("C2C12 Fiber Width")

#add stat annotations
print("\n average fiber width")
pairs = [("ungrooved", "grooved")]
annotator = Annotator(ax, pairs, data = df, x = "Category", y = "AverageWidth")
annotator.configure(test = 'Mann-Whitney', text_format = 'star')
annotator.apply_and_annotate()

print(df.groupby('Category')['AverageWidth'].mean())
plt.savefig(pathName + 'C2C12averageFiberWidth.pdf', dpi=300)


group1 = df[df['Category'] == "grooved"]
group2 = df[df['Category'] == "ungrooved"]
stat,p_value = mannwhitneyu(group1.AverageWidth, group2.AverageWidth)


print(f'Statistic: {stat}')
print(f'P-value: {p_value} ')
  

#add nuclei circularity plot
df = pd.read_excel(fileName, sheet_name = "Sheet8")
df = df[df['StampCondition'] != "62.5"]

plt.figure()
ax = sns.violinplot(data = df, x = df.Category, y = df.AverageCircularity)
sns.stripplot(x = df.Category, y = df.AverageCircularity, data = df, color = "black")
plt.xlabel("Stamp Size (um)")
plt.ylabel("Circulairty")
plt.title("C2C12 Nuclei Average Circularity")
plt.ylim(0, 1)

#add stat annotations
print("\n average Circularity")
pairs = [("ungrooved", "grooved")]
annotator = Annotator(ax, pairs, data = df, x = "Category", y = "AverageCircularity")
annotator.configure(test = 'Mann-Whitney', text_format = 'star')
annotator.apply_and_annotate()

print(df.groupby('Category')['AverageCircularity'].mean())
plt.savefig(pathName + 'C2C12averageCircularity.pdf', dpi=300)



#make plot for Human alignment data####################################

pathName = "C:/Users/laSch/Desktop/Raman Lab/RamanlabCode/AlignmentCode2024/Directionality Tables Human_2/"
saveName = "Summary_Tables.csv"
titleName = "Human Fitted Mean Alignment Direction"

fileName = pathName+saveName

df = pd.read_csv(fileName)
#to remove all 62.5 samples
df = df[df['Stamp_Parameters'] != "62.5"]

pal = sns.color_palette("husl", 8)

#boxplot - just the grooved vs ungrooved
plt.figure()
ax = sns.violinplot(data = df, x = df.Category, y = df.percent_near90)
sns.stripplot(x=df.Category, y=df.percent_near90, data = df, color = "black")
plt.xlabel("Condition")
plt.ylabel("percent +-20(\N{DEGREE SIGN}) around 90(\N{DEGREE SIGN})")
plt.title("Human % within [70,110](\N{DEGREE SIGN})")
plt.ylim(0, 1)

#add stat annotations
print('Human Data - Mann Whitney')
pairs = [("ungrooved", "grooved")]
annotator = Annotator(ax, pairs, data = df, x = "Category", y = "percent_near90")
annotator.configure(test = 'Mann-Whitney', text_format = 'star')
annotator.apply_and_annotate()
print(df.groupby('Category')['percent_near90'].mean())
print(df.groupby('Category')['percent_near90'].std())
#     #stats - Mann Whitney
# group1 = df[df['Category'] == "grooved"]
# group2 = df[df['Category'] == "ungrooved"]
# stat,p_value = mannwhitneyu(group1.percent_near90, group2.percent_near90)



plt.savefig(pathName + 'human70110anglegvug.pdf', dpi=300)


#also plot the different stamp conditions
plt.figure()
ax = sns.violinplot(data = df, x = df.Stamp_Parameters, y = df.percent_near90)
sns.stripplot(x=df.Stamp_Parameters, y=df.percent_near90, data = df, color = "black")
plt.xlabel("Condition")
plt.ylabel("percent +-20(\N{DEGREE SIGN}) around 90(\N{DEGREE SIGN})")
plt.title("Human % bounding mean (\N{DEGREE SIGN})")
plt.ylim(0, 1)

print('Human Alignment Angle mean stats \n')
model = ols('percent_near90 ~ C(Stamp_Parameters)', data=df).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)

if anova_table['PR(>F)'][0] < 0.05:
    tukey = pairwise_tukeyhsd(endog=df['mean_angle'], groups=df['Stamp_Parameters'], alpha=0.05)
    print(tukey)    
plt.savefig(pathName + 'human70110angleAll.pdf', dpi=300)
print(df.groupby('Stamp_Parameters')['percent_near90'].mean())


#look at just the stamped conditions#####3
conditionVals = ["12.5", "25", "125"]
stampeddf = df[df["Stamp_Parameters"].isin(conditionVals)]
conditionVals = ["flat", "unstamped"]
ungrooveddf = df[df["Stamp_Parameters"].isin(conditionVals)]

df = stampeddf

plt.figure()
ax = sns.violinplot(data = df, x = df.Stamp_Parameters, y = df.percent_near90)
sns.stripplot(x=df.Stamp_Parameters, y=df.percent_near90, data = df, color = "black")
plt.xlabel("Stamp Size (um)")
plt.ylabel("percent +-20 \N{DEGREE SIGN} around mean")
plt.title("Human % Near Mean Grooved (\N{DEGREE SIGN})")
plt.ylim(-0.09, 1)
print("\n Percent Near human Mann-Whitney Results grooved")
pairs = [("12.5", "25"), ("12.5", "125"), ("25", "125")]
annotator = Annotator(ax, pairs, data = df, x = "Stamp_Parameters", y = "percent_near90")
annotator.configure(test = 'Mann-Whitney', text_format = 'star')
annotator.apply_and_annotate()

kruskal_result = kruskal(*[group["percent_near90"].values for name, group in df.groupby('Stamp_Parameters')])
print(f'Kruskal-Wallis H-statistic: {kruskal_result.statistic}, p-value: {kruskal_result.pvalue}')

print(df.groupby('Stamp_Parameters')['percent_near90'].mean())

plt.savefig(pathName + 'Human70110angleGrooved.pdf', dpi=300)

    #stats - Anova
print('Human Alignment Angle mean stats Grooved \n')
model = ols('percent_near90 ~ C(Stamp_Parameters)', data=df).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)

if anova_table['PR(>F)'][0] < 0.05:
    tukey = pairwise_tukeyhsd(endog=df['percent_near90'], groups=df['Stamp_Parameters'], alpha=0.05)
    print(tukey)    

print(df.groupby('Stamp_Parameters')['percent_near90'].mean())

#look at just the unstamped conditions
df = ungrooveddf

plt.figure()
ax = sns.violinplot(data = df, x = df.Stamp_Parameters, y = df.percent_near90)
sns.stripplot(x=df.Stamp_Parameters, y=df.percent_near90, data = df, color = "black")
plt.xlabel("stamp size (um)")
plt.ylabel("percent +-20 \N{DEGREE SIGN} around mean")
plt.title("C2C12 % Near Mean Ungrooved (\N{DEGREE SIGN})")
plt.ylim(-0.09, 1)
print("\n Percent Near C2C12 Mann-Whitney Results unGrooved")
pairs = [("flat", "unstamped")]
annotator = Annotator(ax, pairs, data = df, x = "Stamp_Parameters", y = "percent_near90")
annotator.configure(test = 'Mann-Whitney', text_format = 'star')
annotator.apply_and_annotate()
print("\n\n\n ##############")
kruskal_result = kruskal(*[group["percent_near90"].values for name, group in df.groupby('Stamp_Parameters')])
print(f'Kruskal-Wallis H-statistic: {kruskal_result.statistic}, p-value: {kruskal_result.pvalue}')
plt.savefig(pathName + 'Human70110angleUngrooved.pdf', dpi=300)

    #stats - Anova
print('Human Alignment Angle mean stats Grooved \n')
model = ols('percent_near90 ~ C(Stamp_Parameters)', data=df).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)

if anova_table['PR(>F)'][0] < 0.05:
    tukey = pairwise_tukeyhsd(endog=df['percent_near90'], groups=df['Stamp_Parameters'], alpha=0.05)
    print(tukey)    

print(df.groupby('Stamp_Parameters')['percent_near90'].mean())



###plots for Human Fusion index and fiber analysis
fileName = "C:/Users/laSch\Desktop/Raman Lab/RamanlabCode/AlignmentCode2024/FiberAnalysis/HumanFiberData40x.xlsx"

#make plot for Human  widths
df = pd.read_excel(fileName, sheet_name = "Sheet3")
df = df[df['StampCondition'] != "62.5"]
df.AverageWidthperFiber = df.AverageWidthperFiber*0.2157919
plt.figure(figsize=(4, 6))
ax = sns.violinplot(data = df, x = "AverageWidthperFiber", y = "Category")
plt.xlabel("Fiber Width (um)")
plt.ylabel("Stamp Size (um)")
plt.title("Human Width per Fiber")

print("\n C2C12 Fiber Widths")
pairs = [("ungrooved", "grooved")]
annotator = Annotator(ax, pairs, data = df, x = "AverageWidthperFiber", y = "Category", orient = "h")
annotator.configure(test = 'Mann-Whitney', text_format = 'star', loc = 'outside')
annotator.apply_and_annotate()

print(df.groupby('Category')['AverageWidthperFiber'].mean())

plt.savefig(pathName + 'HumanWidthgvug.pdf', dpi=300)

    #print the stats

model = ols('AverageWidthperFiber ~ C(Category)', data=df).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)
print("\n")



#make plot for humanverage fiber widths
df = pd.read_excel(fileName, sheet_name = "Sheet4")
df = df[df['StampCondition'] != "62.5"]

plt.figure()
df.AverageWidth = df.AverageWidth*0.257919
ax = sns.violinplot(data = df, x = df.Category, y = df.AverageWidth)
sns.stripplot(x = df.Category, y = df.AverageWidth, data = df, color = "black")
plt.xlabel("Stamp Size (um)")
plt.ylabel("Average Fiber Width (um)")
plt.title("Human Fiber Width")

#add stat annotations
print("\n average fiber width")
pairs = [("ungrooved", "grooved")]
annotator = Annotator(ax, pairs, data = df, x = "Category", y = "AverageWidth")
annotator.configure(test = 'Mann-Whitney', text_format = 'star')
annotator.apply_and_annotate()

print(df.groupby('Category')['AverageWidth'].mean())

plt.savefig(pathName + 'HumanaverageFiberWidth.pdf', dpi=300)

#add nuclei circularity plot
df = pd.read_excel(fileName, sheet_name = "Sheet8")
df = df[df['StampCondition'] != "62.5"]

plt.figure()
ax = sns.violinplot(data = df, x = df.Category, y = df.AverageCircularity)
sns.stripplot(x = df.Category, y = df.AverageCircularity, data = df, color = "black")
plt.xlabel("Stamp Size (um)")
plt.ylabel("Circulairty")
plt.title("Human Nuclei Average Circularity")
plt.ylim(0, 1)

#add stat annotations
print("\n average Circularity")
pairs = [("ungrooved", "grooved")]
annotator = Annotator(ax, pairs, data = df, x = "Category", y = "AverageCircularity")
annotator.configure(test = 'Mann-Whitney', text_format = 'star')
annotator.apply_and_annotate()

print(df.groupby('Category')['AverageCircularity'].mean())


plt.savefig(pathName + 'HumanaverageCircularity.pdf', dpi=300)


#nuclei per fiber
df = pd.read_excel(fileName, sheet_name = "Sheet5")
df = df[df['StampCondition'] != "62.5"]
plt.figure()
ax = sns.violinplot(data = df, x = df.Category, y = df.AverageCount)
sns.stripplot(x = df.Category, y = df.AverageCount, data = df, color = "black")
plt.xlabel("Condition")
plt.ylabel("Average Nuclei per Fiber per Replicate")
plt.title("Human Average Nuclei")

    #add stat annotations
print("\n Human Average Nuclei Per Fiber")
pairs = [("ungrooved", "grooved")]
annotator = Annotator(ax, pairs, data = df, x = "Category", y = "AverageCount")
annotator.configure(test = 'Mann-Whitney', text_format = 'star')
annotator.apply_and_annotate()

print(df.groupby('Category')['AverageCount'].mean())

plt.savefig(pathName + 'HumanAverageCountgvug.pdf', dpi=300)



#
###Cell Size Plots #################
#

pathName = "C:/Users/laSch/Desktop/Raman Lab/RamanlabCode/AlignmentCode2024/"
MouseName = "c2c12_10x_25_cellSizeResultsHand.csv"
HumanName = "human_10x_25_cellSizeResultsHand.csv"

c2c12df = pd.read_csv(pathName + MouseName)
humandf = pd.read_csv(pathName + HumanName)

ConversionFactor = 1000
#get approximate Diameters
c2c12DiaVec = c2c12df.Length*ConversionFactor #np.sqrt(c2c12df.Area/np.pi)*ConversionFactor
humanDiaVec = humandf.Length*ConversionFactor#np.sqrt(humandf.Area/np.pi)*ConversionFactor

#combine into one df for plotting
df1 = pd.DataFrame(c2c12DiaVec)
df2 = pd.DataFrame(humanDiaVec)

df1['source'] = 'Mouse'
df2['source'] = 'Human'

combined_df = pd.concat([df1, df2])

df = combined_df

#now make the violin plot and run statistics
plt.figure()
ax = sns.violinplot(data = df, x = df.source, y = df.Length)
#sns.stripplot(x = df.source, y = df.Length, data = df, color = "black")
plt.xlabel("Cell Type")
plt.ylabel("Cell Measured Diameter (um)")
plt.ylim(0, 50)

    #add stat annotations
print("cell diameters")
pairs = [("Mouse", "Human")]
annotator = Annotator(ax, pairs, data = df, x = "source", y = "Length")
annotator.configure(test = 'Mann-Whitney', text_format = 'star')
annotator.apply_and_annotate()

print(df.groupby('source')['Length'].mean())

plt.savefig(pathName + 'CellSizes.pdf', dpi=300)








