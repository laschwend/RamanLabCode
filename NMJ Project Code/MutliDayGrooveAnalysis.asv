%Author: Laura Schwendeman 
%Date: 9/25/2025
%Purpose: To process and plot groove dimensions over time and collect
%dimensions using the grooveData class object

close all; clear all; 

% %practice: 
% 
% filefolder  = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\NMJ Paper Figure Resources\Fig 2\Longevity Study 9_18_25 Segmented Images";
% filename = "SAM - NMJ Gels 9_18_25 D1 Grooves YZ 582.png";
% %filename = "NMJ Gels 9_18_25 D1 Grooves YZ 582.png";
% 
% pixelSize = 79.41/92; %um
% pixelSize = 883.88/1024;%um
% 
% SAMD1 = GrooveImage(filefolder, filename, pixelSize, .95, 40, 5, -40, 100);
% 
% SAMD1.plotResults()




%% Code Declarations
saveName = 'NMJGrooveAnalysis9_25_25.mat';
excelName = 'NMJGrooveAnalysis9_25_25.csv'

%file path notes
DropboxPath = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\NMJ Paper Figure Resources\Fig 2\Longevity Study 9_18_25 Segmented Images\";

fileNames = {"20x_#7_C1_region1_denoised - 512_D1_SAM.png", "20x_#7_C1_region2_denoised_D1_SAM.png", "20x_#7_C1_region3_denoised_D2_SAM.png", "20x_#7_C1_region4_denoised_D6_SAM.png"};

dayLabel = {"D1", "D1", "D2", "D6"};

%peak parameters
peakDist = [40, 40, 40, 40]; 
peakHeight = [5 5 5 5];
valleyHeight = [-70 -40 -40 -70];


%Universal parameters
cutoff1 = [400, 1000, 1250, 400]; 
cutoff2 = [40, 250, 40, 40];
pixelSize = 883.88/1024;%um

%Data saving variable
Data = cell(size(fileNames));


%% now loop throught all of the pictures


summaryDatah = cell(1, 2);
summaryDatah{1,1} = "Day";
summaryDatah{1,2} = "height";

summaryDataw = cell(1, 2);
summaryDataw{1,1} = "Day";
summaryDataw{1,2} = "width";


for i = 1:length(fileNames)
    close all; 
     
    grooveStudy = GrooveImage(DropboxPath, fileNames{i}, pixelSize, .95, peakDist(i), peakHeight(i), valleyHeight(i), cutoff1(i), cutoff2(i));
    grooveStudy.plotResults(); 
    Data{i} = grooveStudy;

    heights = grooveStudy.getHeightAve();
    widths = grooveStudy.getWidthAve();

    for h = 1:length(heights)
        summaryDatah{end+1,1} = dayLabel{i};
        summaryDatah{end,2} = heights(h);
    end

    for w = 1:length(widths)
        summaryDataw{end+1,1} = dayLabel{i};
        summaryDataw{end,2} = widths(w);
    end
    

end

%save the data
save(saveName, "Data");


%save an excel with summary data

    sheetStr = 'Sheet1';
    writecell(summaryDatah, excelName, 'Sheet', sheetStr, 'Range', 'A1');
    sheetStr = 'Sheet2';
    writecell(summaryDataw, excelName, 'Sheet', sheetStr, 'Range', 'A1');


%% Make the comparison plot
close all; 
filefolder  = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\NMJ Paper Figure Resources\Fig 2\";
filename = "SAM Image1.png";


SAMGrooves = GrooveImage(filefolder, filename, pixelSize, .95, 40, 10, -10, 300, 10);

SAMGrooves.plotResults();

%% 
figure;
SAMGrooves.plotSummaryGroove(); 
pbaspect([2 1 1])
improvePlot();


