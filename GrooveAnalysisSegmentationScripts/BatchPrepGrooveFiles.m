%Author: Laura Schwendeman
%Date: 3/17/2026
%Purpose: To run through Maheera's Groove Image Data and make segmentated
%Images with SAM in a more automatic manner (once bin segmented images are
%made, can send to MultiDayGrooveAnalysis.m for somewhat automatic processing of
%widths and boundaries)
clc; clear; close all; 
%% save info
ogcrossSectionLoc = "OriginalCrossSection\"; 
segmentedLoc = "SegmentedCrossSection_3_17_26\";
dataSaveName = "3_17_36_MaheeraGrooveAnalysis.mat";

%% filenames

%for Gelma 5% and 10%
folderName1.Name = "C:\Users\draga\MIT Dropbox\Raman Lab\Laura Schwendeman\1_28_26 Maheera Gelma5_10 Gel Longevity Exp\";
folderName1.subfolders = {"d0", "d2", "d4", "d6"};

%for gelma 7.5% and fibrin
folderName2.Name = "C:\Users\draga\MIT Dropbox\Raman Lab\Laura Schwendeman\11_17_25 Maheera GelMa Fibrin Comparision\";
folderName2.subfolders = {"Fibrin D0", "Fibrin D2", "Fibrin D4", "Fibrin D6", "GelMa D0", "GelMa D2", "GelMa D4","GelMa D6"};

%set which folders to look at
folders = {folderName1, folderName2};

%make a set of objects for each picture to open
fileNameData = {};
for folder = folders
    folderObj = folder{:};
    for subfolder = folderObj.subfolders
        name = folderObj.Name + subfolder{:}; 
        files = dir(fullfile(name, '*'));
        
        filesToKeep = filterFilesName(files, "Denoised");
        fileNameData = [fileNameData, filesToKeep];

    end
end



%% loop through and generate all of the cross sections and save them
 
f = 51; 
for i = 1:length(fileNameData)
    
    file = fileNameData{i};
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

    %get rid of weird super high pixel values
    imageStack(imageStack > 1000) = 0;

    %get the directionality
    z_level = ceil(size(imageStack, 3)/2);
    %[angles, hist, mean_angle] = directionality_analysis(imageStack(:,:,z_level), "show_plot", false);
    %mean_angle = correct_stripe_angle(imageStack(:,:,z_level));
    mean_angle = rotate_by_drawn_line(imageStack(:,:,z_level));

    %plot the orignal groove image
    if mod(i-1,5) == 0
       fig = figure(f);
        f = f+1; 
    else 
        figure(fig)
    end
    q = mod(i-1, 5);
    c = 4*(q);
    subplot(5, 4, c+1);
    imshow(imageStack(:,:,z_level), []);
    title(file.name)

    %rotate the image
    im_rotated = imrotate(imageStack(:,:,z_level), mean_angle);

    %plot the rotated Image
    subplot(5, 4, c+2);
    imshow(im_rotated, [])
    title(mean_angle)

    %section the image
    rot_imageStack = [];
    for zp = 1:reader.sizeZ
        rot_imageStack(:,:,zp) = imrotate(imageStack(:,:,zp), mean_angle);
    end

    %now take the section in the middle
    ysection = rot_imageStack(:,round(end/2), :);
    ysection = permute(ysection, [1 3 2]);
    
    %get rid of the blank space
    ybound = round((size(ysection, 1) - reader.width)/2);
    ysection_new = ysection((ybound+1):(end-ybound), :);

    %plot the cross section image
    subplot(5, 4, c+3);
    imshow(ysection_new', []);

    %savetheangles
    fileNameData{i}.angle = mean_angle; 

    %save the picture
    fileNameData{i}.rawSection = ysection_new';
    picName = makeImageName(fileName);
    imwrite(ysection_new, ogcrossSectionLoc+picName+'.png');

end

save(dataSaveName,'fileNameData')
%% Loop through each cross section and then pull up the image Segmenter and save the mask


%% show all of the masks vs their original image



%% helpful functions
function [imName] = makeImageName(fileName)
    splits = split(fileName, '\');

    imName = splits{end-2}+ "_" + splits(end-1) + "_" + splits(end);
end

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

%directionality functions - 100% from ai but if they work they work
function [angles, histogramCounts] = directionality_fourier(img, nBins)

    if nargin < 2
        nBins = 90; % match ImageJ default
    end
    
    img = double(img);

    % 1) Compute Fourier transform
    F = fftshift(fft2(img));
    P = abs(F).^2; % power spectrum

    % 2) Convert to polar coordinates (radius, angle)
    [h, w] = size(img);
    [X, Y] = meshgrid(1:w, 1:h);
    cx = (w+1)/2;
    cy = (h+1)/2;

    % angles in degrees
    anglesImg = atan2(Y - cy, X - cx) * 180/pi;  
    anglesImg(anglesImg < 0) = anglesImg(anglesImg < 0) + 180; 

    % 3) Build histogram of power per angle
    angles = linspace(0, 180, nBins+1);
    histogramCounts = zeros(1, nBins);

    for i = 1:nBins
        mask = anglesImg >= angles(i) & anglesImg < angles(i+1);
        histogramCounts(i) = sum(P(mask));
    end

    % center bin angles
    angles = angles(1:end-1) + (180/nBins)/2;

