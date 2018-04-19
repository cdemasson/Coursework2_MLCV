%% Clearing previous variables
clear all
close all
% *************************************************************************
%%                         READING ALL IMAGES 
% *************************************************************************

for FIG = 1:2
    % READING BOAT IMAGES
    boat(FIG).fig = imread(['door' num2str(FIG) '.jpg']);
end

for FIG = 1:5
    % READING TSUKUBA IMAGES
    tsukuba(FIG).fig = imread(['scene1.row3.col' num2str(FIG) '.ppm']);
end

for FIG = 1:2
    % READING FD IMAGES
    % SELECT WHICH FD IMAGES TO USE
    FDimages(FIG).fig = imread(['RR' num2str(FIG) '.JPG']);  
    % Uncomment if you need to rotate the images
    FDimages(FIG).fig = imrotate(FDimages(FIG).fig,-90);           
end


% *************************************************************************
%%                MANUALLY MATCHING INTEREST POINTS
% *************************************************************************

%% BOAT SEQUENCE 
Bc = zeros(2,2,5);      % Boat coordinates
Pictures = [1,2];       % Select the pictures to compare 
for PT= 1:5
    for FIG = Pictures
        figure(FIG);
        imshow(boat(FIG).fig);
        [Bc(1, FIG, PT), Bc(2, FIG, PT)] = ginput(1);
    end
end

%% TSUKUBA SEQUENCE 
Tc = zeros(2,2,5);      % Tsukuba Coordinates
Pictures_T = [1,2];     % Select the pictures to compare 
for PT= 1:10
    for FIG = Pictures_T
        figure(FIG);
        imshow(tsukuba(FIG).fig);
        [Tc(1, FIG, PT), Tc(2, FIG, PT)] = ginput(1);
    end
end


%% FD SEQUENCE 
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

%% Q1, 3a: Calculating the homography matrix (HA) 
HM = HomogMatrix(Bc); 

%% Q1, 3b: Calculating the fundamental matrix (FA)
FM = FundMatrix(Tc); 

%% Q1, 3c: Homographic point projection and accruacy  

Accuracy = HomogAccuracy(Bc,HM);
%%  Q1, 3d: Epipolar line generation and accuracy 

% Determining the epipolar line (in image A for example) using the 
% fundamental matrix and an interest point in A

range = size(tsukuba(1).fig); 
range = range(1,2); 
Point = Tc(:,1,3); 
Epipolar = EpiLine(FM,Point,true,range); 
x = Epipolar.x; 
y = Epipolar.y; 
Epipole = Epipolar.e; 

% Plotting 
figure(1);
imshow(tsukuba(1).fig)
hold on 
plot(x,y,'r',Epipole(1,1),Epipole(2,1),'b+', Point(1,1), Point(2,1),'g+'); 
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
legend("Epipolar line", "Epipole", "Interest point"); 

%%
% Determining the projected epipolar line in image B, from a projection of
% a point in image A using Line' = FM*X. 
% Once off calculation to plot this projected epipolar line on image B
Ip = 4; 
LineB = FM*[Tc(:,1,Ip);1]; 
xb = 1:range; 
yb = (-LineB(1,1)*x-LineB(3,1))/LineB(2,1); 
figure(2);
imshow(tsukuba(2).fig)
hold on 
plot(xb,yb,'r',Tc(1,2,Ip),Tc(2,2,Ip),'m+')
set(findall(gca, 'Type', 'Line'),'LineWidth',3);
legend("Epipolar line in image B","Interest point in B"); 

% Determining the fundamental accuracy using the average distance between
% points in B and the epipolar lines in B generated using the projection of
% a point in A 
FA = Fund_Matrix_Accuracy(FM,Tc); 



% *************************************************************************
%%                 Q2.2 Stereo Vision (Using images FD: LION) 
% *************************************************************************

%%  Q2.2a      Calculate the fundamental matrix accuracy using manual matcher
        
FM = FundMatrix(FDcc);                % Estimating the fundamental matrix 
FA = Fund_Matrix_Accuracy(FM,FDcc);   % Estimating the accuracy 

%% Q2.2aa       Calculate the fundamental matrix accuracy using automatic matcher

