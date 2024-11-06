%Author: Laura Schwedeman
%Date: 7/23/2024
%Purpose: calculate the cell size of cells in different pictures
clear; close all; clc;
C2C12PicFileName = "C2C1210x_25_0001_Trans.tiff";
HumanPicFileName = "Human10x_25_0001_Trans.tiff";

%% segment the picture with cellpose

%for cellpose stuff - pretrained nuclei segmentation model
cp = cellpose(Model="nuclei");
%%
aveDia = 30; 
C2C12DiaArray = segmentCellsAndMeasure(C2C12PicFileName, cp, aveDia);
%%
aveDia = 30;
HumanDiaArray = segmentCellsAndMeasure(HumanPicFileName, cp, aveDia);

%% plot the results
figure; 

hold on

px2um = 1/1137.686*1000;

histogram(C2C12DiaArray*px2um, "FaceAlpha", 0.5);
histogram(HumanDiaArray*px2um, "FaceAlpha",0.5);

legend("C2C12", "Human");

%% functions 

function [diameterArray] = segmentCellsAndMeasure(cellFileName, cp, averageCellDiameter)

    %load the image
    imageC = imread(cellFileName);
    imageC = im2gray(imageC);
    %figure; 
    %imshow(imageC);

    %run cellpose
    labels = segmentCells2D(cp,imageC,ImageCellDiameter=averageCellDiameter);

    %check the results
    figure;
    imshow(labeloverlay(imageC,labels))

    %get the equivalent diamters
    stats = regionprops("table", labels, "EquivDiameter");
    diameterArray = stats.EquivDiameter;

end
