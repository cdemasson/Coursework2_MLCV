%% creation of the boat and tsukuba dataset
clear all; 
close all; 

for FIG = 1:6
    boat(FIG).fig = imread(['img' num2str(FIG) '.pgm']);
end

for FIG = 1:5
    tsukuba(FIG).fig = imread(['scene1.row3.col' num2str(FIG) '.ppm']);
end

%% Collecting 5 matching coordinates from two boat images and two tsukaba images
% David Has edited this code for Q3 

% In the boat sequence, let's click on 5 identical points on the 2
% pictures
Bc = zeros(2,2,5);      %Boat coordinates
Pictures = [1,2]; 
for PT= 1:5
    for FIG = Pictures
        figure(FIG);
        imshow(boat(FIG).fig);
        [Bc(1, FIG, PT), Bc(2, FIG, PT)] = ginput(1);
    end
end
%%
Tc = zeros(2,2,5);      %Tsukuba Coordinates
Pictures_T = [1,2]; 
for PT= 1:10
    for FIG = Pictures_T
        figure(FIG);
        imshow(tsukuba(FIG).fig);
        [Tc(1, FIG, PT), Tc(2, FIG, PT)] = ginput(1);
    end
end

%% Q1, 3a: Calculating the homography matrix (HA) 
HM = HomogMatrix(Bc); 

%% Q1, 3b: Calculating the fundamental matrix (FA)
FM = FundMatrix(Tc); 

%% Q1, 3c: Homographic point projection and accruacy  

Accuracy = HomogAccuracy(Bc,HM);
%%  Q1, 3d: Epipolar line generation and accuracy 
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

% Generating the epipolar line in image B from the corrosponding points in
% image A. Where point in image A (x,y) and point in image B (x',y') 
%line' = FM*x. Then calculate the distance between point (x',y') and line'

% I think line outputs (A;B;C), where Ax+By+C = 0 
LineB = FM*[Tc(:,1,1);1]; 
xb = 1:range; 
yb = (-LineB(1,1)*x-LineB(3,1))/LineB(2,1); 
figure(2);
imshow(tsukuba(2).fig)
hold on 
plot(xb,yb,'r',Tc(1,2,1),Tc(2,2,1),'b+')
set(findall(gca, 'Type', 'Line'),'LineWidth',2);



%**************************************************************************
%% <<<<<<<<<<<<<<<<<<<<<<<<<<< Functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%**************************************************************************


%**************************************************************************
%             FUNCTION 1: Calculating the homography matrix 

function HM = HomogMatrix(CC)

% CC holds the corrosponding coordinates of the two images 
%                        [X1 X2;
% CC is of the form CC =  Y1 Y2]; 
% The third input for CC determines the image number. I.e. for coordinate
% X2 of image 3:  CC(1,2,3) 

% Finding the homogenous matrix using SVD 
% This will be done using 10 matched points on the two images 

%Building the A matrix, by vertically concatenating the 10 equations from
%the 5 different corrosponding points
A = [];     
    for Pt = 1 : length(CC)
        Ax = [-CC(1,1,Pt),-CC(2,1,Pt),-1,0,0,0,CC(1,2,Pt)*CC(1,1,Pt),CC(1,2,Pt)*CC(2,1,Pt),CC(1,2,Pt)];
        Ay = [0,0,0,-CC(1,1,Pt),-CC(2,1,Pt),-1,CC(2,2,Pt)*CC(1,1,Pt),CC(2,2,Pt)*CC(2,1,Pt),CC(2,2,Pt)];
        A = [A;Ax;Ay];
    end
    
    %Compute the singular value decomposition
[~,~,V] = svd(A);
h = V(:,9)/V(9,9); 
HM = [h(1:3,1)';h(4:6,1)';h(7:9,1)'];    % Output the homography matrix  
end 

%**************************************************************************
%              FUNCTION 2: Calculating the fundamental matrix 

function FM = FundMatrix(CC) 
% The input variable CC is defined in Function 1 above. 
    B = [];     
    for PT = 1 : length(CC) 
        Bx = [CC(1,1,PT)*CC(1,2,PT),CC(1,2,PT)*CC(2,1,PT),CC(1,2,PT),CC(1,1,PT)*CC(2,2,PT),CC(2,1,PT)*CC(2,2,PT),CC(2,2,PT),CC(1,1,PT),CC(2,1,PT),1];
        B = [B;Bx]; 
    end 

    %Compute the singular value decomposition
    [~,~,V] = svd(B);
    f = V(:,9)/V(9,9); 
    FM = [f(1:3,1)';f(4:6,1)';f(7:9,1)'];  % Output the fundamental matrix
end 

%**************************************************************************
%              FUNCTION 3: Homographic point projection and accuracy

function Accuracy = HomogAccuracy(CC,HM)
% This function calculates the accuracy - In average pixel length - of two 
% images, image A and image B. It does so by estimating the corresponding
% coordinates of an interest point in image A, using the inverse of the
% homographic matrix and the coordinates in B: A' = H\B
% It then calcualtes the distance between the estimated coordinates of A' 
% and the actual coordinates of A. 

% NB: This means the accuracy is subject to poor and inaccuracy interest
% point selection if manually selected.

A_Est = zeros(2,5);     % Estimation of points in image A
Dist = zeros(1,5);      % Initialise a distance vector for accuracy

% Iterate through the 5 points 
for Pt = 1 : length(CC)
    Atemp= HM\[CC(:,2,Pt);1]; 
    A_Est(:,Pt) = Atemp(1:2,1);
    Dist(1,Pt) = sqrt((Atemp(1,1)-CC(1,1,Pt))^2+(Atemp(2,1)-CC(2,1,Pt))^2);
end 

Accuracy = sum(Dist)/length(CC); 
fprintf(" The average homographic accuracy is %4.2f pixels \n", Accuracy); 
end 

%**************************************************************************
%              FUNCTION 4: Epipole and Epipolar Line 

function Epipolar = EpiLine(FM,Point,B2A,range)
% FM is the fundamental matrix between image A and B. Point is the Point 
% in image A or B. If the epipole in image A is required then B2A = true,
% if the epipole in image B is required then B2A = false. 
% range is the domain of the image (Full X domain) 
if (B2A == false)
    FM = FM.';          % Take the transpose when projecting from A to B 
end 

% Calculate the Epipole in the image 
[~,~,V] = svd(FM);
Epipole = V(:,3)/V(3,3);
Epipole = Epipole(1:2,1);     %Only use the x,y coordinates

%Create a line for the first point in image A 
% Point = (X1,Y1) 
% Epipole = (X2,Y2)
x = 1 : range; 
y = ((Epipole(2,1)-Point(2,1))/(Epipole(1,1)-Point(1,1)))*(x-Point(1,1)) + Point(2,1); 
Epipolar.x = x; 
Epipolar.y = y; 
Epipolar.e = Epipole; 
end 









