% This script performs stereo rectificaion on the images 

%% Read the images and manually select interest points 
clear all 
close all 
for FIG = 1:2
    FDimages(FIG).fig = imread(['LionBig' num2str(FIG) '.pgm']);  
    FDimages(FIG).fig = imrotate(FDimages(FIG).fig,-90);           
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
FM = FundMatrix(FDcc); 
FA = Fund_Matrix_Accuracy(FM,FDcc); 
Epipolar = EpiLine(FM,FDcc(:,2,1),false,size(FDimages(1).fig,1)); 
EpipoleB = Epipolar.e;      % Left Epipole [x;y] 

% Step 2: Calculate the Rrec matrix 
e1 = [EpipoleB/norm(EpipoleB);0];
e2 = [-EpipoleB(2,1);EpipoleB(1,1);0]/norm(EpipoleB); 
e3 = cross(e1,e2); 
Rrec = [e1.';e2.';e3.']; 

% Step 3: Perform the rotation 
ImageL = FDimages(1).fig; 
ImageR = FDimages(2).fig; 
ImageLRect = ImageTranslate(ImageL,Rrec,FocalLength); 
ImageRRect = ImageTranslate(ImageR,Rrec,FocalLength); 
imshowpair(ImageLRect,ImageRRect,"montage")



%% FOR WILL 

% Select the images and corresponding points
CPS = FDcc;
ImageA = FDimages(1).fig;
ImageB = FDimages(2).fig;
FM = FundMatrix(CPS);                % Estimating the fundamental matrix 
% Calculate the maximum range in the X coordinate
range = size(ImageA);  
range = range(1,2); 

 for IPs = 1:length(CPS)
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

for IPs = 1:length(CPS)
figure(1);
plot(EpilinesA(IPs).fig(1,:),EpilinesA(IPs).fig(2,:),'r',CPS(1,1,IPs),CPS(2,1,IPs),'g+'); 
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
hold on 
figure(2);
plot(EpilinesB(IPs).fig(1,:),EpilinesB(IPs).fig(2,:),'r',CPS(1,2,IPs),CPS(2,2,IPs),'g+'); 
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
hold on 
end