end

%claude's function
function [angles, histogram, meanAngle, stdAngle] = directionality_analysis(img, varargin)
% DIRECTIONALITY_ANALYSIS - Replicates ImageJ's directionality plugin
% Uses Fourier components method to analyze directional structures
%
% Inputs:
%   img - 2D grayscale image
%   Optional parameters (name-value pairs):
%       'nbins' - Number of histogram bins (default: 90)
%       'hist_start' - Histogram start angle in degrees (default: -90)
%       'hist_end' - Histogram end angle in degrees (default: 90)
%       'show_plot' - Display results plot (default: true)
%
% Outputs:
%   angles - Angle values for histogram bins
%   histogram - Histogram counts (power at each angle)
%   meanAngle - Weighted mean direction
%   stdAngle - Standard deviation of direction

% Parse inputs
p = inputParser;
addParameter(p, 'nbins', 90, @isnumeric);
addParameter(p, 'hist_start', -90, @isnumeric);
addParameter(p, 'hist_end', 90, @isnumeric);
addParameter(p, 'show_plot', true, @islogical);
parse(p, varargin{:});

nbins = p.Results.nbins;
hist_start = p.Results.hist_start;
hist_end = p.Results.hist_end;
show_plot = p.Results.show_plot;

% Convert to double and normalize
img = double(img);
if max(img(:)) > 1
    img = img / max(img(:));
end

% Get image dimensions
[rows, cols] = size(img);

% Apply 2D Blackman window (as in ImageJ plugin)
% This prevents cross artifacts at x=0 and y=0 in FFT
blackman_window = create_blackman_window_2d(rows, cols);
img_windowed = img .* blackman_window;

% Compute 2D FFT
fft_img = fft2(img_windowed);
fft_img = fftshift(fft_img);

% Get power spectrum
power_spectrum = abs(fft_img).^2;

% Create coordinate system centered at origin
[X, Y] = meshgrid(1:cols, 1:rows);
center_x = cols / 2 + 0.5;
center_y = rows / 2 + 0.5;
X = X - center_x;
Y = Y - center_y;

% Calculate angles (in degrees, -90 to 90)
theta = atan2d(-Y, X); % Negative Y because image coordinates

% Create histogram bins
angle_edges = linspace(hist_start, hist_end, nbins + 1);
angles = (angle_edges(1:end-1) + angle_edges(2:end)) / 2;
histogram = zeros(1, nbins);

% Accumulate power spectrum values into histogram bins
for i = 1:nbins
    % Find pixels in this angular bin
    mask = (theta >= angle_edges(i)) & (theta < angle_edges(i+1));
    
    % Sum power in this direction
    histogram(i) = sum(power_spectrum(mask));
end

% Normalize histogram
histogram = histogram / sum(histogram);

% Calculate weighted mean angle (circular mean)
% Convert to radians for calculation
angles_rad = deg2rad(angles);
sin_sum = sum(histogram .* sin(angles_rad));
cos_sum = sum(histogram .* cos(angles_rad));
meanAngle = atan2d(sin_sum, cos_sum);

