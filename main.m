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
sigma = 3;
alpha = 0.03;
trshld = 45;
r = 6;
figure(1);
boat_interest_points = my_harris_detector(boat(1).fig, sigma, alpha, trshld, r);

%% Harris feature detector for tsukuba images
%the tsukuba feature detector isn't very good because it only uses the 
%red component of the three dimensional (RGB) picture
clear tsukuba_interest_points;
sigma = 3;
alpha = 0.03;
trshld = 20;
r = 6;
figure(2);
tsukuba_interest_points = my_harris_detector(tsukuba(1).fig, sigma, alpha, trshld, r);

%% Get boat descriptors
boat_descriptors = gray_descriptor(boat(1).fig, boat_interest_points);

%% Get tsukuba descriptors
tsukuba_descriptors = colour_descriptor(tsukuba(1).fig, tsukuba_interest_points);