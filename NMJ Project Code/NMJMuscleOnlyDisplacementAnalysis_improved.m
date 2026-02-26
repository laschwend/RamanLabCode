%Author: Laura Schwendeman
%Date: 2/17/2026
%Purpose: To Organize Figure data for figure 3 of NMJ paper (namely analyze
%the displacement data) - adapted code that can handle an arbitrary number
%of conditions instead of just wt and rgeco

close all; 
clear all; 
%% all the analysis 2/20/26
%list all of the directories to pull from and organize the conditions
RGECOPath = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\NMJ Muscle Only Experiments\RGECO R1";
WTPath = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\NMJ Muscle Only Experiments\WT R2";
SponEstimPath = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\2_12_26 Muscle Only Estim and Spontaneous vids\Converted_Videos\";
ChemPath = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\2_16_26ChemStim\Converted_Videos\";
Paths = {RGECOPath, WTPath, SponEstimPath, SponEstimPath,SponEstimPath,SponEstimPath, ChemPath, SponEstimPath, ChemPath, SponEstimPath,ChemPath...
    ChemPath, ChemPath, ChemPath};

RGECOName = "\Converted_Videos\10x_RGECO_10vpp_5vdcoffset_5duty_1hz_";
WTName = "\Converted_Videos\10x_WTR2_10vpp_5vdcoffset_5duty_1hz_";
RGECOR3Name = "10x_D14_RGECO_R3_";
WTR4Name = "10x_D14_WT_R4_";
WTR4NDMName = "10x_D14_WT_R4NDM_";
RGECOChem30Name = "RGECO_T30_glut_";
RGECOChem0Name = "RGECO_T0_glut_";
WTChem30Name = "WT_T30_glut_";
WTChem0Name = "WT_T0_glut_";
WTNChem30Name = "WT_NDM_T30_glut_";
WTNChem0Name = "WT_NDM_T0_glut_";

NamesTemplate = {RGECOName,...
    WTName,...
    RGECOR3Name, ...
    WTR4Name, ...
    WTR4NDMName, ...
    RGECOR3Name, ...
    RGECOChem30Name, ...
    WTR4Name, ...
    WTChem30Name, ...
    WTR4NDMName, ...
    WTNChem30Name, ...
    RGECOChem0Name, WTChem0Name, WTNChem0Name};

RGECOIDs = {"B3", "B4", "B5", "C3", "C4", "C5"};
WTIDs = {"B2", "B3-02", "B4", "C2-02", "C3", "C4"};
RGECOR3IDs = {"p1_B5_10Vpp_5Vdc_1hz_5duty-02",...
    "p1_C2_10Vpp_5Vdc_1hz_5duty-02", "p1_C3_10Vpp_5Vdc_1hz_5duty-02",...
    "p1_C4_10Vpp_5Vdc_1hz_5duty-02", "p1_C5_10Vpp_5Vdc_1hz_5duty-02"};
WTR4IDs = {"p2_B2_10Vpp_5Vdc_1hz_5duty",...
    "p2_B3_10Vpp_5Vdc_1hz_5duty", "p2_B4_10Vpp_5Vdc_1hz_5duty",...
    "p2_B5_10Vpp_5Vdc_1hz_5duty", "p2_C2_10Vpp_5Vdc_1hz_5duty"};
WTR4NDMIDs = {"p1_B2_10Vpp_5Vdc_1hz_5duty",...
    "p1_B4_10Vpp_5Vdc_1hz_5duty-02", "p2_C5_10Vpp_5Vdc_1hz_5duty",...
    "p2_C4_10Vpp_5Vdc_1hz_5duty", "p2_C3_10Vpp_5Vdc_1hz_5duty"};
RGECOSponIDs = {"p1_B5_spon",...
    "p1_C3_spon", "p1_C3_spon",...
    "p1_C4_spon", "p1_C5_spon"};
WTR4SponIDs = {"p2_B2_spon",...
    "p2_B3_spon", "p2_B4_spon",...
    "p2_B5_spon", "p2_C2_spon"};
WTR4NDMSponIDs = {"p1_B2_spon",...
    "p1_B4_spon", "p2_C5_spon",...
    "p2_C4_spon", "p2_C3_spon"};
ChemIds = {"001", "002", "003", "004", "005"};
RChemIds = {"002", "003", "004", "005"};

IDs = {RGECOIDs, WTIDs, RGECOR3IDs, WTR4IDs, WTR4NDMIDs,...
    RGECOSponIDs, RChemIds, WTR4SponIDs, RChemIds, WTR4NDMSponIDs, ChemIds, ...
    RChemIds, RChemIds, ChemIds};

endingString = "_0.0-5.0sec";

datatxtname = "\results\MAD_timeseries.txt";

% pixel to um conversion factor
px2um = 1/1137.686*1000; %um/px


