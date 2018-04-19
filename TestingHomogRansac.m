% Testing the new form of the ransac homog matrix 

clear all 
load MatchPoints1
load MatchPoints2

%%                  AUTOMATIC FEATURE DETECTOR 
% Step 1: Implement harris features detector  
clear all
for FIG = 1:2
    % READING BOAT IMAGES
    boat(FIG).fig = imread(['img' num2str(FIG) '.pgm']);
end
%%

alpha = 0.05;
trshld = 1;
r = 6;
figure(1);
FD_interest_points1 = my_harris_detector(boat(1).fig, alpha, trshld, r);
figure(2);
FD_interest_points2 = my_harris_detector(boat(2).fig, alpha, trshld, r);

% Step 2: Get image descriptors  
FD_descriptors1 = gray_descriptor(boat(1).fig, FD_interest_points1);
FD_descriptors2 = gray_descriptor(boat(2).fig, FD_interest_points2);

% Step 3: KNN Interest point matches
FD_match = KNN(FD_descriptors1, FD_descriptors2, FD_interest_points1, FD_interest_points2, boat);

MatchPoints1 = [FD_match(:,2),FD_match(:,1)]; 
MatchPoints2 = [FD_match(:,4),FD_match(:,3)]; 

% Step 4: Calculate the fundamental matrix for the matches
%Convert to correct form for Fundamental matrix function 
for i = 1: length(MatchPoints1)
    CorrespondingPoints(1:2,1:2,i) =  [MatchPoints1(i,:).',MatchPoints2(i,:).']; 
end 
%Convert to correct form for Fundamental matrix function 
for i = 1: length(MatchPoints1)
    CPoints(1:2,1:2,i) =  [MatchPoints1(i,:).',MatchPoints2(i,:).']; 
end 

%% CALCULATE THE HOMOGRQPHY MATRIX AND ACCURACY USING RANSAC 

RanHomog = RANSACHomog(CPoints,7);  % Input the corrosponding points and the threshold 
HAccuracy = HomogAccuracy(RanHomog.m,RanHomog.HM)
