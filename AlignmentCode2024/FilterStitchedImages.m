%date: 7/13/2024
%author: Laura Schwendeman
%Purpose: To filter fiber images and prep them for directionality analysis
%in ImageJ

close all; clc; clear;

dirLocation = "C:\Users\laSch\Dropbox (MIT)\Raman Lab\Laura Schwendeman\20240603 Alignment Experiment 7 - human tc twitch\20240607 alignment 7 good IF\4x stitched images\";
%dirLocation = "C:\Users\laSch\Dropbox (MIT)\Raman Lab\Laura Schwendeman\20240530 alignment 6 good IF\4x stitched pics\other replicates\";

conditions = ["12pt5","62pt5", "25", "125", "flat", "unstamped"];
%conditionNumbersKey = [4];%for tagging the conditions in the structure order and not repeating 1 - 12.5, 2- 25, 3- 62.5, 4-125, 5-flat, 6-unstamped
replicates = 1:3;


for cIndx = conditions
    for rIndx = replicates

        %get the name of the file to open and the file to save to 
        fileName = dirLocation + cIndx +"_rep" + num2str(rIndx) + "_4x-MaxIP.tif";
        saveName = dirLocation + cIndx +"_rep" + num2str(rIndx) + "4x_fullWellFiltered.tif";

        imageF = imread(fileName);

        filteredImage = getFilteredImage(imageF, 400);

        imwrite(1-filteredImage, saveName);
        
    end
end



function [filteredIm] = getFilteredImage(imageF, sizefilt)
    imageBin = imbinarize(imageF, "adaptive");
    figure(1); 
    imshow(imageBin)
    se = strel('disk',2);

    imageBin = bwareafilt(imageBin, [sizefilt,inf]);
    figure(2); 
    imshow(imageBin)

     closedImage = imclose(imageBin,se);
    figure(3); 
    imshow(closedImage)

    se = strel('disk',1);
    ErodedIm = imerode(closedImage,se);

    figure(4); 
    imshow(ErodedIm);

    filteredIm = closedImage; 
    



end