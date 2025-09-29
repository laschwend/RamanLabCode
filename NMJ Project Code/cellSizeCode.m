%% to get the sizes of cells for NMJ project

clear all; close all; 
%% files to open: 

filePath = 'C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\NMJ Paper Figure Resources\Fig 2r\Pictures for C2C12 WT Size Measures\';

fileNames = {"125_2_10x_01.tif", "flat_2_10x_01.tif", "flat_3_10x_01.tif", "unstamped_2_10x_01.tif", "unstamped_4_10x_01.tif"};

px2um = 1/1137.686*10^3; %um/px
%%
%for cellpose stuff - pretrained nuclei segmentation model
cp = cellpose(Model="nuclei");


cellDiameters = [];

for i = 1:length(fileNames)

    fileNameN = filePath + fileNames{i};
    imageN = imread(fileNameN);
    imageN = im2gray(imageN);

    figure(1);
    imshow(imageN);

    %set the cell diameter
    averageCellDiameter = 12; %30; %px
    
    %run cellpose
    labels = segmentCells2D(cp,imageN,ImageCellDiameter=averageCellDiameter);
    
    %display segmentation and object labeling
    figure(2);
    imshow(labeloverlay(imageN,labels))
    disp(fileNameN);

    %save the diameter widths
    diameters = regionprops(labels, "EquivDiameter");
    vals = [diameters.EquivDiameter]*px2um;
    cellDiameters = [cellDiameters vals];
    
end

%%
figure; 
histogram(cellDiameters);
xlabel("C2C12 Cell Diameter (um)");
mean(cellDiameters)
improvePlot();

