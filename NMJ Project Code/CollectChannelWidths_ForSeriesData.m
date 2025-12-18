%Script for processing through and saving the widths of different channels
%from experiments - specifically for new format of images with multiple
%sereis

%author: Laura S. 
%date: 12/4/2025


%user defined variables

%for Gels from 12_4_2025
folderDir = "C:\Users\draga\MIT Dropbox\Raman Lab\Laura Schwendeman\12_5_25 Revision Monoculture\Gels\WidthAnalysis\";
fileNames = {"MN_gels_galv_20X - Denoised"};

AnalysisLayer = 1;

dataStructSaveName = "11_8_3_Channels_12_4_25_3.mat";

%% load the datastruct to save to if already available
try 
    load(dataStructSaveName)
    newFile = 0; 
catch
    disp("no previous save for the files, making a new data aquisition for the pictures.")
    newFile = 1; 
end

%% Loop through each file and extract larger channel dimension and smaller
%channel deimension
%add option for viewing the filtered 3D image stack?
% wideChannelDimensions = %zeros(length(fileNames), 1);
% thinChannelDimensions = zeros(length(fileNames), 1);
file = convertStringsToChars( folderDir + fileNames{1} + ".nd2");
reader =  BioformatsImage(file); 
%%
counter = 1;
for f = 1:reader.seriesCount
    for channelC = 1:3
    %get image Stack
    reader.series = f; %sets the series number
    imageStack = makeImageStack(reader, 1);

    %Now get a filtered version of the stack
    filteredStack = filterTheStack(imageStack, reader);


    %show a 3D volume version of the filtered stack
    % figure(1)
    % alphaMap = linspace(0, 1, 256);
    % alphaMap(1:55) = 0;
    % volshow(filteredStack, "Alphamap",alphaMap)

  
    %provide an crop rectangle for each of the thicknesses if already
    %provided
    if newFile
        old_rectt_wide = 0; 
        old_rectt_thin = 0; 
    else
        old_rectt_wide = imageParam.wideRectt{f}; 
        old_rectt_thin = imageParam.thinRectt{f}; 
    end

    AnalysisLayer = 1;%floor(reader.sizeZ/2)+3;

    %now get the value of the widechannel
    [wideChannelDimensions(counter), imageParam.wideRectt{counter}] = getChannelWidth(imageStack, AnalysisLayer, reader, "Large Width", newFile, old_rectt_wide); 

    %get the value of the small channel
    [thinChannelDimensions(counter), imageParam.thinRectt{counter}] = getChannelWidth(imageStack, AnalysisLayer, reader, "Thin Width", newFile, old_rectt_thin);
    counter = counter +1;
    end


end

%% saving the data collected
imageParam.wideChannelDimensions = wideChannelDimensions; 
imageParam.thinChannelDimensions = thinChannelDimensions; 
imageParam.fileNames = fileNames; 
save(dataStructSaveName, "imageParam");

%show summary plots

figure(10);
bar(thinChannelDimensions);
ylabel("Thickness (um)")
title("ThinAverageWidths")
set(gca, "XTickLabel", fileNames)

figure(11);
bar(wideChannelDimensions);
ylabel("Thickness (um)")
title("WideAverageWidths")
set(gca, "XTickLabel", fileNames)

%% testing
makeLabels(fileNames)

%% functions

function [imageStack] = makeImageStack(reader, channel)

    imageStack = zeros(reader.height,reader.width, reader.sizeZ); 

    for z = 1:reader.sizeZ
    
        imageStack(:,:,z) = getPlane(reader, z, channel, 1);
    
    end


end


function [filteredStack] = filterTheStack(imageStack, reader)

    filteredStack = zeros(reader.height,reader.width, reader.sizeZ); 

    for z = 1:reader.sizeZ
    
        J = imageStack(:,:,z);
        %Filter the image
        J_filt = imgaussfilt(J, 5);
        J_filt = mat2gray(J_filt);

        filteredStack(:,:,z) = J_filt;
    
    end

end

function [channelAveWidth, rectt] = getChannelWidth(imageStack, layerHeight, reader, titleString, newFileBool, old_rectt)

    J = imageStack(:,:,layerHeight);


    figure(1);
    J = imshow(J, []);
    title(titleString);


    if newFileBool
        [J,rectt] = imcrop(J);
    else
        [J,rectt] = imcrop(J, old_rectt);
    end

    J_filt = imgaussfilt(J, 5);
    
    J_filt = mat2gray(J_filt);

    J_bin = imbinarize(J_filt, 0.5);

    measures = altWidthMeasure(~J_bin);

    channelAveWidth =  reader.pxSize(1)*mean(measures);
    

end



function [fiberWidths] = altWidthMeasure(fiberImage)
    

    
    % Step 2: Skeletonize the object
    skeletonImage = bwskel(fiberImage);

    figure(5);
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

    %  figure(3);
    % imshow(edtImage*2, []);
    % 
    % [redSkelx, redSkely] = find(skeletonImage >0); 
    % 
    % hold on
    % plot(redSkely, redSkelx, '.r', "MarkerSize", 3);
    % 
    % boundaries = bwboundaries(fiberImage);
    % x = boundaries{1}(:, 2);
    % y = boundaries{1}(:, 1);
    % 
    % plot(x, y, '.y', "MarkerSize", 3)


    

end

