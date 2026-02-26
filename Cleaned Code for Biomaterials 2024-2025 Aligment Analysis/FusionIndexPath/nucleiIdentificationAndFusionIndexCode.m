%code for identifying nuclei with cellpose, and then overlaying the
%identification on segmented muscle images done by hand
%author: Laura Schwendeman
%date: 6-23-2024
close all; clc; clear; set(0,'DefaultFigureVisible','on');
%declare relevant variables
%for alignment study
% dirLocation = "C:\Users\laSch\Dropbox (MIT)\Raman Lab\Laura Schwendeman\20240530 alignment 6 good IF\40x pancakes\"; %change directory as needed
% conditions = ["12pt5", "25", "62pt5", "125", "flat", "unstamped"]; %the order matters
% conditionNumbersKey = [1:6];%for tagging the conditions in the structure order and not repeating 1 - 12.5, 2- 25, 3- 62.5, 4-125, 5-flat, 6-unstamped
% replicates = 1:3; %should be able to index specific replicates this way, can increase the number

%for NMJ Paper - muscle only study
dirLocationM = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\2_13_24 Fliped 40x Muscle only experiment confocal\muscle_stained\segmentation\"; %change directory as needed
dirLocationN = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\2_13_24 Fliped 40x Muscle only experiment confocal\";
conditions = ["RGECO_R3", "WT_R4", "WT_R4NDM"]; %the order matters
conditionNumbersKey = [3];%for tagging the conditions in the structure order and not repeating 1 - Rgeco, 2 - WTr4, 
replicates = [2, 3]; %should be able to index specific replicates this way, can increase the number
replicateKey = {"p1_B5", "p1_C2", "p1_C3", "p1_C4", "p1_C5"; ...
    "p2_B2", "p2_B3", "p2_B4", "p2_B5", "p2_C2";...
    "p1_B2", "p1_B4", "p2_C3", "p2_C4", "p2_C5"};
skipConditions = [1,1;2,1; 2,2; 2,3;2,4];%[1,1; 1,2; 1,3; 1,4; 1,5; 2,1; 2,2; 2,3;2,4];



conditionNumbersKey = repelem(conditionNumbersKey, length(replicates));

%variables for storing info
load('FiberData-NMJMuscleOnly2-WidthsCopy2.mat');
numImages = length(conditions)*length(replicates);
ImFlorData.fusionIndex = zeros(numImages, 1); 
ImFlorData.fiberNucleiLog = cell(numImages,1);
ImFlorData.fiberNucleiCounts = cell(numImages, 1);
ImFlorData.AverageNucleiCount = zeros(numImages,1);
ImFlorData.PictureName = cell(numImages,1);
ImFlorData.nucleiLabels = cell(numImages, 1);
ImFlorData.muscleLabels = cell(numImages, 1);
ImFlorData.fiberWidths = cell(numImages, 1);

%for cellpose stuff - pretrained nuclei segmentation model
cp = cellpose(Model="nuclei");

%% loop through all the different images
counterVar = 1; 
for cIndx = conditionNumbersKey
    for rIndx = replicates

    %conditions to skip for now 
    if any(cIndx == skipConditions(:,1)) && any(rIndx == skipConditions(:,2))
        continue
    end
ImFlorData.PictureName = conditions(cIndx) + "_" + num2str(rIndx);

%open the nuclei image
% fileNameN = dirLocation + cIndx +"_rep" + num2str(rIndx) + "_40x_pancake_nuclei.jpg";
% fileNameM = dirLocation + cIndx +"_rep" + num2str(rIndx) + "_40x_pancake_fibers.tiff";    

%for the NMJ 2_24_26 revisions
fileNameM = dirLocationM + "40x_fliped_D14_stain_" + conditions(cIndx) + "_" + replicateKey(cIndx, rIndx) + ".nd2-channel_1_Simple Segmentation.tiff";
fileNameN = dirLocationN + "40x_fliped_D14_stain_" + conditions(cIndx) + "_" + replicateKey(cIndx, rIndx) + ".nd2-channel_0.png";

imageN = imread(fileNameN);
imageN = im2gray(imageN);

figure(1);
imshow(imageN);

%set the cell diameter
averageCellDiameter = 55; %30; %px

%run cellpose
labels = segmentCells2D(cp,imageN,ImageCellDiameter=averageCellDiameter);

%display segmentation and object labeling
figure(2);
imshow(labeloverlay(imageN,labels))

