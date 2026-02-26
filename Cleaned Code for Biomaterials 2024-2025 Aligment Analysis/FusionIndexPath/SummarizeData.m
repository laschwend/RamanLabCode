%code for processing all the collected fiber data and putting it into
%spreadsheets that are easier to make plots with in python, note that
%nucleiIdentificationAndFusionIndexCode.m and 
%Author: Laura Schwendeman
%Date: 6/26/2024
clear all; close all; clc;

%load the data you want to look at, human or c2c12
%load("fiberdataH2_1 - Copy.mat");
C2C12 = 0; 

% if C2C12
%     load("fiberdataM2_1 - Copy.mat");
%     replicateDict = dictionary(["12pt5", "25", "125", "flat", "unstamped"], [7,5,5,8,8]);
% else
%    %load the data you want to look at, human or c2c12
%     load("fiberdataH2_1 - Copy.mat");
%     replicateDict = dictionary(["12pt5", "25", "125", "flat", "unstamped"], [8,9,5,6,8]);
% end

load("FiberData-NMJMuscleOnly2-WidthsCopy.mat")
replicateDict = dictionary(["RGECO_R3", "WT_R4", "WT_R4NDM"], [5,5,5]);
numConditions = size(FiberDataStruct,1); 
numReps = size(FiberDataStruct, 2);


ConditionsLabel = ( ["RGECO_R3", "WT_R4", "WT_R4NDM"]);
%ConditionsLabel = (["12pt5", "25", "125", "flat", "unstamped"]);


%% plot the average nuclei count/fiber

%   names = [];
%   nucleiCount = [];
%   fusionIndexval = [];
%   i = 1;
% for conditionNum = 1:numConditions
%     for rep = 1:numReps
% 
%      if ~isempty(FiberDataStruct{conditionNum, rep})
%       FiberImageData = FiberDataStruct{conditionNum, rep};
%       nucleiCount = [nucleiCount, mean(FiberImageData.fiberNucleiCounts)]
%       names = [names; (num2str(conditionNum) + "_rep" + num2str(rep))]
%       fusionIndexval = [fusionIndexval, FiberImageData.fusionIndex]
%      end
% 
% 
%     end
% end
% 
%   figure(1);
% bar(["12.5_1", "12.5_2","12.5_3", "25_1", "25_2", "25_3", "62.5_1", "62.5_2","62.5_3", "125_1", "125_2", "125_3", "flat_1", "flat_2", "flat_3", "unstamped_1", "unstamped_2", "unstamped_3"], nucleiCount);
% 
% title("Average Nuclei Per Fiber")
% ylabel("number of nuclei")
% 
%  figure(2);
% bar(["12.5_1", "12.5_2","12.5_3", "25_1", "25_2", "25_3", "62.5_1", "62.5_2","62.5_3", "125_1", "125_2", "125_3", "flat_1", "flat_2", "flat_3", "unstamped_1", "unstamped_2", "unstamped_3"], fusionIndexval);
% 
% title("Fusion index (Nuclei In Fibers vs Total Nuclei Count)")
% ylabel("Fusion Index ")


%% Make the excel sheets and store summary data

%open the excel workbook - need to pre-generate this, open and name an
%excel workbook and save it and then write the path down here
if C2C12
    fileNameExcel = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\1_3_2025 Sonikas Stamp Analysis Copy\Stamp data analysis\C2C12 40x\C2C12_Data_Summarized.xlsx";
else
    fileNameExcel = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\1_3_2025 Sonikas Stamp Analysis Copy\Stamp data analysis\Cook 40x\Cook_Data_Summarized.xlsx";
end

fileNameExcel = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\2_13_24 Fliped 40x Muscle only experiment confocal\FusionIndexData.xlsx";

%for naming each condition and replicate
Conditions = {"12.5", "25", "125", "flat", "unstamped"};
Conditions = {"RGECO_R3", "WT_R4", "WT_R4NDM"};

FusionData = {"FusionIndex", "StampCondition", "Replicate", "Category"};

FiberNucleiCountData = {"NumberOfNuclei", "StampCondition", "Replicate", "Category"};

AverageWidthperFiber = {"AverageWidthperFiber", "StampCondition", "Replicate", "Category"};

AverageWidthperReplicate = {"AverageWidth", "StampCondition", "Replicate", "Category"};

