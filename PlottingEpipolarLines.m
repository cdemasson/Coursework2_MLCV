%%                  Automatically selected points 
%                   STEP 1:   Read stereo image pair  
clear all 
I1 = imread(['scene1.row3.col1.ppm']); 
I2 = imread(['scene1.row3.col5.ppm']);
% Convert to grayscale.
I1gray = rgb2gray(I1);
I2gray = rgb2gray(I2);
visualize = 0; 

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


%%

% Select the images and corresponding points
CPS = CC;
ImageA = I1;
ImageB = I2;
FMR = RANSACFund(CPS,0.9);                % Estimating the fundamental matrix 
FM = FMR.FM;
CPS = FMR.m; 

% Calculate the maximum range in the X coordinate
range = size(ImageA);  
range = range(1,2); 

 for IPs = 10: 20 %length(CPS)
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

for IPs = 10:20 % length(CPS)
figure(1);
plot(EpilinesA(IPs).fig(1,:),EpilinesA(IPs).fig(2,:),'r',CPS(1,1,IPs),CPS(2,1,IPs),'g+'); 
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
hold on 
figure(2);
plot(EpilinesB(IPs).fig(1,:),EpilinesB(IPs).fig(2,:),'r',CPS(1,2,IPs),CPS(2,2,IPs),'g+'); 
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
hold on 
end