%naming conventions for data
Conditions = {"RGECO", "WTR2", "RGECOR3", "WTR4", "WTR4NDM", "RGECOR3spon", "RGECOR3chem30", "WTR4spon", "WTR4chem30", "WTR4NDMspon", "WTR4NDMchem30", ...
    "RGECOChem0", "WTChem0", "WTNDMChem0"};

%some flip factors to invert the upsidedown data
WTFlip = [0,0,0,0,0,0];
RGECOFlip = [1,0,0,0,0,1];
RGECOR3Flip = [0,1,0,0,0,0];
WTR4Flip = [0,0,0,0,0,1];
WTR4NDMFlip = [0,0,0,0,0,0];
RGECOR3SponFlip = [0,0,0,0,0,0];
WTR4SponFlip = [0,0,0,0,0,0];
WTR4NDMSponFlip = [0,0,0,0,0,0];
RGECOR3C0Flip = [0,0,0,0,0];
WTR4C0Flip = [0,0,0,0,0,0];
WTR4NDMC0Flip = [0,0,0,0,0,0];
RGECOR3C30Flip = [0,0,0,0,0];
WTR4C30Flip = [0,0,1,0,0,0];
WTR4NDMC30Flip = [0,0,0,0,0,0];

FlipFactors = {WTFlip, RGECOFlip, RGECOR3Flip, WTR4Flip, WTR4NDMFlip,...
    RGECOR3SponFlip,RGECOR3C30Flip, WTR4SponFlip,WTR4C30Flip, WTR4NDMSponFlip, WTR4NDMC30Flip, ...
    RGECOR3C0Flip, WTR4C0Flip, WTR4NDMC0Flip};

 %% Partial Analysis
% %list all of the directories to pull from and organize the conditions
% RGECOPath = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\NMJ Muscle Only Experiments\RGECO R1";
% WTPath = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\NMJ Muscle Only Experiments\WT R2";
% SponEstimPath = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\2_12_26 Muscle Only Estim and Spontaneous vids\Converted_Videos\";
% ChemPath = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\2_16_26ChemStim\Converted_Videos\";
% Paths = {RGECOPath, WTPath, SponEstimPath, SponEstimPath,SponEstimPath,SponEstimPath, SponEstimPath SponEstimPath};
% 
% RGECOName = "\Converted_Videos\10x_RGECO_10vpp_5vdcoffset_5duty_1hz_";
% WTName = "\Converted_Videos\10x_WTR2_10vpp_5vdcoffset_5duty_1hz_";
% RGECOR3Name = "10x_D14_RGECO_R3_";
% WTR4Name = "10x_D14_WT_R4_";
% WTR4NDMName = "10x_D14_WT_R4NDM_";
% RGECOChem30Name = "RGECO_T30_glut_";
% RGECOChem0Name = "RGECO_T0_glut_";
% WTChem30Name = "WT_T30_glut_";
% WTChem0Name = "WT_T0_glut_";
% WTNChem30Name = "WT_NDM_T30_glut_";
% WTNChem0Name = "WT_NDM_T0_glut_";
% 
% NamesTemplate = {RGECOName,...
%     WTName,...
%     RGECOR3Name, ...
%     WTR4Name, ...
%     WTR4NDMName, ...
%     RGECOR3Name, ...
%     WTR4Name, ...
%     WTR4NDMName, ...
%     };
% 
% RGECOIDs = {"B3", "B4", "B5", "C3", "C4", "C5"};
% WTIDs = {"B2", "B3-02", "B4", "C2-02", "C3", "C4"};
% RGECOR3IDs = {"p1_B5_10Vpp_5Vdc_1hz_5duty-02",...
%     "p1_C3_10Vpp_5Vdc_1hz_5duty-02", "p1_C3_10Vpp_5Vdc_1hz_5duty-02",...
%     "p1_C4_10Vpp_5Vdc_1hz_5duty-02", "p1_C5_10Vpp_5Vdc_1hz_5duty-02"};
% WTR4IDs = {"p2_B2_10Vpp_5Vdc_1hz_5duty",...
%     "p2_B3_10Vpp_5Vdc_1hz_5duty", "p2_B4_10Vpp_5Vdc_1hz_5duty",...
%     "p2_B5_10Vpp_5Vdc_1hz_5duty", "p2_C2_10Vpp_5Vdc_1hz_5duty"};
% WTR4NDMIDs = {"p1_B2_10Vpp_5Vdc_1hz_5duty",...
%     "p1_B4_10Vpp_5Vdc_1hz_5duty-02", "p2_C5_10Vpp_5Vdc_1hz_5duty",...
%     "p2_C4_10Vpp_5Vdc_1hz_5duty", "p2_C3_10Vpp_5Vdc_1hz_5duty"};
% RGECOSponIDs = {"p1_B5_spon",...
%     "p1_C3_spon", "p1_C3_spon",...
%     "p1_C4_spon", "p1_C5_spon"};
% WTR4SponIDs = {...
%     "p2_B3_spon", "p2_B4_spon",...
%     "p2_B5_spon"};
% WTR4NDMSponIDs = {"p1_B2_spon",...
%     "p1_B4_spon", "p2_C5_spon",...
%     "p2_C4_spon", "p2_C3_spon"};
% ChemIds = {"001", "002", "003", "004", "005"};
% RChemIds = {"002", "003", "004", "005"};
% 
% IDs = {RGECOIDs, WTIDs, RGECOR3IDs, WTR4IDs, WTR4NDMIDs,...
%     RGECOSponIDs, WTR4SponIDs, WTR4NDMSponIDs};
% 
% endingString = "_0.0-5.0sec";
% 
% datatxtname = "\results\MAD_timeseries.txt";
% 
% % pixel to um conversion factor
% px2um = 1/1137.686*1000; %um/px
% 
% 
% %naming conventions for data
% Conditions = {"RGECO", "WTR2", "RGECOR3", "WTR4", "WTR4NDM", "RGECOR3spon", "WTR4spon" "WTR4NDMspon"};
% 
% %some flip factors to invert the upsidedown data
% WTFlip = [1,0,0,0,0,1];
% RGECOFlip = [0,0,0,0,0,0];
% RGECOR3Flip = [0,0,0,0,0,0];
% WTR4Flip = [0,0,0,0,1,0];
% WTR4NDMFlip = [0,0,0,0,0,0];
% RGECOR3SponFlip = [0,0,0,0,0,0];
% WTR4SponFlip = [0,0,0,0,0,0];
% WTR4NDMSponFlip = [0,0,0,0,0,0];
% RGECOR3C0Flip = [0,0,0,0,0];
% WTR4C0Flip = [0,0,0,0,0,0];
% WTR4NDMC0Flip = [0,0,0,0,0,0];
% RGECOR3C30Flip = [0,0,0,0,0];
% WTR4C30Flip = [0,0,0,0,0,0];
% WTR4NDMC30Flip = [0,0,0,0,0,0];
% 
% FlipFactors = {WTFlip, RGECOFlip, RGECOR3Flip, WTR4Flip, WTR4NDMFlip,...
%     RGECOR3SponFlip, WTR4SponFlip, WTR4NDMSponFlip};
% 

