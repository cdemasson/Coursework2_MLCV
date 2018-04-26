% This script performs stereo rectificaion on the images 

%% Read the images and manually select interest points 
clear all 
close all 
for FIG = 1:2
    FDimages(FIG).fig = imread(['lamp' num2str(FIG) '.JPG']);  
    %FDimages(FIG).fig = imrotate(FDimages(FIG).fig,-90);           
end

%%
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

%% Stereo Rectification 

FocalLength = 2;        % Define the camera focal length 

% Step 1: Calculate the direction of the left epipole 
FundRan = RANSACFund(FDcc,0.9);
FM = FundRan.FM; 
FA = Fund_Matrix_Accuracy(FM,FundRan.m); 
%%
Epipolar = EpiLine(FM,FundRan.m(:,2,2),false,size(FDimages(1).fig,1)); 
EpipoleB = Epipolar.e;      % Left Epipole [x;y] 

% Step 2: Calculate the Rrec matrix 
e1 = [EpipoleB/norm(EpipoleB);0];
e2 = [-EpipoleB(2,1);EpipoleB(1,1);0]/norm(EpipoleB); 
e3 = cross(e1,e2); 
Rrec = [e1.';e2.';e3.']; 

% Step 3: Perform the rotation 
ImageR = FDimages(1).fig; 
ImageL = FDimages(2).fig; 
theta = deg2rad(1.15); 
Rright = [cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1];  
Rl = Rrec; 
Rr = Rright\Rrec; 
ImageLRect = ImageTranslate(ImageL,Rl,FocalLength); 
ImageLRect = imresize(ImageLRect,1); 
ImageRRect = ImageTranslate(ImageR,Rr,FocalLength); 
ImageRRect = imresize(ImageRRect,1); 
figure(1)
imshowpair(ImageLRect,ImageRRect,"montage")
hold on 
% Calibration line 
% P1 = [0 316]; 
% P2 = [1500 316]; 
% animatedline([P1(1,1),P2(1,1)],[P1(1,2),P2(1,2)]);
% set(findall(gca, 'Type', 'Line'),'LineWidth',2);

%% Calculate the disparity map 
clear all 
load DispTestL
load DispTestR
%%
%ImageLRect = I1Rect; 
%ImageRRect= I2Rect; 
DispMap = Disparity(ImageLRect,ImageRRect,1,0.1); 
%% Show the map 
disparityRange = [0 400];
imshow(DispMap,disparityRange);
title('Disparity Map');
colormap(gca,jet) 
colorbar



