AverageCountperReplicate = {"AverageCount", "StampCondition", "Replicate", "Category"};

AverageCircReplicate = {"AverageCircularity", "StampCondition", "Replicate", "Category"};

ConditionMap = {"grooved","grooved","grooved", "ungrooved", "ungrooved"};

    %loop through all the objects and get the fusion Index and put it in a
    %cell of the spreadsheet
    count = 2;
    FiberCount = 2; 
 for conditionNum = 1:numConditions
     numReps = replicateDict(ConditionsLabel{conditionNum});
    for rep = 1:numReps
        %get the fusion index
        FiberImageData = FiberDataStruct{conditionNum, rep};
        FusionData{count, 1} = FiberImageData.fusionIndex;
        FusionData{count, 2} = Conditions{conditionNum};
        FusionData{count, 3} = rep;
        FusionData{count, 4} = ConditionMap{conditionNum};

        
        FiberMeanWidths = [];
        FiberCounts = [];
        %loop through each fiber to store nuclei per fiber info
        for fiber = 1:length(FiberImageData.fiberWidths)

            %get the number of nuclei per fiber
            FiberNucleiCountData{FiberCount, 1} = FiberImageData.fiberNucleiCounts(fiber); 
            FiberNucleiCountData{FiberCount, 2} = Conditions{conditionNum};
            FiberNucleiCountData{FiberCount, 3} = rep;
            FiberNucleiCountData{FiberCount, 4} = ConditionMap{conditionNum};
          
            %get the mean fiber width of the fiber
            FiberMeanWidths = [FiberMeanWidths mean(FiberImageData.fiberWidths{fiber})];
            %for averaging, store the fiber nuclei coutn
            FiberCounts = [FiberCounts FiberImageData.fiberNucleiCounts(fiber)];

            %get the average width of each fiber in the image
            AverageWidthperFiber{FiberCount, 1} = mean(FiberImageData.fiberWidths{fiber});
            AverageWidthperFiber{FiberCount, 2} = Conditions{conditionNum};
            AverageWidthperFiber{FiberCount, 3} = rep;
            AverageWidthperFiber{FiberCount, 4} = ConditionMap{conditionNum};

            FiberCount = FiberCount + 1;
        end


        %Get the over all average width calculated in the picture
        AverageWidthperReplicate{count, 1} = mean(FiberMeanWidths);
        AverageWidthperReplicate{count, 2} = Conditions{conditionNum};
        AverageWidthperReplicate{count, 3} = rep;
        AverageWidthperReplicate{count, 4} = ConditionMap{conditionNum};

        %Get the over all average number of nuclei per fiber
        AverageCountperReplicate{count, 1} = mean(FiberCounts);
        AverageCountperReplicate{count, 2} = Conditions{conditionNum};
        AverageCountperReplicate{count, 3} = rep;
        AverageCountperReplicate{count, 4} = ConditionMap{conditionNum};

        %get the mean circularity of the nuclei in the image
        AverageCircReplicate{count, 1} = mean(FiberImageData.NucleiCircularity);
        AverageCircReplicate{count, 2} = Conditions{conditionNum};
        AverageCircReplicate{count, 3} = rep;
        AverageCircReplicate{count, 4} = ConditionMap{conditionNum};

        count = count +1;

    end
 end

 %% save all the info into the spreadsheet 
 
 %sheet 1: Fusion Index
sheetStr = 'Sheet1';
writecell(FusionData, fileNameExcel, 'Sheet', sheetStr, 'Range', 'A1')

%sheet 2: nuclei per fiber
sheetStr = 'Sheet2';
writecell(FiberNucleiCountData, fileNameExcel, 'Sheet', sheetStr, 'Range', 'A1')

%sheet 3: fiber width measures per fiber
sheetStr = 'Sheet3';
writecell(AverageWidthperFiber, fileNameExcel, 'Sheet', sheetStr, 'Range', 'A1')


%sheet 4: Average Width measure per replicate
sheetStr = 'Sheet4';
writecell(AverageWidthperReplicate, fileNameExcel, 'Sheet', sheetStr, 'Range', 'A1')

%sheet 5: Average Nuclei Count measure per replicate
sheetStr = 'Sheet5';
writecell(AverageCountperReplicate, fileNameExcel, 'Sheet', sheetStr, 'Range', 'A1')

