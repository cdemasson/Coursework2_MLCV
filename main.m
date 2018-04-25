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

%% Display homography matrices with corresponding interest_points pic scaled 1 - 1/2
pt = 1;
for i = 1:length(chimney_interest_points1)
    x = round(chimney_interest_points1(i,1)/2);
    y = round(chimney_interest_points1(i,2)/2);
    if x > 498
        x = 498;
    end
    index = find(chimney_interest_points2(:,1) == x & chimney_interest_points2(:,2) < y+1 & chimney_interest_points2(:,2) > y-1);
    if index ~= 0 
        chim_match(pt,:) = [chimney_interest_points1(i,:) chimney_interest_points2(index(1),:)];
        pt = pt + 1;
    end
end

chim_match12 = convMatrix(chim_match);
chim_homo12 = HomogMatrix(chim_match12)
chim_acc12 = HomogAccuracy(chim_match12, chim_homo12);
%%
chim_ransac12 = RANSACHomog(chim_match12, 1.5);
chim_acc12 = HomogAccuracy(chim_ransac12.m, chim_ransac12.HM);
link_inoutliers(chimney, 1, 2, chim_match);

%% Display homography matrices with corresponding interest_points pic scaled 1 - 1/3
pt = 1;
for i = 1:length(chimney_interest_points1)
    x = round(chimney_interest_points1(i,1)/3);
    y = round(chimney_interest_points1(i,2)/3);
    if x > 331
        x = 331;
    end
    index = find(chimney_interest_points3(:,1) == x & chimney_interest_points3(:,2) < y+1 & chimney_interest_points3(:,2) > y-1);
    if index ~= 0 
        chim_match1(pt,:) = [chimney_interest_points1(i,:) chimney_interest_points3(index(1),:)];
        pt = pt + 1;
    end
end

chim_match13 = convMatrix(chim_match1);
%% without RANSAC
chim_homo13 = HomogMatrix(chim_match13)
chim_acc13 = HomogAccuracy(chim_match13, chim_homo13);
%% with RANSAC
chim_ransac13 = RANSACHomog(chim_match13, 1.5);
chim_acc13 = HomogAccuracy(chim_ransac13.m, chim_ransac13.HM);

%% Display matches
figure(1);
title('Matching points on picture scale 1');
imshow(chimney(1).fig);
hold on;
for pts = 1:size(chim_match,1)
    plot(chim_match(pts,2), chim_match(pts,1), 'r+');
end
figure(2);
title('Matching points on picture scale 1/2');
imshow(chimney(2).fig);
hold on;
for pts = 1:size(chim_match,1)
    plot(chim_match(pts,4), chim_match(pts,3), 'r+');
end
    
%%
figure(1)
title('Matching points on picture scale 1');
imshow(chimney(1).fig);
hold on;
for pts = 1:size(chim_match1,1)
    plot(chim_match1(pts,2), chim_match1(pts,1), 'r+');
end
figure(2)
title('Matching points on picture scale 1/3');
imshow(chimney(3).fig);
hold on;
for pts = 1:size(chim_match1,1)
    plot(chim_match1(pts,4), chim_match1(pts,3), 'r+');
end

% end of Q2.1.a

%% Q2.1.b

for FIG = 1:4
    chimney(FIG).fig = imread(['chimney' num2str(FIG) '.JPG']);
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

%%
figure(3);
chimney_interest_points3 = my_harris_detector(chimney(3).fig, alpha, trshld, r);
figure(4);
chimney_interest_points4 = my_harris_detector(chimney(4).fig, alpha, trshld, r);

%% Get chimney descriptors
chimney_descriptors1 = colour_descriptor(chimney(1).fig, chimney_interest_points1);
chimney_descriptors2 = colour_descriptor(chimney(2).fig, chimney_interest_points2);
%%
chimney_descriptors3 = colour_descriptor(chimney(3).fig, chimney_interest_points3);
chimney_descriptors4 = colour_descriptor(chimney(4).fig, chimney_interest_points4);

%% KNN search
chim_match_pts12 = KNN(chimney_descriptors1, chimney_descriptors2, chimney_interest_points1, chimney_interest_points2, chimney);

%%
chim_match_pts13 = KNN(chimney_descriptors1, chimney_descriptors3, chimney_interest_points1, chimney_interest_points3, chimney);
chim_match_pts14 = KNN(chimney_descriptors1, chimney_descriptors4, chimney_interest_points1, chimney_interest_points4, chimney);

%% homography matrix
chimney_12_conv = convMatrix(chim_match_pts12);
chimney_12_homog = HomogMatrix(chimney_12_conv)
HAerror12 = HomogAccuracy(chimney_12_conv, chimney_12_homog);
%%
chimney_12_ransac = RANSACHomog(chimney_12_conv, 10);
HAerror12 = HomogAccuracy(chimney_12_ransac.m, chimney_12_ransac.HM);
%%
ransac = link_inoutliers(chimney, 1, 2, chim_match_pts12);
%%
chimney_13_conv = convMatrix(chim_match_pts13);
chimney_13_homog = HomogMatrix(chimney_13_conv);
HAerror13 = HomogAccuracy(chimney_13_conv, chimney_13_homog);
%%
chimney_14_conv = convMatrix(chim_match_pts14);
chimney_14_homog = HomogMatrix(chimney_14_conv);
HAerror14 = HomogAccuracy(chimney_14_conv, chimney_14_homog);

