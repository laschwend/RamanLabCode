%Author: Laura Schwendeman
%Date: 9/26/25
%Purpose: Visualize and segment channel picture for figures
clear all; 

folderDir = "C:\Users\draga\MIT Dropbox\Raman Lab\Laura Schwendeman\2_25_26 11-9-3 D0 Stamping GelMa\";
fileNames = "20x_channelImages_D0_11_9_3_nicerep002 - Denoised.nd2_series 6.png";


    file = convertStringsToChars(folderDir + fileNames);
    filteredStack = imread(file);
    filteredStack = rgb2gray(filteredStack);

    %filteredStack = imcrop(filteredStack);

    %imageStack = makeImageStack(reader, 1);
    reader.width = size(filteredStack,1);
    reader.height = size(filteredStack,2);
    reader.sizeZ = 1;

    %Now get a filtered version of the stack
    filteredStack = filterTheStack(filteredStack, reader);

    figure(1);
    imshow(filteredStack(:,:,1));

    

    %% to save the data for the channel dimensions in an excel
    close all; 

    dataNames = {"11_9_3_Channels_2_26_26.mat"};

    

    thinWidths = [];
    thickWidths = [];
    valids = [3,4,5,6,8,9,10,11,12,14];

    for i=1:length(dataNames)
        
        load(dataNames{i});

        thick = imageParam.wideChannelDimensions(valids);
        thin = imageParam.thinChannelDimensions(valids);
        figure(2+i); 
        bar(thin)
        % if i ==1
        %     indx = 1:6;
        % elseif i == 2
        %     indx = 2:3;
        % elseif i ==3
        %     indx = [1 2 3 5];
        % else
        %     indx = 1:length(thick);
        % end

        % thick = thick(indx);
        % thin = thin(indx);

        %now add them to the widths 
        thinWidths = [thinWidths, thin'];
        thickWidths = [thickWidths, thick'];
  
    end
    

    figure(1);
    hold on; 
    h = histogram(thinWidths, 10, 'Normalization','probability');
    plot([10,10], [0,1], 'k');
    
    x = 0:.2:27;
    [gaussianT, meanthin] = getGaussianFit(thinWidths, x);
    disp(["Thin Mean " num2str(meanthin)]);
    plot(x,gaussianT, 'g')
    plot([mean(thinWidths),mean(thinWidths)], [0,1], 'g');

    axis([0, 30 , 0, .5])
    xlabel('w1 (um)')
    ylabel('Normalized Occurance')
    improvePlot();

    [h,p, ~, stats] = ttest(thinWidths, 10)
    stats
    legend("Measured Values", "Gaussian Fit", "Measured Mean", "Mold Dimension");

    figure(2);
    hold on;
    histogram(thickWidths,10, 'Normalization','probability');

    x = 35:.2:65;
    [gaussianT, meanthick] = getGaussianFit(thickWidths, x);
    disp(["Thick Mean " num2str(meanthick)]);
    plot(x,gaussianT, 'g')
    
    plot([mean(thickWidths),mean(thickWidths)], [0,1], 'g');
    plot([50,50], [0,1], 'k');
    axis([35, 65 , 0, .5])
    
    
    xlabel('w2 (um)');
    ylabel('Normalized Occurance')
    improvePlot();
    legend("Measured Values", "Gaussian Fit", "Measured Mean", "Mold Dimension");

    %run t-test
    [h,p, ~, stats] = ttest(thickWidths, 50)
    
    


%% figure that compares fibrin d0 3/3/2026 to the gelma 11-9-3 data
fibrinwidths = [88.043, 42.297, 112.331, 266.731, 85.493];

figure; 


hold on; 
edges = 0:2:300;
histogram(fibrinwidths, edges, 'Normalization','percentage')

histogram(thinWidths, edges, 'Normalization','percentage')
dx = 200;
[y, x] = kde(fibrinwidths);
plot(x,y*dx)
[y, x] = kde(thinWidths);
plot(x,y*dx)
plot([10,10], [0,35], 'k');
legend('Fibrin','GelMA', 'Fibrin KDE', 'GelMa KDE', 'Mold Dimension')

xlabel('w1 (\mum)')
ylabel('Percent ()')

improvePlot()



%% 



%%

    function [imageStack] = makeImageStack(reader, channel)

    imageStack = zeros(reader.width, reader.height, reader.sizeZ); 

    for z = 1:reader.sizeZ
    
        imageStack(:,:,z) = getPlane(reader, z, channel, 1);
    
    end


    end

    function [filteredStack] = filterTheStack(imageStack, reader)

    filteredStack = zeros(reader.width, reader.height, reader.sizeZ); 

    for z = 1:reader.sizeZ
    
        J = imageStack(:,:,z);
        %Filter the image
        J_filt = J; imgaussfilt(J, 1);
        %J_filt = J;
        figure(3)
        imshow(J_filt)
        J_filt = mat2gray(J_filt);
        T = adaptthresh(J_filt, .6);
        J_filt = imbinarize(J_filt, .35);
    

        filteredStack(:,:,z) = J_filt;

        
    
    end

    end


    %% functions

    function [gaussianF, meanD] = getGaussianFit(data, xindx)

        meanD= mean(data);
        stdD = std(data);

        gaussianF = normpdf(xindx, meanD, stdD);

    end