% Step 1: Implement harris features detector  
alpha = 0.05;
trshld = 1;
r = 6;
figure(1);
FD_interest_points1 = my_harris_detector(FDimages(1).fig, alpha, trshld, r);
figure(2);
FD_interest_points2 = my_harris_detector(FDimages(2).fig, alpha, trshld, r);

% Step 2: Get image descriptors  
FD_descriptors1 = colour_descriptor(FDimages(1).fig, FD_interest_points1);
FD_descriptors2 = colour_descriptor(FDimages(2).fig, FD_interest_points2);

% Step 3: KNN Interest point matches
FD_match = KNN(FD_descriptors1, FD_descriptors2, FD_interest_points1, FD_interest_points2, FDimages);

MatchPoints1 = [FD_match(:,2),FD_match(:,1)]; 
MatchPoints2 = [FD_match(:,4),FD_match(:,3)]; 

% Step 4: Calculate the fundamental matrix for the matches
%Convert to correct form for Fundamental matrix function 
for i = 1: length(MatchPoints1)
    CorrespondingPoints(1:2,1:2,i) =  [MatchPoints1(i,:).',MatchPoints2(i,:).']; 
end 

FM = FundMatrix(CorrespondingPoints(:,:,randperm(9))); 
FA = Fund_Matrix_Accuracy(FM,CorrespondingPoints(:,:,randperm(8))); 

%%  Q2.2b

% Calculate the maximum range in the X coordinate
range = size(FDimages(1).fig);  
range = range(1,2); 
IPs = 5;                    % SELECT THE INTEREST POINTS TO COMPARE
PointA = FDcc(:,1,IPs);
PointB = FDcc(:,2,IPs); 
EpipolarA = EpiLine(FM,PointA,true,range);
EpipolarB = EpiLine(FM,PointA,false,range);

% Assigning variables 
xA = EpipolarA.x; 
yA = EpipolarA.y; 
EpipoleA = EpipolarA.e; 
xB = EpipolarB.x; 
yB = EpipolarB.y; 
EpipoleB = EpipolarB.e; 

% Plotting 
figure(1);
imshow(FDimages(1).fig)
hold on 
plot(xA,yA,'r',EpipoleA(1,1),EpipoleA(2,1),'b+', PointA(1,1), PointA(2,1),'g+'); 
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
legend("Epipolar line", "Epipole", "Interest point"); 

% Plotting 
figure(2);
imshow(FDimages(2).fig)
hold on 
plot(xB,yB,'r',EpipoleB(1,1),EpipoleB(2,1),'b+', PointB(1,1), PointB(2,1),'g+'); 
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
legend("Epipolar line", "Epipole", "Interest point"); 

%% Q2.2e               ReportImRectify Images Using Matlab   

% Set 1 to visualize and 0 else 
visualize = 1; 

%                   STEP 1:   Read stereo image pair  
I1 = FDimages(1).fig;
I2 = FDimages(2).fig; 
% Convert to grayscale.
I1gray = rgb2gray(I1);
I2gray = rgb2gray(I2);

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
figure;
showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2);
legend('Putatively matched points in I1', 'Putatively matched points in I2');
end 

%            STEP 4:   Remove outliers using Epopolar Constraints

[fMatrix, epipolarInliers, status] = estimateFundamentalMatrix(...
  matchedPoints1, matchedPoints2, 'Method', 'RANSAC', ...
  'NumTrials', 10000, 'DistanceThreshold', 0.8, 'Confidence', 99.99);

if status ~= 0 || isEpipoleInImage(fMatrix, size(I1)) ...
  || isEpipoleInImage(fMatrix', size(I2))
  error(['Either not enough matching points were found or '...
         'the epipoles are inside the images. You may need to '...
         'inspect and improve the quality of detected features ',...
         'and/or improve the quality of your images.']);
end

inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);

if (visualize == 1)
figure;
showMatchedFeatures(I1, I2, inlierPoints1, inlierPoints2);
legend('Inlier points in I1', 'Inlier points in I2');
end 

%                   STEP 5:   Rectify Images

[t1, t2] = estimateUncalibratedRectification(fMatrix, ...
  inlierPoints1.Location, inlierPoints2.Location, size(I2));
tform1 = projective2d(t1);
tform2 = projective2d(t2);

