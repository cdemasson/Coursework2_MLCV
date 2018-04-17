%% creation of the boat and tsukuba dataset
clear all;

for FIG = 1:6
    boat(FIG).fig = imread(['img' num2str(FIG) '.pgm']);
end

for FIG = 1:5
    tsukuba(FIG).fig = imread(['scene1.row3.col' num2str(FIG) '.ppm']);
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

%% Harris feature detector for boat images
alpha = 0.04;
trshld = 10;
r = 6;
figure(1);
boat_interest_points1 = my_harris_detector(boat(1).fig, alpha, trshld, r);
figure(2);
boat_interest_points2 = my_harris_detector(boat(2).fig, alpha, trshld, r);

%% SQUARE PICTURE
alpha = 0.04;
trshld = 5;
r = 6;
figure(1);
square_interest_points = my_harris_detector(squareTest, alpha, trshld, r);

%% Harris feature detector for tsukuba images
%the tsukuba feature detector isn't very good because it only uses the 
%red component of the three dimensional (RGB) picture
alpha = 0.04;
trshld = 1;
r = 6;
figure(1);
tsukuba_interest_points1 = my_harris_detector(tsukuba(1).fig, alpha, trshld, r);
figure(2);
tsukuba_interest_points2 = my_harris_detector(tsukuba(2).fig, alpha, trshld, r);

%% Get boat descriptors
boat_descriptors1 = gray_descriptor(boat(1).fig, boat_interest_points1);
boat_descriptors2 = gray_descriptor(boat(2).fig, boat_interest_points2);

%% Get tsukuba descriptors
tsukuba_descriptors1 = colour_descriptor(tsukuba(1).fig, tsukuba_interest_points1);
tsukuba_descriptors2 = colour_descriptor(tsukuba(2).fig, tsukuba_interest_points2);

%% KNN search
boat_match = KNN(boat_descriptors1, boat_descriptors2, boat_interest_points1, boat_interest_points2, boat);
%%
tsukuba_match = KNN(tsukuba_descriptors1, tsukuba_descriptors2, tsukuba_interest_points1, tsukuba_interest_points2, tsukuba);