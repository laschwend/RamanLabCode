%scratch plotting code for getting supplementary plots
close all; clear; clc;
load("fiberdata.mat");

condition = 1; 
rep = 1; 

labelsF = FiberDataStruct{condition,rep}.muscleLabels; 
labels = FiberDataStruct{condition,rep}.nucleiLabels;

FiberNucleusLog = FiberDataStruct{condition,rep}.fiberNucleiLog;

loggedNucleiNums = find(sum(FiberNucleusLog, 1) > 0);
numNucleiLogged = sum(sum(FiberNucleusLog, 1) > 0);

markedNucleiIm = labels; 
markedNucleiIm(ismember(labels, loggedNucleiNums)) = -1; 
markedNucleiIm(markedNucleiIm > 0) = -2; 

markedNucleiIm = markedNucleiIm*-1; 

figure(15)
fiberMap = [255, 33, 222; 255, 255, 255;255, 255, 255;255, 255, 255;255, 255, 255]./255;
nucleiMap = [128, 128, 255; 26, 30, 240]/255;
imshow(labelsF*0);
hold on; 
labels2Show = labelsF>0; 

imshow(labeloverlay(label2rgb(labels2Show, fiberMap, 'w'),markedNucleiIm)); %label2rgb(markedNucleiIm,nucleiMap)));
makeScaleBar(1/4.6341, 100, markedNucleiIm, '\mum', 'k')
%% getting a nice representation of fiber Width measures
fiberNum = 17; 

 fiberPix = labelsF == fiberNum; 
 
 fiberMap = [255, 33,222; 255, 0,0]/255; 
 labelsF(labelsF == fiberNum) = -2;
 labelsF(labelsF >0) = -1; 
 labelsF = labelsF*-1; 

 figure(4);
 imshow(label2rgb(labelsF, fiberMap))
    
  altWidthMeasure(fiberPix);


%% Getting a Nice Representation of the Nuclei Circularity
imageFileName = "C:\Users\laSch\Dropbox (MIT)\Raman Lab\Laura Schwendeman\20240530 alignment 6 good IF\40x pancakes\12pt5_rep1_40x_pancake_nuclei.jpg";

imageN = imread(imageFileName);

nucleiMap = [127, 250, 248;127, 250, 248]/255;
labels2 = labels >0;

edgeMatrix=edge(labels,'Canny');


figure; 
imshow(labeloverlay(rgb2gray(imageN)*2,labels2));
makeScaleBar(1/4.6341, 100, imageN, '\mum', 'w')
figure; 
imshow(labeloverlay(rgb2gray(imageN)*2,labels,"Colormap",'sky'));
makeScaleBar(1/4.6341, 100, imageN, '\mum', 'w')

figure; 
imshow(label2rgb(labels2, [128, 128, 255]/255, 'k'));
makeScaleBar(1/4.6341, 100, imageN, '\mum', 'w')

figure; 
imshow(label2rgb(labels,'sky', 'k', 'shuffle'));
makeScaleBar(1/4.6341, 100, imageN, '\mum', 'w')

%% make the labeled image with scale related to circularity

figure; 
stats = regionprops(labels, 'Circularity');

circularity = [0 stats.Circularity];
CircularityMap = round(circularity(labels+1)*180);
c = colormap('jet');%palette2./255;%colormap('parula');
imshow(label2rgb(CircularityMap, flip(c), 'w','noshuffle'))
makeScaleBar(1/4.6341, 100, imageN, '\mum', 'w')
title('Nuclei Circularity 12.5')
c = flip(c);
c = c(1:180, :);
colormap(c)
colorbar;
%%
figure; 
circularity = [stats.Circularity];
histogram(circularity)

disp('mean')
mean(circularity)
disp('median')
median(circularity)
disp('mode')
mode(circularity)

%% a quick nuclei median vs mean check
% circMeans = zeros(6)
% 
% for i = 1:

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

    figure(3);
    imshow(edtImage*2, []);

    [redSkelx, redSkely] = find(skeletonImage >0); 

    hold on
    plot(redSkely, redSkelx, '.r', "MarkerSize", 3);

    boundaries = bwboundaries(fiberImage);
    x = boundaries{1}(:, 2);
    y = boundaries{1}(:, 1);

    plot(x, y, '.y', "MarkerSize", 3)

    figure(5); 
    histogram(fiberWidths);
    grid off;
    xlabel('Width in Pixels');
    ylabel('Count');
    title('Fiber Widths');
end

function [] = makeScaleBar(l2pxRatio, length, image, units, colorChar)
    hold on; 
    [imageHeight, imageWidth, ~] = size(image); 

    y = imageHeight*.95; 
    x2 = imageWidth*.92; 
    x1 = x2 - length/l2pxRatio;

    plot([x1, x2], [y,y], colorChar, 'LineWidth', 3);% colorCha 'LineWidth', 3);

    text((x1+x2)/2, y, [num2str(length) ' ' units],'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom','FontSize', 12, 'FontName', 'Arial', 'Color',colorChar);

end

