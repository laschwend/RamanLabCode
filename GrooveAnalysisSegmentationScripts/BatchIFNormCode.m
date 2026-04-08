%Author: Laura Schwendeman
% Date: 4/8/2026
% Description: Code for using "Gray Value" for mapping groove heights along
% the middle line of an image

close all; clear all; clc;
%% Load the image Data 
load("3_17_36_MaheeraGrooveAnalysis.mat");

pixelSize = 883.88/1024;%um
%% open the powerpoint presentation
import mlreportgen.ppt.*

% Create presentation
ppt = Presentation('output_presentation.pptx');
open(ppt);


%% Loop through the images, make plot, and save to a powerpoint or excel
for i = 1:length(fileNameData)
    
    %get the rotated image
    rotIm = getRotatedImageFromFile(fileNameData{i});

    %get the Z-Values
    ZVals = getzvals(rotIm);

    fig = figure(1);
    title(fileNameData{i}.name);
    subplot(1,2, 1);
    %plot the rotated Image
    imshow(rotIm, []);
    hold on; 
    X = 1:size(rotIm, 1);
    Y = round(size(rotIm, 2)/2);
    plot(X,Y*ones(size(rotIm,2)), '-r');

    %plot the intensity values
    subplot(1,2,2);
    ZVals = rescale(ZVals);
    ZVals = ZVals(ZVals>0);
    plot(1:length(ZVals)*pixelSize, ZVals);

    xlabel("um")
    ylabel("normalized Intensity Value");

    %save the figure to a powerpoint
    % Add to PowerPoint
    addFigureToPPT(ppt, fig, fileNameData{i}.name);

    % Close figure to avoid memory issues
    close(fig);

    
    
end

%% close the powerpoint or excel
% Save & close presentation
close(ppt);

%% helper functions

%a function for getting the rotated cross section from the original file
%object if the angle is already provided (breaks if not provided)
function [img] = getRotatedImageFromFile(file)
    
    fileName = fullfile(file.folder, file.name);
    
    %open the .nd2 file
    reader = BioformatsImage(fileName);

    % make 3D image stack
    imageStack = zeros(reader.height, reader.width, reader.sizeZ, 3);
    
    for c = 1:reader.sizeC
        for z = 1:reader.sizeZ
            imageStack(:,:,z) = getPlane(reader, z, 1, 1);
        end
    end
    
    %get the directionality
    mean_angle = file.angle;

     %section the image
    img = imrotate(imageStack(:,:,round(end/2)), mean_angle);
    
end


%gets the intensity values along the center line of the image
function [zvals] = getzvals(rotIm)
    zvals = rotIm(:,round(end/2));
end


function addFigureToPPT(ppt, fig, slideTitle)
import mlreportgen.ppt.*
    % Create a new slide (Title and Content layout)
    slide = add(ppt, 'Title and Content');

    % Add title if provided
    if nargin > 2 && ~isempty(slideTitle)
        replace(slide, 'Title', slideTitle);
    end

    % Save figure temporarily as PNG
    imgFile = [tempname, '.png'];
    exportgraphics(fig, imgFile, 'Resolution', 300);

    % Add image to slide
    replace(slide, 'Content', Picture(imgFile));

    % Optional: delete temp file
    delete(imgFile);
end