%save the labels in the datastructure
ImFlorData.nucleiLabels = labels; 

%% get some info about all of the nuclei regions
%statsN = regionprops(labels, 'Area', 'Centroid');

%% now open the muscle image (by hand segmented)

imageF = imread(fileNameM);
imageF = imageF(:,:,1:3);

figure(3); 
imshow(imageF);

% %get rid of the white outlines
% whitePixels = (~(imageF(:,:,1) == 253 | imageF(:,:,1) == 227 | imageF(:,:,1) == 254) | imageF(:,:,3) > 100);
% for i = 1:3
%     whitePixelsFull(:,:,i) = whitePixels;
% end
% 
% imageF(whitePixelsFull) = 0;


% figure(4); 
% imshow(imageF);

%binarize and then find the objects
imageF = imbinarize(rgb2gray(imageF), "global");
SE = strel('disk',5);
imageF = bwareafilt(imageF, [3000,inf]);
imageF = imfill(imageF, "holes");
imageF = imopen(imageF, SE);
imageF = bwareafilt(imageF, [3000,inf]);


%imageF = bwareafilt(imageF, [2000,inf]);


%imageF = imclose(imageF, SE);

figure(5); 
imshow(imageF);

%get all the fibers with labels
labelsF = bwlabel(imageF);
figure(6);
imshow(label2rgb(labelsF, 'colorcube'));
figure(6); 
imshow(labeloverlay(label2rgb(labelsF, 'colorcube'), labels))

%save the labels
ImFlorData.muscleLabels = labelsF;

%% count the number of nuclei in each fiber
 
%percent of overlap to include the nucleus inside a given fiber
overlapThreshold = 0.5; 

%make a matrix to store info if a given numbered nucleus is in a fiber
numFibers = max(labelsF, [], 'all');
numNuclei = max(labels,[], 'all');
FiberNucleusLog = zeros(numFibers, numNuclei);
FiberWidthLog = cell(numFibers,1);

%Now loop through each Fiber and see if any of the nuclei are in there
figure(7)
hold on;
for fiber = 1:numFibers
     fiberPix = labelsF == fiber; 
     imshow(fiberPix);
    %FiberWidthLog{fiber} = getFiberWidths(fiberPix,10);
     % imshow(fiberPix);
    for nucleus = 1:numNuclei
        nucleusPix = labels == nucleus; 
        
        if sum(fiberPix & nucleusPix,'all')/sum(nucleusPix,'all') > overlapThreshold
            FiberNucleusLog(fiber, nucleus) = 1; 
            %imshow(label2rgb(nucleusPix,'jet'));
        end

    end
   
end

%% store summary data about number of nuclei in fibers

loggedNucleiNums = find(sum(FiberNucleusLog, 1) > 0);
numNucleiLogged = sum(sum(FiberNucleusLog, 1) > 0);

markedNucleiIm = labels; 
markedNucleiIm(ismember(labels, loggedNucleiNums)) = -1; 
markedNucleiIm(markedNucleiIm > 0) = -2; 

markedNucleiIm = markedNucleiIm*-1; 

%plot the results
figure(15)
fiberMap = [255, 33, 222]./255;
nucleiMap = [127, 250, 248; 26, 30, 240]/255;
imshow(labeloverlay(label2rgb(labelsF>0, fiberMap),markedNucleiIm)); %label2rgb(markedNucleiIm,nucleiMap)));


%save the nuclei log
ImFlorData.fiberNucleiLog = FiberNucleusLog;

%get values for nuclei per fiber
ImFlorData.fiberNucleiCounts= sum(FiberNucleusLog, 2);

%get value of nuclei in a fiber out of the total nuclei
ImFlorData.fusionIndex = numNucleiLogged/numNuclei; 

%% Get Nuclei Roundness and Areas

%get the region properties
stats = regionprops("table", labels, "Circularity", "Area");

ImFlorData.NucleiCircularity = stats.Circularity; 
ImFlorData.NucleiAreas = stats.Area; 


%% save to the data struct

%ImFlorData.fiberWidths = FiberWidthLog; 

FiberDataStruct{cIndx,rIndx} = ImFlorData;

%counterVar = counterVar + 1; 
disp(cIndx + " " + num2str(rIndx));  

save('fiberdata_NMJMuscleOnly2_nowidthsforextra.mat', 'FiberDataStruct');


    end
end

%save all the data one laste time
%save('fiberdata.mat', 'FiberDataStruct');


