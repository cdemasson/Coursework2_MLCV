% THIS SCRIPT TESTS THE HOMOG RANSAC FUNCTION AND THEN USES THE HOMOG
% MATRIX TO TRANSFORM THE IMAGES 

clear all 
load MatchPoints1
load MatchPoints2

%%                  AUTOMATIC FEATURE DETECTOR 
% Step 1: Implement harris features detector  
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

%%  TESTING WITH WILL'S BOAT DATA 
load WillX
load WillY

for i = 1: length(PairedPosX)
    CPoints(1:2,1:2,i) =  [[PairedPosX(i,1);PairedPosY(i,1)],[PairedPosX(i,2);PairedPosY(i,2)]]; 
end 

%% CALCULATE THE HOMOGRQPHY MATRIX AND ACCURACY USING RANSAC 

RanHomog = RANSACHomog(CPoints,0.9);  % Input the corrosponding points and the threshold 
HAccuracy = HomogAccuracy(RanHomog.m,RanHomog.HM); 
fprintf(" The number of correctly matched points is %4.2f \n", length(RanHomog.m));
fprintf(" The accuracy for these points is %4.2f pixels \n", HAccuracy);

%% Translating the image 
for FIG = 1:6
    % READING BOAT IMAGES
    boat(FIG).fig = imread(['img' num2str(FIG) '.pgm']);
end

%%

ImageA = boat(1).fig;
ImageB = boat(2).fig; 
ImageBTr = ImageTranslate(ImageB,RanHomog.HM); 
figure(1)
imshowpair(ImageA, ImageB,'montage')
figure(2)
imshowpair(ImageA,ImageBTr,'montage'); 
%imshow(ImageBTr)




