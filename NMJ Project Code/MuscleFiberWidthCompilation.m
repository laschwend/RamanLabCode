%author: Laura Schwendeman 
%date: 10/7/2025
%purpose: extract data from .csv files for muscle fiber length and compile
%it into a new spreadsheet with average and mode widths for each dataset


%setup all the file names
folder1 = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\NMJ Muscle Only Experiments\RGECO R1\RGECO 20x endpoint\";
folder2 = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\NMJ Muscle Only Experiments\WT R2\6_27_25 WTR2 confocal endpoint D14\";

names1 = {"B3", "B4", "B5", "C3", "C4", "C5"}; %needs _BF_
names2 = {"B2", "B3", "B4", "C2", "C3", "C4"};

excelSaveName = "10_7_25_BF_FiberWidthsNMJ.xlsx";

%% 
a = compileTheData(fileName, "RGECO", names1{i});

%% loop through all files

tableData = cell(1,4);
tabelData{1,1} = "Cell Type";
tableData{1,2} = "Well";
tableData{1,3} = "AverageWidth";
tableData{1,4} = "ModeWidth";

%for names1
for i = 1:length(names1)

fileName = folder1 + names1{i} + "_BF_results.csv";
a = compileTheData(fileName, "RGECO", names1{i});

    tableData{end+1, 1} = a{1,1};
    for k = 2:length(a)
        tableData{end, k} = a{1,k};
    end

end

for j = 1:length(names1)

fileName = folder2 + names2{j} + "_results.csv";
a = compileTheData(fileName, "WT", names2{j});

tableData{end+1, 1} = a{1,1};
    for o = 2:length(a)
        tableData{end, o} = a{1,o};
    end

end

tableData2 = cell2table(tableData);

% figure(); 
% bar(categorical(tableData2.tableData1), tabelData2.tableData3)
% xlabel("well")
% ylabel("average width")
% 
% figure(); 
% bar(categorical(tableData2.tableData1), tabelData2.tableData4)
% xlabel("well")
% ylabel("mode width")

%save in excel
sheetStr = "Sheet1";
writecell(tableData, excelSaveName, 'Sheet', sheetStr, 'Range', 'A1');



function [tableRow] = compileTheData(filename, tag, well)

    tableData = readtable(filename);
    tableRow{1,1} = tag; 
    tableRow{1,2} = well;

    tableRow{1,3} = mean(tableData.Length);
    tableRow{1,4} = mode(tableData.Length);
  

end

%%

