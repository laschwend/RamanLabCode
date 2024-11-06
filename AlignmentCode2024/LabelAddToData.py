# -*- coding: utf-8 -*-
"""
Created on Mon Jul  8 07:31:32 2024

@author: laura Schwendeman

Purpose: To add labels to data in grooved or ungrooved categories for fiber analysis
"""

#libraries
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import plotly.express as px



fileName = "C:/Users/laSch\Desktop/Raman Lab/RamanlabCode/AlignmentCode2024/FiberAnalysis/C2C12FiberData40x.xlsx"

sheetsToEdit = ["Sheet1", "Sheet2", "Sheet3", "Sheet4"]

for sheetNum in sheetsToEdit:
    
    df = pd.read_excel(fileName, sheet_name = sheetNum)
    
    category = ["ungrooved" if x in ("flat", "unstamped") else "grooved" for x in df.StampCondition]
    
    df['Category'] = category
    
    df.to_excel(fileName, sheet_name = sheetNum)
    
    
    
