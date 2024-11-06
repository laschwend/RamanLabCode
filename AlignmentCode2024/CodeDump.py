# -*- coding: utf-8 -*-
"""
Created on Tue Jul  9 03:21:19 2024

@author: laSch

Purpose: store extra code from final paper plots
"""

# plt.figure()
# sns.lineplot(x="Stamp_Parameters", y="mean_angle", data=df, color = "black")
# sns.stripplot(x=df.Stamp_Parameters, y=df.mean_angle, data = df, palette = pal)
# plt.title(titleName)
# plt.xlabel("Stamp Size (um)")
# plt.ylabel("Angle (\N{DEGREE SIGN})")
# plt.ylim(0, 180)


# #bar plot option
# plt.figure()
# sns.barplot(data = df, x = df.Stamp_Parameters, y = df.mean_angle, palette = pal)
# sns.stripplot(x=df.Stamp_Parameters, y=df.mean_angle, data = df, color = "black")
# plt.xlabel("Stamp Size (um)")
# plt.ylabel("Angle (\N{DEGREE SIGN})")
# plt.ylim(0, 180)

#boxplot option
# plt.figure()
# sns.boxplot(data = df, x = df.Stamp_Parameters, y = df.mean_angle, palette = pal)
# sns.stripplot(x=df.Stamp_Parameters, y=df.mean_angle, data = df, color = "black")
# plt.xlabel("Stamp Size (um)")
# plt.ylabel("Angle (\N{DEGREE SIGN})")
# plt.ylim(0, 180)


# print('C2C12 Alignment Angle mean stats \n')
# model = ols('mean_angle ~ C(Stamp_Parameters)', data=df).fit()
# anova_table = sm.stats.anova_lm(model, typ=2)
# print(anova_table)

# if anova_table['PR(>F)'][0] < 0.05:
#     tukey = pairwise_tukeyhsd(endog=df['mean_angle'], groups=df['Stamp_Parameters'], alpha=0.05)
#     print(tukey)    

#  #add statistics  - 2 way anova
# #model = ols('mean_angle ~ C(Stamp_Parameters)+C(rep)+C(Stamp_Parameters):C(rep)', data=df).fit()
# #anova_table = sm.stats.anova_lm(model, typ=2)
# #print(anova_table)

#     #add statistics - kruskal
# kruskal_result = kruskal(*[group["mean_angle"].values for name, group in df.groupby('Stamp_Parameters')])
# print(f'Kruskal-Wallis H-statistic: {kruskal_result.statistic}, p-value: {kruskal_result.pvalue}')

# plt.figure()
# sns.boxplot(data = df, x = df.Stamp_Parameters, y = df.stdd, palette = pal)
# sns.stripplot(x=df.Stamp_Parameters, y=df.stdd, data = df, color = "black")
# plt.xlabel("Stamp Size (um)")
# plt.ylabel("Standard Deviation (\N{DEGREE SIGN})")
# #plt.ylim(0, 180)

#     #add statistics  - 1 way anova
# print('C2C12 Alignment Angle std stats \n')
# model = ols('stdd ~ C(Stamp_Parameters)', data=df).fit()
# anova_table = sm.stats.anova_lm(model, typ=2)
# print(anova_table)

# if anova_table['PR(>F)'][0] < 0.05:
#     tukey = pairwise_tukeyhsd(endog=df['mean_angle'], groups=df['Stamp_Parameters'], alpha=0.05)
#     print(tukey)    


#     #add statistics - kruskal
# kruskal_result = kruskal(*[group["stdd"].values for name, group in df.groupby('Stamp_Parameters')])
# print(f'Kruskal-Wallis H-statistic: {kruskal_result.statistic}, p-value: {kruskal_result.pvalue}')

plt.figure()
sns.boxplot(data = df, x = df.Stamp_Parameters, y = df.percent_near90, palette = pal)
sns.stripplot(x=df.Stamp_Parameters, y=df.percent_near90, data = df, color = "black")
plt.xlabel("Stamp Size (um)")
plt.ylabel("percent +-20 around 90")
plt.title("C2C12 % within [70,110](\N{DEGREE SIGN})")
plt.ylim(0, 1)
plt.savefig(pathName + 'C2C1270110angle.pdf', dpi=300)

    #stats