%% depreciated, an old way to calculate widths

%fiberWidths = getFiberWidths(fiberPix, 10)

%% helpful functions
%from ChatGpt with some edits, gets the fiber widths (check the *2
%multiplier though) -- depreciated, use new code instead
function [fiberWidths] = getFiberWidths(fiberImage, numSamplePoints)

    

% Step 2: Skeletonize the object
skeletonImage = bwmorph(fiberImage, 'skel', Inf);

% figure; 
% imshow(skeletonImage); 
% figure; 
% imshow(fiberImage);

% Step 3: Extract properties of the object
props = regionprops(fiberImage, 'Orientation', 'Centroid');
objectOrientation = props(1).Orientation;

% Step 4: Initialize width array
widths = [];

% Get the coordinates of the skeleton
[y, x] = find(skeletonImage);

%down sample the points
x = x(1:ceil(length(x)/numSamplePoints):length(x));
y = y(1:ceil(length(y)/numSamplePoints):length(y));

% Iterate over each skeleton point
for k = 1:length(x)
    % Current skeleton point
    pt = [x(k), y(k)];
    
    % Compute the perpendicular direction
    theta = deg2rad(objectOrientation + 90);
    dx = cos(theta);
    dy = sin(theta);
    
    % Create a line in the perpendicular direction
    lineLength = 100; % Adjust as needed
    x1 = pt(1) - lineLength * dx;
    y1 = pt(2) - lineLength * dy;
    x2 = pt(1) + lineLength * dx;
    y2 = pt(2) + lineLength * dy;
    
    % Sample points along the line
    numSamples = 30; % Number of sample points
    xLine = linspace(x1, x2, numSamples);
    yLine = linspace(y1, y2, numSamples);
    
    % Interpolate the binary image along the line
    lineValues = interp2(double(fiberImage), xLine, yLine);
    
    % Find the width along this line
    binaryLine = lineValues > 0.5; % Threshold to get binary line

    %find the max number of contigous set of white pixels
    width = getLongestPixCount(binaryLine)/numSamples*lineLength*2;
    
    if ~isempty(width)
    % Store the width
    widths = [widths; width];

      % Store the line width for visualization
       x1 = pt(1) - width/2 * dx;
    y1 = pt(2) - width/2 * dy;
    x2 = pt(1) + width/2 * dx;
    y2 = pt(2) + width/2 * dy;
    %disp([x1, x2, numSamples])
    xLine = linspace(round(x1), round(x2), round(numSamples));
    yLine = linspace(round(y1), round(y2), round(numSamples));
    perpendicularLines{k} = [xLine', yLine'];
    
    else 
       perpendicularLines{k} = [0,0;0,0];
       disp(binaryLine);

    end
end

% Display the widths
% disp('Widths along the minor axis:');
% disp(widths);

% Optional: Plot the widths
figure;
plot(widths);
title('Widths along the minor axis');
xlabel('Skeleton Point Index');
ylabel('Width');

figure;
imshow(fiberImage);
hold on;

% Plot the perpendicular lines with the measured widths
for k = 1:length(perpendicularLines)
    line = perpendicularLines{k};
    plot(line(:, 1), line(:, 2), 'r-', 'LineWidth', 1.5);
    midPoint = round(size(line, 1) / 2);
   % text(line(midPoint, 1), line(midPoint, 2), num2str(widths(k)), 'Color', 'yellow');
end

title('Measured Widths Along the Minor Axis');
hold off;

fiberWidths = widths;

    
end


function [longestPixCount] = getLongestPixCount(mappedLine)


    diffPixCount = diff(mappedLine);
     
   
    %beginning check
    if mappedLine(1)
        diffPixCount = [1 diffPixCount];
    end
    if mappedLine(end)
        diffPixCount = [diffPixCount -1];
    end

    %get the locations of the boundary
    boundaryLocPlus = find(diffPixCount >0);
    boundaryLocMinus = find(diffPixCount<0);

    %figure out all the widths with white lines- could probably be
    %rewritten to be more efficient
    widths = [];
    for StartIndx = boundaryLocPlus
        EndIndx = boundaryLocMinus(find(boundaryLocMinus - StartIndx >0, 1));
        widths = [widths (EndIndx-StartIndx)];

    end

    longestPixCount = max(widths, [], "all");

end

%function that filters the muscle fiber image
function [filteredFibers] = filterFiberImage(FiberImage)

    
end
