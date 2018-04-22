% RANSAC Applied to the homography matrix 
% This function uses the RANSAC method to eliminate bad matches and
% calculate the best homography matrix using the good matches

function RanHomog = RANSACHomog(CC,Thres)
% This function takes in the corresponding coordinates in the same form as
% all of the other functions, as a multi-dimensional matrix where the third
% dimension is the number of the match point
% ***********************************************************************

MostAcceptedPoints = 0;     % Initialise the number of accepted points
BestHomog = zeros(3,3); % Initialise a homography matrix  

% Perform a number of random samples 
    for I = 1 : 1000
        % Initialse the number of accepted points 
        CurrentPoints = 0; 
        % Step 1: Select 4 random corresponding points
        RandMatches = CC(:,:,randperm(length(CC),5)); 
        % Step 2: Calculate the homography matrix, using the RandMatches 
        HM = HomogMatrix(RandMatches); 
        % Step 3: Iterate through all points and calculate and calculate
        % the distance between the mapped point and actual point
        for Pt = 1 : length(CC) 
            Atemp= HM\[CC(:,2,Pt);1]; % Calculate the mapped point A
            Dist = sqrt((Atemp(1,1)-CC(1,1,Pt))^2+(Atemp(2,1)-CC(2,1,Pt))^2);
            if (Dist < Thres) 
                % Increment the number of accepted points 
                CurrentPoints = CurrentPoints + 1; 
            end 
        end
        
        % Check if the homography matrix must be updated 
        if (CurrentPoints > MostAcceptedPoints) 
            MostAcceptedPoints = CurrentPoints; 
            BestHomog = HM; 
        end    
    end 
        % Assign the homography matrix 
        RanHomog.HM = BestHomog; 
        % Recalculate the best matches using the best Homography matrix 
        Counter = 1; 
        for Pt = 1 : length(CC) 
            Atemp= RanHomog.HM\[CC(:,2,Pt);1]; % Calculate the mapped point A
            Dist = sqrt((Atemp(1,1)-CC(1,1,Pt))^2+(Atemp(2,1)-CC(2,1,Pt))^2);
            if (Dist < Thres) 
                RanHomog.m(1:2,1:2,Counter) = [CC(:,1,Pt), CC(:,2,Pt)]; 
                Counter = Counter +1; % Increment UniquePt 
            end 
        end 
end 