print('C2C12 Alignment Angle %near90 stats \n')
model = ols('percent_near90 ~ C(Stamp_Parameters)', data=df).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)

if anova_table['PR(>F)'][0] < 0.1:
    tukey = pairwise_tukeyhsd(endog=df['percent_near90'], groups=df['Stamp_Parameters'], alpha=0.05)
    print(tukey)    


    #add statistics - kruskal
kruskal_result = kruskal(*[group["percent_near90"].values for name, group in df.groupby('Stamp_Parameters')])
print(f'Kruskal-Wallis H-statistic: {kruskal_result.statistic}, p-value: {kruskal_result.pvalue}')

#boxplot option - grooved vs ungrooved
plt.figure()
sns.boxplot(data = df, x = df.Category, y = df.percent_near90, palette = pal)
sns.stripplot(x=df.Category, y=df.percent_near90, data = df, color = "black")
plt.xlabel("Stamp Size (um)")
plt.ylabel("percent +-20 around 90")
plt.title("C2C12 % within [70,110](\N{DEGREE SIGN})")
plt.ylim(0, 1)
plt.savefig(pathName + 'C2C1270110anglegvug.pdf', dpi=300)

    #stats
print('C2C12 Alignment Angle %near90 stats \n')
model = ols('percent_near90 ~ C(Category)', data=df).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)

if anova_table['PR(>F)'][0] < 0.1:
    tukey = pairwise_tukeyhsd(endog=df['percent_near90'], groups=df['Category'], alpha=0.05)
    print(tukey)    


    #add statistics - kruskal
kruskal_result = kruskal(*[group["percent_near90"].values for name, group in df.groupby('Category')])
print(f'Kruskal-Wallis H-statistic: {kruskal_result.statistic}, p-value: {kruskal_result.pvalue}')


# plt.figure()
# sns.boxplot(data = df, x = df.StampCondition, y = df.FusionIndex)
# sns.stripplot(x = df.StampCondition, y = df.FusionIndex, data = df, color = "black")
# plt.xlabel("Stamp Size (um)")
# plt.ylabel("Fusion Index")
# plt.title("C2C12 Fusion Index")
# plt.savefig(pathName + 'C2C12fusionindex.pdf', dpi=300)


    #run statistics 
model = ols('NumberOfNuclei ~ C(StampCondition)', data=df).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)

model = ols('NumberOfNuclei ~ C(StampCondition)+C(Replicate)+C(StampCondition):C(Replicate)', data=df).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)

if anova_table['PR(>F)'][0] < 0.05:
    tukey_cond = pairwise_tukeyhsd(endog=df['NumberOfNuclei'], groups=df['StampCondition'], alpha=0.05)
    print(tukey_cond)

if anova_table['PR(>F)'][1] < 0.05:
    tukey_time = pairwise_tukeyhsd(endog=df['NumberOfNuclei'], groups=df['Replicate'], alpha=0.05)
    print(tukey_time)
    
    
    
    #human pltos
    # plt.figure()
    # sns.lineplot(x="Stamp_Parameters", y="mean_angle", data=df, color = "black")
    # sns.stripplot(x=df.Stamp_Parameters, y=df.mean_angle, data = df, palette = pal)
    # plt.title(titleName)
    # plt.xlabel("Stamp Size (um)")
    # plt.ylabel("Angle (\N{DEGREE SIGN})")
    # plt.ylim(0, 180)


    # #bar plot option
    # plt.figure()
    # sns.barplot(data = df, x = df.Stamp_Parameters, y = df.mean_angle, palette = pal)
    # sns.stripplot(x=df.Stamp_Parameters, y=df.mean_angle, data = df, color = "black")
    # plt.xlabel("Stamp Size (um)")
    # plt.ylabel("Angle (\N{DEGREE SIGN})")
    # plt.ylim(0, 180)
    