[I1Rect, I2Rect] = rectifyStereoImages(I1, I2, tform1, tform2);
if (visualize == 1)
figure;
imshowpair(I1Rect, I2Rect,'montage');
figure;
imshow(stereoAnaglyph(I1Rect, I2Rect));
title('Rectified Stereo Images (Red - Left Image, Cyan - Right Image)');
end 

%% Q2.2ee Perform image rectification using manually matched interest points

% Step 1:          calculate the fundamental matrix  
FM = FundMatrix(FDcc);                % Estimating the fundamental matrix 

% Step 2:        convert form of corresponding points   
MatchPoints1 = [];
MatchPoints2 = []; 
for i = 1:length(FDcc) 
    MatchPoints1 = [MatchPoints1;FDcc(:,1,i).'];  
    MatchPoints2 = [MatchPoints2;FDcc(:,2,i).' ]; 
end 

% Step 3:               Rectify images 
[t1, t2] = estimateUncalibratedRectification(FM,MatchPoints1,MatchPoints1, size(FDimages(1).fig));
tform1 = projective2d(t1);
tform2 = projective2d(t2);

RA = imread(['Rec1.png']); 
RB = imread(['Rec2.png']); 

[FD1Rect, FD2Rect] = rectifyStereoImages(FDimages(1).fig, FDimages(2).fig, tform1, tform2);

figure;
imshowpair(FD1Rect, FD2Rect,'montage');


%%                      Q2.2c: Disparity map 

%First convert to grayscale
% NB: YOU MUST FIRST RUN Q2.2e, AND RECTIFY THE IMAGES
ImageA = rgb2gray(FD1Rect);
ImageB = rgb2gray(FD2Rect);
% Disparity range is the range of disparity to show, the differenc must be
% divisible by 16
disparityRange = [0 16];
% Blocksize is an odd interger in the range [5 255], it determines the
% square block size for comparison. 
disparityMap = disparity(ImageA,ImageB,'BlockSize',5,'DisparityRange',disparityRange);
figure(1)
imshow(disparityMap,disparityRange);
title('Disparity Map');
colormap(gca,jet) 
colorbar

%%                      Q2.2d: Depth map from disparity map 

% Define camera constants in m 
focal_length = 18; 
baseline = 200;
SensorSize = 0.00487; 
%SensorSize = 200; 

DepthMap = (focal_length*baseline)./((disparityMap)*SensorSize); 
%DepthMap = DepthMap/1000;    % Convert to m 
%find(DepthMap == Inf) 

depthRange = [0 3000];
figure(2)
imshow(DepthMap,depthRange) 
title('Depth Map');
colorbar

%%              Q2.2e: Depth map from disparity map with random noise 

disparityMapNoise = disparityMap+2*rand();
figure(2)
imshow(disparityMapNoise,disparityRange);
title('Disparity Map');
colormap(gca,jet) 
colorbar


%%                      ADDITIONAL CODE 
%%              THIS HAS BEEN CHANGES FOR THE BOAT IMAGES
%         Collecting all epipolar lines and plotting them on the  two image 
FM = FundMatrix(Bc);                % Estimating the fundamental matrix 
% Calculate the maximum range in the X coordinate
range = size(boat(1).fig);  
range = range(1,2); 

 for IPs = 1:length(Bc)
     PointA = Bc(:,1,IPs);
     PointB = Bc(:,2,IPs);
     
    EpipolarA = EpiLine(FM,PointA,true,range);
    EpipolarB = EpiLine(FM,PointA,false,range);
    EpilinesA(IPs).fig = [EpipolarA.x;EpipolarA.y];
    EpilinesB(IPs).fig = [EpipolarB.x;EpipolarB.y];
 end 

% Plotting the epipolar lines on the images
figure(1);
imshow(boat(1).fig)
hold on 
figure(2);
imshow(boat(2).fig)
hold on 

for IPs = 1:length(Bc)
figure(1);
plot(EpilinesA(IPs).fig(1,:),EpilinesA(IPs).fig(2,:),'r',Bc(1,1,IPs),Bc(2,1,IPs),'g+'); 
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
hold on 
figure(2);
plot(EpilinesB(IPs).fig(1,:),EpilinesB(IPs).fig(2,:),'r',Bc(1,2,IPs),Bc(2,2,IPs),'g+'); 
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
hold on 
end
%%  








