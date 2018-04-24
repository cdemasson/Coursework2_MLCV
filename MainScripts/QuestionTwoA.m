% Script for generating accuracies for 2.2a 
clear all 
for FIG = 1:2
    % READING FD IMAGES
    % SELECT WHICH FD IMAGES TO USE
    FDimages(FIG).fig = imread(['lamp' num2str(FIG) '.JPG']);  
    % Uncomment if you need to rotate the images
    %FDimages(FIG).fig = imrotate(FDimages(FIG).fig,-90);           
end

%%                  Manually selected points 
FDcc = zeros(2,2,4);      % FD Corrosponding Coordinates
Picture = [1,2];       % Select the pictures to compare
Pic1 = Picture(1,1); 
Pic2 = Picture(1,2); 
for PT= 1:10
    for FIG = 1:2
        figure(FIG);
        % This ensures the pictures swap regardness of which pictures are
        % chosen 
        if (FIG == 1)
            Pic = Pic1; 
        else 
            Pic = Pic2; 
        end 
        imshow(FDimages(Pic).fig);
        [FDcc(1,FIG, PT), FDcc(2,FIG, PT)] = ginput(1);
    end
end

%%                  Automatically selected points 
%                   STEP 1:   Read stereo image pair  
I1 = imread(['FD1.jpeg']); 
I2 = imread(['FD2.jpeg']);
% Convert to grayscale.
I1gray = rgb2gray(I1);
I2gray = rgb2gray(I2);
visualize = 1; 

if (visualize == 1)
figure;
imshowpair(I1, I2,'montage');
title('I1 (left); I2 (right)');
figure(2);
imshow(stereoAnaglyph(I1,I2));
title('Composite Image (Red - Left Image, Cyan - Right Image)');
end 

%                STEP 2:   Collect interest points 

blobs1 = detectSURFFeatures(I1gray, 'MetricThreshold', 2000);
blobs2 = detectSURFFeatures(I2gray, 'MetricThreshold', 2000);

if (visualize == 1)
figure;
imshow(I1);
hold on;
plot(selectStrongest(blobs1, 30));
title('Thirty strongest SURF features in I1');

figure;
imshow(I2);
hold on;
plot(selectStrongest(blobs2, 30));
title('Thirty strongest SURF features in I2');
end 

%               STEP 3:   Find point correspondences

[features1, validBlobs1] = extractFeatures(I1gray, blobs1);
[features2, validBlobs2] = extractFeatures(I2gray, blobs2);

% Match featues using SAD
indexPairs = matchFeatures(features1, features2, 'Metric', 'SAD','MatchThreshold', 5);

matchedPoints1 = validBlobs1(indexPairs(:,1),:);
matchedPoints2 = validBlobs2(indexPairs(:,2),:);

if (visualize == 1)
figure,
showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2);
legend('Putatively matched points in I1', 'Putatively matched points in I2');
end 

%               STEP 4:   Convert to my data form 

for i = 1 : length(matchedPoints1.Location) 
    CC(1:2,1:2,i) = [matchedPoints1.Location(i,:).', matchedPoints2.Location(i,:).']; 
end 




%%              CALCULATING THE ACCURACIES without RANSAC

FMA = FundMatrix(CC); 
FMB  = FundMatrix(FDcc); 
FAaccA = Fund_Matrix_Accuracy(FMA,CC);
FAaccB = Fund_Matrix_Accuracy(FMB,FDcc);

%%              CALCULATING THE ACCURACIES with RANSAC 
RanFundA = RANSACFund(CC,0.9);  
%RanFundB = RANSACFund(FDcc,0.9);  

FAccuracyA = Fund_Matrix_Accuracy(RanFundA.FM,RanFundA.m); 
%FAccuracyB = Fund_Matrix_Accuracy(RanFundB.FM,RanFundB.m); 


%%          QUESTION 2.2b 

% Select the images and corresponding points
CPS = CC;
ImageA = I1;
ImageB = I2;
FM = RanFundA.FM;                % Estimating the fundamental matrix 
% Calculate the maximum range in the X coordinate
range = size(ImageA);  
range = range(1,2); 

 for IPs = 1:10
     PointA = CPS(:,1,IPs);
     PointB = CPS(:,2,IPs);
     
    EpipolarA = EpiLine(FM,PointA,true,range);
    EpipolarB = EpiLine(FM,PointA,false,range);
    EpilinesA(IPs).fig = [EpipolarA.x;EpipolarA.y];
    EpilinesB(IPs).fig = [EpipolarB.x;EpipolarB.y];
 end 

% Plotting the epipolar lines on the images
figure(1);
imshow(ImageA)
hold on 
figure(2);
imshow(ImageB)
hold on 

for IPs = 1:10
figure(1);
plot(EpilinesA(IPs).fig(1,:),EpilinesA(IPs).fig(2,:),'r',CPS(1,1,IPs),CPS(2,1,IPs),'g+'); 
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
hold on 
figure(2);
plot(EpilinesB(IPs).fig(1,:),EpilinesB(IPs).fig(2,:),'r',CPS(1,2,IPs),CPS(2,2,IPs),'g+'); 
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
hold on 
end













