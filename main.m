%% creation of the boat and tsukuba dataset
clear all; 
close all; 

% *************************************************************************
%%                         READING ALL IMAGES 
% *************************************************************************

for FIG = 1:6
    % READING BOAT IMAGES
    boat(FIG).fig = imread(['img' num2str(FIG) '.pgm']);
end

for FIG = 1:5
    % READING TSUKUBA IMAGES
    tsukuba(FIG).fig = imread(['scene1.row3.col' num2str(FIG) '.ppm']);
end

for FIG = 1:4
    % READING LION IMAGES
    temp = imread(['Lion' num2str(FIG) '.pgm']);
    lion(FIG).fig = imrotate(temp,-90); 
end

clear vars 

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


%% LION SEQUENCE 
Ln = zeros(2,2,4);      % lion Coordinates
Pictures_T = [1,2];     % Select the pictures to compare 
for PT= 1:10
    for FIG = Pictures_T
        figure(FIG);
        imshow(lion(FIG).fig);
        [Ln(1, FIG, PT), Ln(2, FIG, PT)] = ginput(1);
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
Point = Tc(:,1,1); 
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

% Determining the projected epipolar line in image B, from a projection of
% a point in image A using Line' = FM*X. 
% Once off calculation to plot this projected epipolar line on image B
LineB = FM*[Tc(:,1,1);1]; 
xb = 1:range; 
yb = (-LineB(1,1)*x-LineB(3,1))/LineB(2,1); 
figure(2);
imshow(tsukuba(2).fig)
hold on 
plot(xb,yb,'r',Tc(1,2,1),Tc(2,2,1),'b+')
set(findall(gca, 'Type', 'Line'),'LineWidth',2);

% Determining the fundamental accuracy using the average distance between
% points in B and the epipolar lines in B generated using the projection of
% a point in A 
FA = Fund_Matrix_Accuracy(FM,Tc); 



% *************************************************************************
%%                 Q2.2 Stereo Vision (Using images FD: LION) 
% *************************************************************************

%%  Q2.2a


FM = FundMatrix(Ln);                % Estimating the fundamental matrix 
FA = Fund_Matrix_Accuracy(FM,Ln);   % Estimating the accuracy 

%%  Q2.2b

% Calculate the maximum range in the X coordinate
range = size(lion(1).fig);  
range = range(1,2); 
IPs = 5; 
PointA = Ln(:,1,IPs);
PointB = Ln(:,2,IPs); 
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
imshow(lion(1).fig)
hold on 
plot(xA,yA,'r',EpipoleA(1,1),EpipoleA(2,1),'b+', PointA(1,1), PointA(2,1),'g+'); 
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
legend("Epipolar line", "Epipole", "Interest point"); 

% Plotting 
figure(2);
imshow(lion(2).fig)
hold on 
plot(xB,yB,'r',EpipoleB(1,1),EpipoleB(2,1),'b+', PointB(1,1), PointB(2,1),'g+'); 
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
legend("Epipolar line", "Epipole", "Interest point"); 














