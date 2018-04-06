%% creation of the boat and tsukuba dataset
clear all;

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
% Q1, 3a 
% Finding the homogenous matrix using SVD 
% This will be done using 10 matched points on the two images 

%Building the A matrix, by vertically concatenating the 10 equations from
%the 5 different corrosponding points

A = [];     %Initialise the matrix
for Pt = 1 : length(Bc) 
    Ax = [-Bc(1,1,Pt),-Bc(2,1,Pt),-1,0,0,0,Bc(1,2,Pt)*Bc(1,1,Pt),Bc(1,2,Pt)*Bc(2,1,Pt),Bc(1,2,Pt)];
    Ay = [0,0,0,-Bc(1,1,Pt),-Bc(2,1,Pt),-1,Bc(2,2,Pt)*Bc(1,1,Pt),Bc(2,2,Pt)*Bc(2,1,Pt),Bc(2,2,Pt)];
    A = [A;Ax;Ay]; 
end 

%Compute the singular value decomposition
[U,S,V] = svd(A);
h = V(:,9)/V(9,9); 
h = [h(1:3,1);h(4:6,1);h(7:9,1)];

% Q1, 3b 
% Q1, 3c 
% Q1, 3d 



















