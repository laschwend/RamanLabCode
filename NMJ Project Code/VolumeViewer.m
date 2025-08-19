%Laura Schwendeman 
%7/28/2025
%Purpose: to open image files and make 3D renders of them

%first open the .nd2 file

filepath = 'C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\7_25_25 leak test r1 - 11-8-345\11-8-3-LS_20X.nd2';
filename = '11-8-3_AB_channel_20x.nd2';
filename = '11-8-3-LS_20X.nd2'

filepath = 'C:\Users\laSch\MIT Dropbox\Raman Lab\Laura Schwendeman\7_2_2025 fluobead test 4 - after pictures\20x_Fluotest4_after_B2_10um.nd2'
fileName = filepath;% + filename; 


reader = BioformatsImage(fileName);

%% make 3D image stack

imageStack = zeros(reader.height, reader.width, reader.sizeZ, 3);

for c = 1:reader.sizeC

    for z = 1:reader.sizeZ
    
        imageStack(:,:,z, c) = getPlane(reader, z, 1, 1);
    
    end
end

%% view the final image
alphaMap = linspace(0, 1, 256);
alphaMap(1:75)= 0;
volshow(imageStack, "Alphamap",alphaMap)


%% playing with image crop

I = getPlane(reader,15, 1, 1);


figure(1);
H = imshow(I, []);

[J,rectt] = imcrop(H);

figure(2)
imshow(J, []);

% playing with binarization




%Filter the image
J_filt = imgaussfilt(J, 5);
figure(3)
J_filt = mat2gray(J_filt);
imshow(J_filt)
% 
% J_filt = medfilt2(J_filt, [20,20]);
% figure(4)
% imshow(J_filt, [])

J_bin = imbinarize(J_filt, 0.5);

figure(5); 
imshow(J_bin)


% getting widths
measures = altWidthMeasure(~J_bin)

%report the average channel width
avearageWidth = reader.pxSize(1)*mean(measures)


%% funtions

function [fiberWidths] = altWidthMeasure(fiberImage)
    

    
    % Step 2: Skeletonize the object
    skeletonImage = bwskel(fiberImage);

    figure(1);
    subplot(2,3,1)
    imshow(skeletonImage);
    title('skelImage')

    edtImage = bwdist(~fiberImage); 

    subplot(2,3,2);
    imshow(edtImage, []);
    title('distance image')

    diameterImage = 2 * edtImage .* single(skeletonImage);

    subplot(2,3,3);
    imshow(diameterImage, [])
    title('Diameter Image');

    fiberWidths = diameterImage(diameterImage >0);

    subplot(2,3,4);
    histogram(fiberWidths);
    grid on;
    xlabel('Width in Pixels');
    ylabel('Count');
    title('widths');

    subplot(2,3,5);
    imshow(fiberImage);
    title('original image')

    %  figure(3);
    % imshow(edtImage*2, []);
    % 
    % [redSkelx, redSkely] = find(skeletonImage >0); 
    % 
    % hold on
    % plot(redSkely, redSkelx, '.r', "MarkerSize", 3);
    % 
    % boundaries = bwboundaries(fiberImage);
    % x = boundaries{1}(:, 2);
    % y = boundaries{1}(:, 1);
    % 
    % plot(x, y, '.y', "MarkerSize", 3)


    

end