//opens a file that has multiple series and opens them as individual pictures to process
//author: Laura Schwendeman
//date: 8/18/2025


//defined variables
folderName= "C:/Users/laSch/MIT Dropbox/Raman Lab/Laura Schwendeman/8_11_25 nmj GELMA casting results/"
filename = "4x_brightfield_round2_11_8_3.nd2"

fullfile = folderName + filename; 

//get an object with info on the number of series
run("Bio-Formats Macro Extensions"); 
Ext.setId(fullfile); 

Ext.getSeriesCount(nSeries);
print("Number of series: " + nSeries);


run("Bio-Formats Importer", "open=[fullfile] color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_" + 2);
run("Subtract Background...", "rolling=50 light sliding");
run("Smooth");