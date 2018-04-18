function [matching_points] = KNN(Train_BD, Test_BD, interest_points1, interest_points2, picture)

%This is KNN code, use to classify testing points, based on labelled
%training points. For example, if the KNN value is 5, each time a testing
%point is evaluated the five closest points will be collected. The testing
%point will then be assigned the modal label value of the five closest
%training points. 

% Here the training data is split into the coordinates and the labels. 
% Train_BD = boat_descriptors1;
 Train_BDL = 1:length(Train_BD); %The corrosponding labels of the training points 
 Train_BD = [Train_BD Train_BDL'];

% The testing data consists only of testing point coordinates with no label
% Test_BD = boat_descriptors2; 

% NB!!!! BEFORE RUNNING THE CODE ASSIGN TRAINING AND TESTING DATA 

% -------------------------------------------------------------------------
% <<<<<<<<<<<<<<<<<<<<<<<<<<<<< KNN >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% -------------------------------------------------------------------------
kNN = 10;                   %Number of neighbours considered
nb_bins = size(Train_BD,2)-1;
matching_points = zeros(100,4);
for n=1:size(matching_points,1)
    KKNN = zeros(kNN,2);        %[Distance, Label] Matrix 
    PREDICTION = zeros(2,3); 
    %Iterate through all test data 
    for i = 1 : length(Test_BD)     
        %Iterate through all train data
        %length(Train_BD)
        for k = 1 : length(Train_BD)
            %Point - Holds the distance between the current train and test data
            %points and the label of the train data point 
            L = 0;
            Xtest = Test_BD(i,:);
            Xtrain = Train_BD(k,:);
            for bin = 1:nb_bins
                L = L + (Xtest(1,bin)-Xtrain(1,bin))^2;
            end
            L = sqrt(L);
            point = [L,Train_BD(k,end)]; 

            %Initially populate KKNN with the first 5 points 
            if (k <= kNN) 
                KKNN(k,:) = point; 
            end 

            %Check if the distance between the current test point and the
            %current data point is less that any of the other stored shortest
            %distances
            if point(1,1) < max(KKNN(:,1))
                %Find the row that contains the largest distance 
                row = find(KKNN(:,1) == max(KKNN(:,1))); 
                %Just in case two of the distances are the same, take the first
                row = row(1,1); 
                %Replace the largest distance with the new distance/label 
                KKNN(row,1:2) = point; 
            end
        end 

        PREDICTION(i,:) = [i mode(KKNN(:,:))]; %[interest_testing_point_number Distance Label]
    end

    sorted_predict = sortrows(PREDICTION, 2);
    label = sorted_predict(1,3);
    iPt = sorted_predict(1,1);
    if label == 0 || iPt == 0
        break;
    end
    matching_points(n,:) = [interest_points1(label,:) interest_points2(iPt,:)];
    row_to_delete = find(Train_BD(:,end) == label);
    Train_BD(row_to_delete,:) = [];
    Test_BD(iPt,:) = [];
%     if PREDICTION(i,2) > 25
%         break;
%     end
end
    
figure(1);
imshow(picture(1).fig);
hold on;
length(matching_points);
for pts = 1:length(matching_points)
    plot(matching_points(pts,2), matching_points(pts,1), 'r+');
end


figure(2);
imshow(picture(2).fig);
hold on;
for pts = 1:length(matching_points)
    plot(matching_points(pts,4), matching_points(pts,3), 'r+');
end
    
end
