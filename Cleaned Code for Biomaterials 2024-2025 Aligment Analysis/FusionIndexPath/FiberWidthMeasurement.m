%Author: Laura Schwendeman
%Data: 6/30/2024
%purpose: To add fiber width analysis to segmented fibers from
%nucleiIdentificationandfusionindexcode.m

%don't forget to chang the save name at the bottom

%dirLocation = "C:\Users\laSch\Dropbox (MIT)\Raman Lab\Laura Schwendeman\20240530 alignment 6 good IF\40x pancakes\";
dirLocation = "C:\Users\laSch\Dropbox (MIT)\Raman Lab\Laura Schwendeman\20240603 Alignment Experiment 7 - human tc twitch\40x pancakes\";

conditions = ["12pt5", "25", "62.5", "125", "flat", "unstamped"];
conditionNumbersKey = [1, 2, 3, 4, 5, 6];%for tagging the conditions in the structure order and not repeating 1 - 12.5, 2- 25, 3- 62.5, 4-125, 5-flat, 6-unstamped
replicates = 1:3; 

conditionNumbersKey = repelem(conditionNumbersKey, length(replicates));

%variables for storing info
load('fiberdataH.mat');

counterVar = 1; 
for cIndx = conditions
    for rIndx = replicates
        ImageData = FiberDataStruct{conditionNumbersKey(counterVar), rIndx};

        ImageData.PictureName = cIndx + "_" + num2str(rIndx);

         %percent of overlap to include the nucleus inside a given fiber
        overlapThreshold = 0.5; 
        
        %get the fiber label picture
        labelsF = ImageData.muscleLabels; 
        labelsF = bwlabel(labelsF~=0);

        %make a matrix to store info if a given numbered nucleus is in a fiber
        numFibers = max(labelsF, [], 'all');      
        FiberWidthLog = cell(numFibers,1);
        
        %Now loop through each Fiber and compile the widths
        figure(7)
        hold on;
        for fiber = 1:numFibers
             fiberPix = labelsF == fiber; 
            %FiberWidthLog{fiber} = getFiberWidths(fiberPix,10);
            FiberWidthLog{fiber} = altWidthMeasure(fiberPix);
        end
    
        ImageData.fiberWidths = FiberWidthLog;

        FiberDataStruct{conditionNumbersKey(counterVar), rIndx} = ImageData; 
        counterVar = counterVar +1;
    end
end


%% save the updated fiberDataStructure

save('fiberdataH.mat', 'FiberDataStruct');

%% functions 
% this is the best way I found to get width measurements
function [fiberWidths] = altWidthMeasure(fiberImage)
    
    % Step 2: Skeletonize the object
    skeletonImage = bwskel(fiberImage);

    figure(1);
    subplot(2,3,1)
    imshow(skeletonImage);
    title('skelImage')

    edtImage = bwdist(~fiberImage); 

    subplot(2,3,2);
    imshow(edtImage, []);
    title('distance image')

    diameterImage = 2 * edtImage .* single(skeletonImage);

    subplot(2,3,3);
    imshow(diameterImage, [])
    title('Diameter Image');

    fiberWidths = diameterImage(diameterImage >0);

    subplot(2,3,4);
    histogram(fiberWidths);
    grid on;
    xlabel('Width in Pixels');
    ylabel('Count');
    title('widths');

    subplot(2,3,5);
    imshow(fiberImage);
    title('original image')


    

end



%This is the other way I thought of using the minor axis of the shape but
%its a bad way to get width measurements,wouldn't recommend using it unless
%it was editted. It's also slower. 
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
figure(1);
plot(widths);
title('Widths along the minor axis');
xlabel('Skeleton Point Index');
ylabel('Width');

figure(2);
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


