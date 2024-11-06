%Date: 7/13/2024
%Author: Laura Schwendeman
%Purpose: generate segmented muscle fibers for human samples Alignment
%project 2024

%% setup up file names and for loop and save names

close all; clc; clear;

dirLocation = "C:\Users\laSch\Dropbox (MIT)\Raman Lab\Laura Schwendeman\20240603 Alignment Experiment 7 - human tc twitch\40x pancakes\";

conditions = ["6pt25", "25", "125", "flat", "unstamped"];
%conditionNumbersKey = [4];%for tagging the conditions in the structure order and not repeating 1 - 12.5, 2- 25, 3- 62.5, 4-125, 5-flat, 6-unstamped
replicates = 1:3;


for cIndx = conditions
    for rIndx = replicates

        %get the name of the file to open and the file to save to 
        fileName = dirLocation + cIndx +"_rep" + num2str(rIndx) + "_40x_pancake_fibers.tif"
        saveName = dirLocation + cIndx +"_rep" + num2str(rIndx) + "_40x_pancake_fibers.mat";

        
        %open the image file
        imageF = imread(fileName); 

        %run the segmentation on it
        labeledImage = getSegmentedImage(imageF)

        save(saveName, 'labeledImage');

        close all; 
    end
end


%function the plots and returns the segmented image
function [labeledImage] = getSegmentedImage(imageF)

    imageBin = imbinarize(imageF, "adaptive");
figure; 
imshow(imageBin)
se = strel('disk',2);


imageBin = bwareafilt(imageBin, [1000,inf]);
figure; 
imshow(imageBin)

closedImage = imclose(imageBin,se);
figure; 
imshow(closedImage)
se = strel('disk',1);
ErodedIm = imerode(closedImage,se);

figure; 
imshow(ErodedIm);
ErodedIm = bwmorph(ErodedIm, "bridge");
ErodedIm = imfill(ErodedIm, "holes");
se = strel('disk',10);


figure; 
imshow(ErodedIm);

%% now get objects
labeledImage = bwlabel(ErodedIm);
    
plotboundingBoxes(labeledImage)
    

end


function [] = plotboundingBoxes(labeledImage)
    
    stats = regionprops(labeledImage, 'Area', 'Centroid', 'BoundingBox'); 

for k = 1:length(stats)
    fprintf('Region %d:\n', k);
    fprintf('  Area: %d\n', stats(k).Area);
    fprintf('  Centroid: (%.2f, %.2f)\n', stats(k).Centroid(1), stats(k).Centroid(2));
end

rgbLabel = label2rgb(labeledImage, 'lines', 'k');

figure; 
imshow(rgbLabel);

% Draw the bounding boxes 
 for k = 1:length(stats) 
 boundingBox = stats(k).BoundingBox;
 rectangle('Position', boundingBox, 'EdgeColor', 'w', 'LineWidth', 2); 
 end 
 % Optionally annotate the centroids of the labeled regions
 centroids = regionprops(labeledImage, 'Centroid'); 
 for k = 1:length(centroids) 
     centroid = centroids(k).Centroid;
     text(centroid(1), centroid(2), sprintf('%d', k), ... 
         'HorizontalAlignment', 'center', ... 
         'VerticalAlignment', 'middle', ... 
         'Color', 'w', ... 
         'FontSize', 12, ... 
         'FontWeight', 'bold'); 
 end 
 hold off;

    
end