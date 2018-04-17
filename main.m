%% creation of the boat and tsukuba dataset
clear all;
close all;

for FIG = 1:6
    boat(FIG).fig = imread(['img' num2str(FIG) '.pgm']);
end

for FIG = 1:5
    tsukuba(FIG).fig = imread(['scene1.row3.col' num2str(FIG) '.ppm']);
end

for FIG = 1:4
    chimney(FIG).fig = imread(['chimney' num2str(FIG) '.JPG']);
end

%% let's register some coordinates
% in the tsubuka sequence, let's click on 10 identical points on the 5
% pictures
tsubuka_coor = zeros(2,5,10);
for PT=1:10
    for FIG=1:5
        figure(FIG);
        image(tsukuba(FIG).fig);
        [tsubuka_coor(1, FIG, PT), tsubuka_coor(2, FIG, PT)] = ginput(1);
    end
end

%%******************************************************
%%%%%%%%%%%%%%%%%%%% BOAT SEQUENCE %%%%%%%%%%%%%%%%%%%%%
%%******************************************************
%% Harris feature detector for boat images
close all;
alpha = 0.04;
trshld = 10;
r = 6;
figure(1);
boat_interest_points1 = my_harris_detector(boat(1).fig, alpha, trshld, r);
figure(2);
boat_interest_points2 = my_harris_detector(boat(2).fig, alpha, trshld, r);

%% Get boat descriptors
boat_descriptors1 = gray_descriptor(boat(1).fig, boat_interest_points1);
boat_descriptors2 = gray_descriptor(boat(2).fig, boat_interest_points2);

%% KNN search
boat_match = KNN(boat_descriptors1, boat_descriptors2, boat_interest_points1, boat_interest_points2, boat);

%%*********************************************************
%%%%%%%%%%%%%%%%%%%% TSUKUBA SEQUENCE %%%%%%%%%%%%%%%%%%%%%
%%*********************************************************
%% Harris feature detector for tsukuba images
close all;
alpha = 0.04;
trshld = 1;
r = 6;
figure(1);
tsukuba_interest_points1 = my_harris_detector(tsukuba(1).fig, alpha, trshld, r);
figure(2);
tsukuba_interest_points2 = my_harris_detector(tsukuba(2).fig, alpha, trshld, r);

%% Get tsukuba descriptors
tsukuba_descriptors1 = colour_descriptor(tsukuba(1).fig, tsukuba_interest_points1);
tsukuba_descriptors2 = colour_descriptor(tsukuba(2).fig, tsukuba_interest_points2);

%%
tsukuba_match = KNN(tsukuba_descriptors1, tsukuba_descriptors2, tsukuba_interest_points1, tsukuba_interest_points2, tsukuba);

%% ********************************************************
%%%%%%%%%%%%%%%%%%%% CHIMNEY SEQUENCE %%%%%%%%%%%%%%%%%%%%%
%%*********************************************************
%Q2.1.a
for FIG = 1:3
    chimney(FIG).fig = imread(['size-' num2str(FIG) '.JPG']);
end

%% Harris feature detector for chimney images
close all;
alpha = 0.05;
trshld = 1;
r = 6;
figure(1);
chimney_interest_points1 = my_harris_detector(chimney(1).fig, alpha, trshld, r);
figure(2);
chimney_interest_points2 = my_harris_detector(chimney(2).fig, alpha, trshld, r);
figure(3);
chimney_interest_points3 = my_harris_detector(chimney(3).fig, alpha, trshld, r);

%% Get chimney descriptors
chimney_descriptors1 = colour_descriptor(chimney(1).fig, chimney_interest_points1);
chimney_descriptors2 = colour_descriptor(chimney(2).fig, chimney_interest_points2);
chimney_descriptors3 = colour_descriptor(chimney(3).fig, chimney_interest_points3);

%% KNN search
chimney_match = KNN(chimney_descriptors1, chimney_descriptors2, chimney_interest_points1, chimney_interest_points2, chimney);
%%
chimney_match = KNN(chimney_descriptors1, chimney_descriptors3, chimney_interest_points1, chimney_interest_points3, chimney);


