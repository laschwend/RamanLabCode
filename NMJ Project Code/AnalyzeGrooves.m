%Author: Laura Schwendeman
%Date: 8/19/2025
%Purpose: Analyze Binarized Image of grooves and get average size of the
%grooves in the chip
close all; 
clear all; 

%% setup parameters
filefolder = "C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\NMJ Paper Figure Resources\Fig 2\";
filename = "Groove Projection View Bin_YZ 512.png";

pixelSize = 79.81/92; %um

%% Process Image
im = imread(filefolder+filename); 

figure(1);
imshow(im); 

%make a binary object
%im = mat2gray(im);
imBin = imbinarize(im(:,:,3), 0.99);
figure(2);
imshow(imBin)
hold on; 
%get the border line
boundary = bwboundaries(imBin);

for k = 1:length(boundary)
   boundar = boundary{k};
   plot(boundar(:,2), boundar(:,1), 'r', 'LineWidth', 2)
end

%get rid of the edges
B = boundary{1};

deleteLocs = B(:,1) == 1 | B(:, 2) == 1;

B(deleteLocs, :) = [];
B = B(1:(end-50), :);

plot(B(:,2), B(:,1), 'y', 'LineWidth',2)

%set the pixel values to the actual dimensions
B = B.*pixelSize; 

%subtract off the min value to lower the line
B(:,2) = B(:,2) - min(B(:,2), [], "all");

%% now get the peak and valley locations
figure(4);

plot(B(:,1), B(:,2), 'k');
xlabel("(um)");
ylabel("(um)");

[peaksvals, peaks] = findpeaks(B(:,2), "MinPeakDistance", 30);
[valleyvals, valleys] = findpeaks(-B(:,2), "MinPeakDistance", 30, 'MinPeakHeight', -15);

hold on; 
plot(B(peaks,1), B(peaks,2), 'or');
plot(B(valleys, 1), B(valleys, 2), 'ob');

%% seperate the signal into the discrete sections
figure(5); hold on; 

    interpPtAmt = 200; 
    Grooves = zeros(interpPtAmt, 2, length(valleys)-1); 
    %loop through each valley point
for i = 1:(length(valleys)-1)

    %get the x locs of the valleys
    x1 = valleys(i);
    x2 = valleys(i+1);

    %get the x y values
    B_section = B(x1:x2, :);

    %floor the b section with the min value
    B_section(:,2) = B_section(:,2) - min(B_section(:,2), [], "all");

    %get rid of duplicate x values
    [~,uniquelocs] = unique(B_section(:,1));
    B_section = B_section(uniquelocs, :);

    %interpolate the values for averaging
    x_vals = (0:(interpPtAmt-1))*pixelSize;
    xq = linspace(B_section(1,1), B_section(end,1),interpPtAmt);
    y_vals = interp1(B_section(:,1), B_section(:,2), xq, "linear");

    Grooves(:,1, i) = xq-B_section(1,1); 
    Grooves(:,2,i) = y_vals;  

    plot(Grooves(:,1,i), y_vals);

end

ylabel('(um)')
xlabel('(um)')
title('All Grooves Overlayed');

%calculate the average line and .std? --maybe find the 2.671 code for this
AverageGroove = mean(Grooves, 3);
maxGroove = max(Grooves(:, 2, :), [], 3);
minGroove = min(Grooves(:, 2, :), [], 3);
figure(6); 
hold on; 
plot(AverageGroove(:,1), AverageGroove(:,2), '-k');
plot(AverageGroove(:,1), maxGroove, '--r');
plot(AverageGroove(:,1), minGroove, '--b');

ylabel('height (um)')
xlabel('width (um)')
title('Average Groove Dimensions');
axis([0 50 0 30])


%add nominal dimensions line
r=12.5; %um
dtheta = .01; 
x1 = r*cos(-pi/2:dtheta:0); 
y1 = r*sin(-pi/2:dtheta:0)+r; 

x2 = r*cos(pi:-dtheta:0) +2*r;
y2 = r*sin(pi:-dtheta:0)+r;

x3 = r*cos(pi:dtheta:3/2*pi)+4*r;
y3 = r*sin(pi:dtheta:3/2*pi)+r;

plot([x1 x2 x3], [y1 y2 y3], '-y', 'LineWidth', 2);

legend('Average Groove', 'Maximum value', 'Minimum Value', 'Nominal Dimension');

%Plot a histogram of widths and heights


%% Plot final spread against ground truth


%% Extra Parameters