% Calculate circular standard deviation
R = sqrt(sin_sum^2 + cos_sum^2);
stdAngle = sqrt(-2 * log(R)) * 180 / pi;

% Display results
fprintf('Directionality Analysis Results:\n');
fprintf('Mean Direction: %.2f degrees\n', meanAngle);
fprintf('Std Deviation: %.2f degrees\n', stdAngle);

% Plot if requested
if show_plot
    figure('Name', 'Directionality Analysis', 'NumberTitle', 'off');
    
    subplot(2, 2, 1);
    imshow(img, []);
    title('Original Image');
    
    subplot(2, 2, 2);
    imagesc(log(1 + power_spectrum));
    axis image;
    colormap(gca, 'hot');
    title('Power Spectrum (log scale)');
    
    subplot(2, 2, [3, 4]);
    bar(angles, histogram, 'FaceColor', [0.2 0.4 0.8]);
    xlabel('Direction (degrees)');
    ylabel('Amount (normalized power)');
    title(sprintf('Directionality Histogram (Mean: %.2f°)', meanAngle));
    grid on;
    xlim([hist_start hist_end]);
    
    % Add mean line
    hold on;
    yl = ylim;
    plot([meanAngle meanAngle], yl, 'r--', 'LineWidth', 2);
    legend('Histogram', 'Mean Direction', 'Location', 'best');
    hold off;
end

end

%% Helper functions
function window_1d = blackman_window(n)
% Generate 1D Blackman window
k = 0:(n-1);
window_1d = 0.42 - 0.5 * cos(2*pi*k/(n-1)) + 0.08 * cos(4*pi*k/(n-1));
end

function window_2d = create_blackman_window_2d(rows, cols)
% Generate 2D Blackman window by outer product of 1D windows
window_row = blackman_window(rows);
window_col = blackman_window(cols);
window_2d = window_row' * window_col;
end

%% another one from bestie claude
function rot_angle = correct_stripe_angle(img)
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    img = double(img);

    F = fftshift(fft2(img));
    magnitude = log(1 + abs(F));

    [rows, cols] = size(magnitude);
    cx = cols/2; cy = rows/2;
    [X, Y] = meshgrid(1:cols, 1:rows);
    dc_mask = sqrt((X-cx).^2 + (Y-cy).^2) > 10;
    magnitude_masked = magnitude .* dc_mask;

    % Average top N peaks for robustness (handles noise better than single peak)
    flat = magnitude_masked(:);
    [~, top_idx] = maxk(flat, 5);
    [fy_all, fx_all] = ind2sub(size(magnitude_masked), top_idx);
    dx = mean(fx_all) - cx;
    dy = mean(fy_all) - cy;

    stripe_angle = rad2deg(atan2(dy, dx));
    rot_angle = 90+stripe_angle; %90 - stripe_angle;

    %img_out = imrotate(img, rot_angle, 'bilinear', 'crop');
end

%% an option for just drawing a line
function [angle_deg] = rotate_by_drawn_line(img)
    
    fig = figure('Name', 'Draw a line along the stripes, then press Enter');
    imshow(img, []); 
    title({'Draw a line parallel to the stripes', ...
           'Double-click or press Enter when done'}, ...
           'FontSize', 12);

    % --- Let user draw a line ---
    h = drawline('Color', 'r', 'LineWidth', 2);
    
    % Wait for user to finish (double-click or Enter)
    customWait(h);

    % Get the line endpoints
    pos = h.Position;  % [x1 y1; x2 y2]
    x1 = pos(1,1); y1 = pos(1,2);
    x2 = pos(2,1); y2 = pos(2,2);

    % --- Compute angle from horizontal ---
    dx = x2 - x1;
    dy = y2 - y1;
    angle_deg = -rad2deg(atan2(-dy, dx));  % angle of line from horizontal
 
end

% Helper: waits for user to finish interacting with the ROI
function customWait(h)
    l = addlistener(h, 'ROIClicked', @(src, evt) resume(evt));
    uiwait;
    delete(l);

    function resume(evt)
        if strcmp(evt.SelectionType, 'double')
            uiresume;
        end
    end
end
