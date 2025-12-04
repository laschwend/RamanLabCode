Read Me: 


This Folder Contains Code for running alignment and fusion index analysis the general analysis flow is as follows: 

Fusion Index Path: 

For Each Cell Type
1) ImageJ: Split Image color channels to get fibers and nuclei .tif with ReformatNd2toTif.ijm
2) Drawing Software: Trace Fibers by hand to get segmentation
	Alternatives that I tried but didn't work super well: 
		ilastik: could be promising if more time is put into it
		
3) Run nucleiIdentificationAndFusionIndexCode.m script to use cellpose library to segment nuclei & generate large class cell with raw fiber and nuclei tagging data
4) Run FiberWidthMeasurement.m to add fiber widths to the cell data
5) Make a new excel Sheet in Excel with at least 8 sheets and name appropriately
5) run SummarizeData.m Script to save summary data into the spreadsheet
6) Open Spreadsheet in Python with FinalPaperPlots.py to get final figures with seaborn package (can also write your own script to make figures, mine is pretty messy)
	*note, you might need to comment out sections of the code & rewrite filenames


Alignment Path: 

For each cell type
1) filter MaxIP images in MATLAB with FilterStitchedImages.m
2) open imageJ and run AlignmentDirectionalityScript.ijm
	can adjust rectangle cropping region as necessary
3) Run FitGaussianFromImageJ.py to get a .csv of fit gaussian values, can change the region measures here
4) use labelAddToData.py to add grooved and ungrooved labels to data (shouldn't need for new dataset hopefully) 
5) use FinalPaperPlots.py code to plot summary alignment plots
6) use superviolin plot from terminal to make superviolin plots





