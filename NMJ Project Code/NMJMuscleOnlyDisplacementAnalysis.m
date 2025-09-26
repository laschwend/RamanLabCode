%Author: Laura Schwendeman
%Date: 8/26/2025
%Purpose: To Organize Figure data for figure 3 of NMJ paper (namely analyze
%the displacement data)

close all; 
clear all; 

%list all of the directories to pull from and organize the conditions
OptoPath = 0;
RGECOPath = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\NMJ Muscle Only Experiments\RGECO R1";
WTPath = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\NMJ Muscle Only Experiments\WT R2";

OptoNameTemplate = 0;
RGECONameTemplate = "\Converted_Videos\10x_RGECO_10vpp_5vdcoffset_5duty_1hz_";
WTNameTemplate = "\Converted_Videos\10x_WTR2_10vpp_5vdcoffset_5duty_1hz_";

OptoIDs = 0;
RGECOIDs = {"B3", "B4", "B5", "C3", "C4", "C5"};
WTIDs = {"B2", "B3-02", "B4", "C2-02", "C3", "C4"};

endingString = "_0.0-5.0sec";


datatxtname = "\results\MAD_timeseries.txt";

% pixel to um conversion factor
px2um = 1/1137.686*1000; %um/px


%naming conventions for data
Conditions = {"RGECO", "WTR2"};

%some flip factors to invert the upsidedown data
WTFlip = [1,0,0,0,0,1];
RGECOFlip = [0,0,0,0,0,0];

%% generate all the file locations and the datastructure

%RGECO setup
RGecoData = initializeDataStruct(Conditions{1}, RGECOPath, RGECONameTemplate, RGECOIDs, endingString, datatxtname, px2um, RGECOFlip);
makeDisplacementPlots(RGecoData);

RGecoData = getMaxDisp(RGecoData);

%WT setup
WTData = initializeDataStruct(Conditions{2}, WTPath, WTNameTemplate, WTIDs, endingString, datatxtname, px2um, WTFlip);
makeDisplacementPlots(WTData);

WTData = getMaxDisp(WTData);


%% Plot Summary Displacement Data
figure(); 

%get all the averages
RGecoMad = getAllAverageMADMaxs(RGecoData);
WTMad = getAllAverageMADMaxs(WTData);

%plot the bars
h = bar(["RGECO", "WT"], [mean(RGecoMad), mean(WTMad)]);
hold on; 
scatter(repmat(h(1).XEndPoints(1), length(RGecoMad), 1), RGecoMad);
scatter(repmat(h(1).XEndPoints(2), length(WTMad), 1), WTMad);
xlabel("Cell Type");
ylabel("MADMax Displacement (um)");


%% save data to an excel sheet

makeExcelSheet(WTData, RGecoData, "MuscleData9_23_25.xlsx")


%% functions
function [datastruct] = initializeDataStruct(conditionName, Path, NameTemplate, reps, endingString, dataTxtString, px2um, flip)

    datastruct = {};

    for i = 1:length(reps)
        replicate.condition = conditionName + " " + reps{i}; 
        replicate.fileName = Path + NameTemplate + reps{i} + endingString; 
        if flip(i)
            displacement = getMADStringData(replicate.fileName +dataTxtString)*px2um; 
            displacement = displacement*-1 + max(displacement);
            replicate.MADdisplacement = displacement;
        else
        replicate.MADdisplacement = getMADStringData(replicate.fileName +dataTxtString)*px2um;
        end
        datastruct{i} = replicate; 
    end

end

function [madDisplacementString] = getMADStringData(filename)
    madDisplacementString = importdata(filename);
end

function [peaksLoc, valleysLoc] = getpeaksNvalleys(MADDisp)
    
    [~, peaksLoc] = findpeaks(MADDisp, "MinPeakDistance", 25);
    [~,valleysLoc] = findpeaks(-MADDisp, "MinPeakDistance", 25);
 

end


function [MADMaxs, averageMADMax] = getAverageDisplacement(MADDisp, peaksLoc, valleysLoc)

    peaks = MADDisp(peaksLoc);
    MADMaxs = [];
    for p = 1:length(peaksLoc)
        
        pL = peaksLoc(p);
        vL = find(valleysLoc - pL > 0, 1);

        if isempty(vL)

            vL = length(valleysLoc);
        end

        vL = MADDisp(valleysLoc(vL)); 
        pLl = MADDisp(pL);

        MADMaxs(end+1) = pLl-vL;
       

    end

    averageMADMax = mean(MADMaxs);

end


function [] = plotDisplacementAndPeakLocations(subplotNum, subplotDim, struct, peakLoc, valleyLoc)
    
    subplot(subplotDim(1), subplotDim(2), subplotNum);
    hold on; 
    plot(struct.MADdisplacement)
    plot(peakLoc, struct.MADdisplacement(peakLoc), 'or');
    plot(valleyLoc, struct.MADdisplacement(valleyLoc), 'ob');
    title(struct.condition);
    xlabel("frame")
    ylabel("Displacement (um)")
    
    