%% generate all the file locations and the datastructure
DataStructs = {};

for i = 1:length(Conditions)
    %initialize the datastructure
    Data = initializeDataStruct(Conditions{i}, Paths{i}, NamesTemplate{i}, IDs{i}, endingString, datatxtname, px2um, FlipFactors{i});
    makeDisplacementPlots(Data);
    Data = getMaxDisp(Data);
    DataStructs{i} = Data;

end

%now plot summary values
meanVals = zeros(length(Conditions), 1);
for i = 1:length(DataStructs)
    meanVals(i) = mean(getAllAverageMADMaxs(DataStructs{i})); 
end
figure(); 
h = bar(string(Conditions), meanVals);
hold on; 
for i = 1:length(Conditions)
    MadVals = getAllAverageMADMaxs(DataStructs{i}); 
    scatter(repmat(h(1).XEndPoints(i), length(MadVals), 1), MadVals);
end
xlabel("Cell Type");
ylabel("MADMax Displacement (um)");

%% save data to an excel sheet

makeExcelSheet(DataStructs, "MuscleData2_22_2026.xlsx")


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

function [] = makeExcelSheet(DataStructs, excelName)

    %initialize summary tables
    MadDisp = {};
    AveMADMax = cell(1,5);
    AveMADMax{2,1} = "AveMADMax";
    AveMADMax{3,1} = "BinToPeak";
    AveMADMax{4,1} = "BinToRelax";
    AveMADMax{5,1} = "BinAtPeak90";

    count = 0; 
    for cond = 1:length(DataStructs)
    %first make a table with all the displacement data
    data = DataStructs{cond};
    numReps = length(DataStructs{cond});

        %populate data from every replicate into large tables for the excel
        %sheet
        c_last = count;
        for i = 1:numReps
            lenMAD = length(data{i}.MADdisplacement);
            numReps = length(data{i}.time2Peak);
            MadDisp{1, c_last+i} = data{i}.condition;
            AveMADMax{1,c_last+i+1} = data{i}.condition;
            
             
            for j = 1:lenMAD
               MadDisp{1+j,c_last+i} = data{i}.MADdisplacement(j);
            end
    
            AveMADMax{2,c_last+ i+1} = (data{i}.AveMax); 
            AveMADMax{3,c_last+i+1} = mean(data{i}.time2Peak);
            AveMADMax{4,c_last+i+1} = mean(data{i}.relaxTime); 
            AveMADMax{5,c_last+i+1} = mean(data{i}.timeAtPeak); 
            count = count +1;
        end
    end


    %then put it in an excel sheet
    sheetStr = 'Sheet1';
    writecell(MadDisp, excelName, 'Sheet', sheetStr, 'Range', 'A1');
    sheetStr = 'Sheet2';
    writecell(AveMADMax, excelName, 'Sheet', sheetStr, 'Range', 'A1');


end