%% gray version
for i = 1:4
    chimney_gray(i).fig = rgb2gray(chimney(i).fig);
end
%% Harris feature detector for chimney images
close all;
alpha = 0.05;
trshld = 1;
r = 6;
figure(1);
chimney_interest_points1 = my_harris_detector(chimney_gray(1).fig, alpha, trshld, r);
figure(2);
chimney_interest_points2 = my_harris_detector(chimney_gray(2).fig, alpha, trshld, r);
% descriptors
chimney_descriptors1 = gray_descriptor(chimney_gray(1).fig, chimney_interest_points1);
chimney_descriptors2 = gray_descriptor(chimney_gray(2).fig, chimney_interest_points2);
%%
chim_match_pts12 = KNN(chimney_descriptors1, chimney_descriptors2, chimney_interest_points1, chimney_interest_points2, chimney_gray);
% compute homog with ransac
chimney_12_conv = convMatrix(chim_match_pts12);
ransac = link_inoutliers(chimney, 1, 2, chim_match_pts12);

% *************************************************************************
%%                MANUALLY MATCHING INTEREST POINTS
% *************************************************************************

Cc = zeros(5,2);      % Chimney coordinates
Pictures = [1,2];       % Select the pictures to compare 
for PT= 1:10
    for FIG = Pictures
        figure(FIG);
        imshow(chimney(FIG).fig);
        if FIG == 1
            [Cc(PT,2), Cc(PT,1)] = ginput(1);
        else 
            [Cc(PT,4), Cc(PT,3)] = ginput(1);
        end
    end
end
%% Q2.1.c
Cconv = convMatrix(Cc);
chimney_homog = HomogMatrix(Cconv)
HAerror12 = HomogAccuracy(Cconv, chimney_homog);
%%
ransac = link_inoutliers(chimney, 1, 2, Cc);
HomogAccuracy(ransac.m, ransac.HM)

%%
figure(1);
imshow(chimney(1).fig);
hold on;
length(Cc);
for pts = 1:length(Cc)
    plot(Cc(pts,2), Cc(pts,1), 'r+');
end


%% Testing the gradient descriptor function
close all;
alpha = 0.05;
trshld = 1;
r = 6;
figure(1);
chimIPts1 = my_harris_detector(chimney_gray(1).fig, alpha, trshld, r);
figure(2);
chimIPts2 = my_harris_detector(chimney_gray(2).fig, alpha, trshld, r);
%%
for pts = size(chimIPts1,1):-1:1
    if chimIPts1(pts,1) < 9 || chimIPts1(pts,1) > 326-8 || chimIPts1(pts,2) < 8 || chimIPts1(pts,2) > 491-9
        chimIPts1(pts,:) = [];
    end
end
for pts = size(chimIPts2,1):-1:1
    if chimIPts2(pts,1) < 9 || chimIPts2(pts,1) > 326-8 || chimIPts2(pts,2) < 8 || chimIPts2(pts,2) > 491-9
        chimIPts2(pts,:) = [];
    end
end
%% descriptors
chimDes1 = gradient_descriptor(chimney_gray(1).fig, chimIPts1);
%%
labelTmp = chimDes1(1,end);
for row = 2:size(chimDes1,1)
    label = chimDes1(row,end);
    if label == labelTmp
        chimIPts1 = [chimIPts1(1:row-1,:); chimIPts1(row-1,:); chimIPts1(row:end,:)];
    end
    labelTmp = label;
end
%%
chimDes2 = gradient_descriptor(chimney_gray(2).fig, chimIPts2);
%%
labelTmp = chimDes2(1,end);
for row = 2:size(chimDes2,1)
    label = chimDes2(row,end);
    if label == labelTmp
        chimIPts2 = [chimIPts2(1:row-1,:); chimIPts2(row-1,:); chimIPts2(row:end,:)];
    end
    labelTmp = label;
end
%% KNN search
chim_match_pts12 = KNN(chimDes1, chimDes2, chimIPts1, chimIPts2, chimney_gray);

%% homography matrix
chimney_12_conv = convMatrix(chim_match_pts12);
chimney_12_homog = HomogMatrix(chimney_12_conv)
HAerror12 = HomogAccuracy(chimney_12_conv, chimney_12_homog);
%%
chimney_12_ransac = RANSACHomog(chimney_12_conv, 10);
HAerror12 = HomogAccuracy(chimney_12_ransac.m, chimney_12_ransac.HM);
%%
ransac = link_inoutliers(chimney_gray, 1, 2, chim_match_pts12);