end

function [] = makeDisplacementPlots(datastruct)

nFiguresCol = ceil(sqrt(length(datastruct))); 
nFiguresRow = ceil(length(datastruct)/nFiguresCol);

subplotDim = [nFiguresRow nFiguresCol];

figure; 

for i = 1:length(datastruct)

    rep = datastruct{i}; 

    [pL, vL] = getpeaksNvalleys(rep.MADdisplacement);

    plotDisplacementAndPeakLocations(i, subplotDim, rep, pL, vL);


end

end

%that moment when I really should have made a class object for this, 
%but this gets the time to peak and relaxation time too
function [updatedData] = getMaxDisp(datastruct)

    for i = 1:length(datastruct)

    rep = datastruct{i}; 

    [pL, vL] = getpeaksNvalleys(rep.MADdisplacement);

    
    [a, rep.AveMax] =  getAverageDisplacement(rep.MADdisplacement, pL, vL);
    [rep.time2Peak, rep.relaxTime, rep.timeAtPeak] = getTimes(pL, vL, rep.MADdisplacement); 

    updatedData{i} = rep; 

end

end

function [time2Peak, relaxTime, timeAtPeak] = getTimes(pL, vL, disp)

    %get time to peak
    time2Peak = [];
    for valleyIndx = 1:length(vL)
        valleyPt = vL(valleyIndx); 

        if any(valleyPt<pL)
            peakPt = pL(valleyPt<pL);
            peakPt = peakPt(1);
            bins = peakPt-valleyPt
            time2Peak = [time2Peak, bins];
        end
    end

    %get time to relax
    relaxTime = [];

    for peakIndx = 1:length(pL)
        peakPt = pL(peakIndx); 

        if any(peakPt<vL)
            valleyPt = vL(peakPt<vL);
            valleyPt = valleyPt(1);
            bins = -peakPt+valleyPt
            relaxTime = [relaxTime, bins];
        end
    end

    %get time at peak
    timeAtPeak = [];

    for peak_idx = 1:length(pL)
        threashold = .9*disp(peak_idx);
         idx_plus = find(disp(peak_idx:end) >= threashold, 1, 'first') + peak_idx + 1;
        idx_minus = find(disp(1:peak_idx) <= threashold, 1, 'last');

        timeAtPeak = [timeAtPeak, idx_plus - idx_minus];

    end

end

function [allAverages] = getAllAverageMADMaxs(datastruct)
    allAverages = [];

    for i = 1:length(datastruct)
        
        allAverages = [allAverages datastruct{i}.AveMax];     

    end
    
end

function [] = makeExcelSheet(WTData, RgecoData, excelName)

    %first make a table with all the displacement data
    numWT = size(WTData,2); 
    numRgeco = size(RgecoData, 2);

    lenMAD = length(WTData{1}.MADdisplacement);
    lenMAD2 = length(RgecoData{1}.MADdisplacement);

    MadDisp = cell(1,numWT+numRgeco);
    AveMADMax = cell(1,numWT + numRgeco+1);
    AveMADMax{2,1} = "AveMADMax";
    AveMADMax{3,1} = "BinToPeak";
    AveMADMax{4,1} = "BinToRelax";
    AveMADMax{5,1} = "TimeAtPeak90";

    %do WT first
    for i = 1:numWT
        MadDisp{1, i} = WTData{i}.condition;
        AveMADMax{1,i+1} = WTData{i}.condition;
        
        for j = 1:lenMAD
           MadDisp{1+j,i} = WTData{i}.MADdisplacement(j);
        end
        AveMADMax{2,i+1} = (WTData{i}.AveMax); 
        AveMADMax{3,i+1} = mean(WTData{i}.time2Peak);
        AveMADMax{4,i+1} = mean(WTData{i}.relaxTime); 
        AveMADMax{5,i+1} = mean(WTData{i}.timeAtPeak); 

    end

    %then get Rgeco
    for r = 1:numRgeco
        lenMAD2 = length(RgecoData{r}.MADdisplacement);
        MadDisp{1, i+r} = RgecoData{r}.condition;
        AveMADMax{1,r+i+1} = RgecoData{r}.condition;
        for k = 1:lenMAD2
           MadDisp{1+k,i+r} = RgecoData{r}.MADdisplacement(k);
        end
        AveMADMax{2,r+i+1} = RgecoData{r}.AveMax;
        AveMADMax{3,r+i+1} = mean(RgecoData{r}.time2Peak); 
         AveMADMax{4,r+i+1} = mean(RgecoData{r}.relaxTime);
         AveMADMax{5,r+i+1} = mean(RgecoData{r}.timeAtPeak);
    end

    %then put it in an excel sheet
    sheetStr = 'Sheet1';
    writecell(MadDisp, excelName, 'Sheet', sheetStr, 'Range', 'A1');
    sheetStr = 'Sheet2';
    writecell(AveMADMax, excelName, 'Sheet', sheetStr, 'Range', 'A1');


end