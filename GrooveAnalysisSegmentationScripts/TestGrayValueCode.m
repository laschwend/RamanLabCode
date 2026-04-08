%Author: Laura Schwendeman
%Date: 4/8/2026
%Purpose: To calculate sum image stacks of grooves and calculate the gray
%values of the image and plot those as a surface plot to see if they might
%work for calculating groove dimensions

%% test image: 

%set folder names and locations
folderName1.Name = "C:\Users\draga\MIT Dropbox\Raman Lab\Laura Schwendeman\1_28_26 Maheera Gelma5_10 Gel Longevity Exp\";
folderName1.subfolders = {"d0"};

%set which folders to look at
folders = {folderName1};

%make a set of objects for each picture to open
fileNameData3 = {};
for folder = folders
    folderObj = folder{:};
    for subfolder = folderObj.subfolders
        name = folderObj.Name + subfolder{:}; 
        files = dir(fullfile(name, '*'));
        
        filesToKeep = filterFilesName(files, "Denoised");
        fileNameData3 = [fileNameData3, filesToKeep];

    end
end


%% open the image: 
    i = 1;

    file = fileNameData3{i};
    fileName = fullfile(file.folder, file.name);
    
    %open the .nd2 file
    reader = BioformatsImage(fileName);

    % make 3D image stack
    imageStack = zeros(reader.height, reader.width, reader.sizeZ, 3);
    Im = zeros(reader.height, reader.width, reader.sizeZ);

    for c = 1:reader.sizeC
        for z = 1:reader.sizeZ
            imageStack(:,:,z) = getPlane(reader, z, 1, 1);
            Im(:,:,z) = im2gray(imageStack(:,:,z, 1));
        end
    end
    
    imageStack(imageStack > 1000) = 0;

    %% Now sum the pixel values
    
    sumedIm = sum(Im, 3); 

    figure(1), 
    imshow(imageStack(:,:,round(end/2),1), []);

    figure(2); 
    surf(sumedIm, "edgeColor", "None");
    xlabel('x')
    ylabel('y')
    zlabel('summed intensity value');

    %% using just one slice in the middle
    figure(5), 
    imshow(imageStack(:,:,round(end/2),1), []);

    figure(4); 
    surf(imageStack(:,:,round(end/2),1), "edgeColor", "None");
    xlabel('x')
    ylabel('y')
    zlabel('slice intensity value');

    %try getting the cross section line along the middle
    mean_angle = fileNameData{1}.angle; 
    im_rotated = imrotate(imageStack(:,:,round(end/2),1), mean_angle);

    pixelSize = 883.88/1024;%um
    X = (1:size(im_rotated,1))*pixelSize;
    ZVals = im_rotated(:,round(end/2));

    figure();
    plot(X,rescale(ZVals));
    xlabel("um")
    ylabel("Florescent Value");

    %
   
     

    


%% helpful functions
function [filteredFilenames] = filterFilesName(files, subString)

    filteredFilenames = {};

    for k = 1:length(files)
    baseFileName = files(k).name;
    fullFileName = fullfile(files(k).folder, baseFileName);

    
    % Check if the filename does contain the specified substring
        if contains(baseFileName, subString, 'IgnoreCase', true)
            filteredFilenames{end+1} = files(k);
        end
    end
  
end