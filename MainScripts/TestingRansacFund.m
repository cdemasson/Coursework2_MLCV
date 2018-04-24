% Testing RANSACFund 

%% Using MATLABs interest point detector 

% Set 1 to visualize and 0 else 
visualize = 1; 

%                   STEP 1:   Read stereo image pair  
I1 = imread(['FD1.jpeg']); 
I2 = imread(['FD1.jpeg']);
% Convert to grayscale.
I1gray = rgb2gray(I1);
I2gray = rgb2gray(I2);

if (visualize == 1)
figure;
imshowpair(I1, I2,'montage');
title('I1 (left); I2 (right)');
figure(2);
imshow(stereoAnaglyph(I1,I2));
title('Composite Image (Red - Left Image, Cyan - Right Image)');
end 

%                STEP 2:   Collect interest points 

blobs1 = detectSURFFeatures(I1gray, 'MetricThreshold', 2000);
blobs2 = detectSURFFeatures(I2gray, 'MetricThreshold', 2000);

if (visualize == 1)
figure;
imshow(I1);
hold on;
plot(selectStrongest(blobs1, 30));
title('Thirty strongest SURF features in I1');

figure;
imshow(I2);
hold on;
plot(selectStrongest(blobs2, 30));
title('Thirty strongest SURF features in I2');
end 

%               STEP 3:   Find point correspondences

[features1, validBlobs1] = extractFeatures(I1gray, blobs1);
[features2, validBlobs2] = extractFeatures(I2gray, blobs2);

% Match featues using SAD
indexPairs = matchFeatures(features1, features2, 'Metric', 'SAD','MatchThreshold', 5);

matchedPoints1 = validBlobs1(indexPairs(:,1),:);
matchedPoints2 = validBlobs2(indexPairs(:,2),:);

if (visualize == 1)
figure,
showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2);
legend('Putatively matched points in I1', 'Putatively matched points in I2');
end 

%               STEP 4:   Convert to my data form 

for i = 1 : length(matchedPoints1.Location) 
    CC(1:2,1:2,i) = [matchedPoints1.Location(i,:).', matchedPoints2.Location(i,:).']; 
end 

%%               STEP 5:   Eliminating the bad matches
RanFund = RANSACFund(CC,0.9);  % Input the corrosponding points and the threshold 
FAccuracy = Fund_Matrix_Accuracy(RanFund.FM,RanFund.m); 
fprintf(" The number of correctly matched points is %4.2f \n", length(RanFund.m));

I1Matches = [];
I2Matches = [];
for k = 1 : length(RanFund.m)
    I1Matches = [I1Matches; RanFund.m(:,1,k).']; 
    I2Matches = [I2Matches; RanFund.m(:,2,k).']; 
end 

if (visualize == 1)
figure;
showMatchedFeatures(I1, I2, I1Matches,I1Matches);
legend('Accepted points in Iimage A', 'Accepted points in Image B');
title('Best matched points obtained using RANSAC method') 
end 