#boxplot option
plt.figure()
sns.boxplot(data = df, x = df.Stamp_Parameters, y = df.mean_angle, palette = pal)
sns.stripplot(x=df.Stamp_Parameters, y=df.mean_angle, data = df, color = "black")
plt.xlabel("Stamp Size (um)")
plt.ylabel("Angle (\N{DEGREE SIGN})")
plt.ylim(0, 180)

    #add statistics  - 1 way anova
print('Human Alignment mean angle Stats')
model = ols('mean_angle ~ C(Stamp_Parameters)', data=df).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)

if anova_table['PR(>F)'][0] < 0.05:
    tukey = pairwise_tukeyhsd(endog=df['mean_angle'], groups=df['Stamp_Parameters'], alpha=0.05)
    print(tukey)    

    #add statistics - kruskal
kruskal_result = kruskal(*[group["mean_angle"].values for name, group in df.groupby('Stamp_Parameters')])
print(f'Kruskal-Wallis H-statistic: {kruskal_result.statistic}, p-value: {kruskal_result.pvalue}')

#look at standard deviation
plt.figure()
sns.boxplot(data = df, x = df.Stamp_Parameters, y = df.stdd, palette = pal)
sns.stripplot(x=df.Stamp_Parameters, y=df.stdd, data = df, color = "black")
plt.xlabel("Stamp Size (um)")
plt.ylabel("Standard Deviation (\N{DEGREE SIGN})")

    #add statistics  - 1 way anova - on std
print('Human Alignment std Stats')
model = ols('stdd ~ C(Stamp_Parameters)', data=df).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)

if anova_table['PR(>F)'][0] < 0.05:
    tukey = pairwise_tukeyhsd(endog=df['stdd'], groups=df['Stamp_Parameters'], alpha=0.05)
    print(tukey)    

    #add statistics - kruskal
kruskal_result = kruskal(*[group["stdd"].values for name, group in df.groupby('Stamp_Parameters')])
print(f'Kruskal-Wallis H-statistic: {kruskal_result.statistic}, p-value: {kruskal_result.pvalue}')

#look at percent between 70 and 90 deg
#boxplot option
plt.figure()
sns.boxplot(data = df, x = df.Stamp_Parameters, y = df.percent_near90, palette = pal)
sns.stripplot(x=df.Stamp_Parameters, y=df.percent_near90, data = df, color = "black")
plt.xlabel("Stamp Size (um)")
plt.ylabel("percent +-20 around 90")
plt.ylim(0, 1)
plt.savefig(pathName + 'human70110angle.pdf', dpi=300)

print('human Alignment Angle %near90 stats \n')
model = ols('percent_near90 ~ C(Stamp_Parameters)', data=df).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)

if anova_table['PR(>F)'][0] < 0.05:
    tukey = pairwise_tukeyhsd(endog=df['percent_near90'], groups=df['Stamp_Parameters'], alpha=0.05)
    print(tukey)    

 #add statistics  - 2 way anova
#model = ols('mean_angle ~ C(Stamp_Parameters)+C(rep)+C(Stamp_Parameters):C(rep)', data=df).fit()
#anova_table = sm.stats.anova_lm(model, typ=2)
#print(anova_table)

    #add statistics - kruskal
kruskal_result = kruskal(*[group["percent_near90"].values for name, group in df.groupby('Stamp_Parameters')])
print(f'Kruskal-Wallis H-statistic: {kruskal_result.statistic}, p-value: {kruskal_result.pvalue}')

if anova_table['PR(>F)'][0] < 0.05:
    tukey = pairwise_tukeyhsd(endog=df['percent_near90'], groups=df['Category'], alpha=0.05)
    print(tukey)    

 #add statistics  - 2 way anova
#model = ols('mean_angle ~ C(Stamp_Parameters)+C(rep)+C(Stamp_Parameters):C(rep)', data=df).fit()
#anova_table = sm.stats.anova_lm(model, typ=2)
#print(anova_table)

    #add statistics - kruskal
kruskal_result = kruskal(*[group["percent_near90"].values for name, group in df.groupby('Category')])
print(f'Kruskal-Wallis H-statistic: {kruskal_result.statistic}, p-value: {kruskal_result.pvalue}')