%sheet 8: Average Nuclei Circulairty measure per replicate
sheetStr = 'Sheet8';
writecell(AverageCircReplicate, fileNameExcel, 'Sheet', sheetStr, 'Range', 'A1')

%% Save all the nuclei count Figures to an excel sheet
%for getting the images: 
%dirLocation = "C:\Users\laSch\Dropbox (MIT)\Raman Lab\Laura Schwendeman\20240530 alignment 6 good IF\40x pancakes\";
%dirLocation = "C:\Users\laSch\Dropbox (MIT)\Raman Lab\Laura Schwendeman\20240603 Alignment Experiment 7 - human tc twitch\40x pancakes\"
if C2C12
    dirLocation = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\1_3_2025 Sonikas Stamp Analysis Copy\Stamp data analysis\C2C12 40x\";
else
    dirLocation = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\1_3_2025 Sonikas Stamp Analysis Copy\Stamp data analysis\Cook 40x\";
end
    conditionNames = {"12pt5", "25", "125", "flat", "unstamped"};

sheetNum = 7; 

dpi = get(groot, 'ScreenPixelsPerInch');
excel = actxserver('Excel.Application');
excel.Visible = 1;
wrkbk =  excel.Workbooks;

graphFile = wrkbk.Open(fileNameExcel);
sheet = get(graphFile.Sheets, 'Item', sheetNum);

columns = {'A', 'K', 'T', 'AA', 'AK', 'AT', 'BA', 'BK', 'BT'}; %for number of replicates

%for cell type
if C2C12
    cellType = "C2C12";
else
    cellType = "Cook";
end

%loop through each condition
for conditionNum = 1:numConditions
    numReps = replicateDict(ConditionsLabel{conditionNum});
    for rep = 1:numReps
        FiberImageData = FiberDataStruct{conditionNum, rep};
        labels = FiberImageData.nucleiLabels;
        %fileNameN = dirLocation +  conditionNames{conditionNum} +"_rep" + num2str(rep) + "_40x_pancake_nuclei.tif";
        fileNameN = dirLocation + cellType + "_40x_" + conditionNames{conditionNum} +"_rep" + num2str(rep) + "_nuclei.tif";
        imageN = imread(fileNameN);
        imageN = im2gray(imageN);

        figTitle = Conditions{conditionNum} + "_" + num2str(rep);
        
        fig = plotNucleiFig(labels, figTitle,  imageN);

        %now put the figure in the excel sheet
         insertFig(sheet, fig, conditionNum*40, char(columns{rep}),dpi);
        close(fig);

    end
end







% Save all the segmented figures to an excel sheet
sheetNum = 6; 
sheet = get(graphFile.Sheets, 'Item', sheetNum);

for conditionNum = 1:numConditions
    numReps = replicateDict(ConditionsLabel{conditionNum});
    for rep = 1:numReps
        FiberImageData = FiberDataStruct{conditionNum, rep};
        labels = FiberImageData.nucleiLabels;
        %fileNameN = dirLocation +  conditionNames{conditionNum} +"_rep" + num2str(rep) + "_40x_pancake_nuclei.jpg";
        imageN = FiberImageData.muscleLabels; 
        colormap = [1 0 0; repmat([1 0 0], max(imageN, [],'all'), 1)];
        imageN = label2rgb(imageN, colormap);

        figTitle = Conditions{conditionNum} + "_" + num2str(rep);
        
        fig = plotNucleiFig(labels, figTitle,  imageN);

        %now put the figure in the excel sheet
         insertFig(sheet, fig, conditionNum*40, char(columns{rep}),dpi);
        close(fig);

    end
end

%% now closing everything
wrkbk.Close();                 % Close workbook
excel.Quit();                  % Quit server
excel.delete();



%% helpful functions

%for putting a figure in an excel sheet
function [] = insertFig(sheet, figure, row, column, dpi)

   print(figure, sprintf('-r%d', dpi), '-clipboard', '-dbitmap');     %   to the clipboard as a bitmap
   sheet.Range([column num2str(row)]).PasteSpecial();

end

%for displaying the nuclei segmentation figure
function [fig] = plotNucleiFig(nucleiLabels, figTitle, originalImage)
    
    fig = figure(1); 
    imshow(labeloverlay(originalImage,nucleiLabels))
    title(figTitle);

end
