%Author: Laura Schwendeman
%Date: 9/26/25
%Purpose: Visualize and segment channel picture for figures

folderDir = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\7_25_25 leak test r1 - 11-8-345\";
fileNames = "11-8-5-LS_20X.nd2";


    file = convertStringsToChars(folderDir + fileNames);
    reader =  BioformatsImage(file);

    imageStack = makeImageStack(reader, 1);

    %Now get a filtered version of the stack
    filteredStack = filterTheStack(imageStack, reader);

    figure(1);
    imshow(~filteredStack(:,:,11));

    

    %% to save the data for the channel dimensions in an excel
    close all; 

    dataNames = {"11_8_375_leaktest_8_14_25_2.mat", "11_8_3_Channels_9_12_25_3.mat", "11_8_3_Channels_9_18_25.mat"};

    

    thinWidths = [];
    thickWidths = [];

    for i=1:length(dataNames)
        
        load(dataNames{i});

        thick = imageParam.wideChannelDimensions;
        thin = imageParam.thinChannelDimensions;
        figure(2+i); 
        bar(thin)
        if i ==1
            indx = 1:6;
        elseif i == 2
            indx = 2:3;
        elseif i ==3
            indx = [1 2 3 5];
        else
            indx = 1:length(thick);
        end

        thick = thick(indx);
        thin = thin(indx);

        %now add them to the widths 
        thinWidths = [thinWidths, thin'];
        thickWidths = [thickWidths, thick'];
  
    end
    

    figure(1);
    hold on; 
    h = histogram(thinWidths, 10, 'Normalization','probability');
    plot([10,10], [0,1], 'k');
    
    x = 0:.2:25;
    [gaussianT, meanthin] = getGaussianFit(thinWidths, x);
    disp(["Thin Mean " num2str(meanthin)]);
    plot(x,gaussianT, 'g')
    plot([mean(thinWidths),mean(thinWidths)], [0,1], 'g');

    axis([0, 25 , 0, .5])
    xlabel('w1 (um)')
    ylabel('Normalized Occurance')
    improvePlot();

    [h,p] = ttest(thinWidths, 10)

    figure(2);
    hold on;
    histogram(thickWidths,10, 'Normalization','probability');

    x = 35:.2:65;
    [gaussianT, meanthick] = getGaussianFit(thickWidths, x);
    disp(["Thick Mean " num2str(meanthick)]);
    plot(x,gaussianT, 'g')
    plot([50,50], [0,1], 'k');
    plot([mean(thickWidths),mean(thickWidths)], [0,1], 'g');
    axis([35, 65 , 0, .5])
    
    
    xlabel('w2 (um)');
    ylabel('Normalized Occurance')
    improvePlot();

    %run t-test
    [h,p] = ttest(thickWidths, 50)






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
        J_filt = imgaussfilt(J, 5);
        %J_filt = J;
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