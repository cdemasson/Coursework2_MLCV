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

Tc = zeros(2,2,5);      %Tsukuba Coordinates
Pictures_T = [1,2]; 
for PT= 1:5
    for FIG = Pictures_T
        figure(FIG);
        imshow(tsukuba(FIG).fig);
        [Tc(1, FIG, PT), Tc(2, FIG, PT)] = ginput(1);
    end
end

%% David's work starts here

%         Q1, 3a: Calculating the homography matrix (HA) 

% Finding the homogenous matrix using SVD 
% This will be done using 10 matched points on the two images 

%Building the A matrix, by vertically concatenating the 10 equations from
%the 5 different corrosponding points

A = [];     
for Pt = 1 : length(Bc) 
    Ax = [-Bc(1,1,Pt),-Bc(2,1,Pt),-1,0,0,0,Bc(1,2,Pt)*Bc(1,1,Pt),Bc(1,2,Pt)*Bc(2,1,Pt),Bc(1,2,Pt)];
    Ay = [0,0,0,-Bc(1,1,Pt),-Bc(2,1,Pt),-1,Bc(2,2,Pt)*Bc(1,1,Pt),Bc(2,2,Pt)*Bc(2,1,Pt),Bc(2,2,Pt)];
    A = [A;Ax;Ay]; 
end 

%Compute the singular value decomposition
[~,~,V] = svd(A);
h = V(:,9)/V(9,9); 
HA = [h(1:3,1)';h(4:6,1)';h(7:9,1)'];         % The homography matrix 

%         Q1, 3b: Calculating the fundemental matrix (FA)
B = [];     
for PT = 1 : length(Tc) 
    Bx = [Tc(1,1,PT)*Tc(1,2,PT),Tc(1,2,PT)*Tc(2,1,PT),Tc(1,2,PT),Tc(1,1,PT)*Tc(2,2,PT),Tc(2,1,PT)*Tc(2,2,PT),Tc(2,2,PT),Tc(1,1,PT),Tc(2,1,PT),1];
    B = [B;Bx]; 
end 

%Compute the singular value decomposition
[~,~,V] = svd(B);
f = V(:,9)/V(9,9); 
FA = [f(1:3,1)';f(4:6,1)';f(7:9,1)'];          % The fundamental matrix

%          Q1, 3c: Homographic point projection and accruacy  

A_Est = zeros(2,5);     % Estimation of points in image A
Dist = zeros(1,5);      % Initialise a distance vector for accuracy

% Iterate through the 5 points 
for Pt = 1 : length(Bc)
    Atemp= HA\[Bc(:,2,Pt);1]; 
    A_Est(:,Pt) = Atemp(1:2,1);
    Dist(1,Pt) = sqrt((Atemp(1,1)-Bc(1,1,Pt))^2+(Atemp(2,1)-Bc(2,1,Pt))^2);
end 

Accuracy = sum(Dist)/length(Bc); 
fprintf(" The average accuracy is %4.2f pixels \n", Accuracy); 

%          Q1, 3d: Epipolar line generation and accuracy 



















