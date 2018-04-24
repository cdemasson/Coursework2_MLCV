% RANSAC Applied to the fundamental matrix 
% This function uses the RANSAC method to eliminate bad matches and
% calculate the best fundamental matrix using the good matches

function RanFund = RANSACFund(CC,Thres)
% This function takes in the corresponding coordinates in the same form as
% all of the other functions, as a multi-dimensional matrix where the third
% dimension is the number of the match point
% ***********************************************************************

MostAcceptedPoints = 0;     % Initialise the number of accepted points
BestFund = zeros(3,3); % Initialise a homography matrix  

% Perform a number of random samples 
    for I = 1 : 1000
        % Initialse the number of accepted points 
        CurrentPoints = 0; 
        % Step 1: Select 4 random corresponding points
        RandMatches = CC(:,:,randperm(length(CC),9)); 
        % Step 2: Calculate the homography matrix, using the RandMatches 
        FM = FundMatrix(RandMatches); 
        % Step 3: Iterate through all points and calculate and calculate
        % the distance between the mapped point and actual point
        for Pt = 1 : length(CC) 
             % Get the corrosponding point in image B
            PtbX = CC(1,2,Pt);              
            PtbY = CC(2,2,Pt);
            % LineB outputs (A;B;C), where Ax+By+C = 0 
            LineB = FM*[CC(:,1,Pt);1];       % Calculate the epipolar in image B
            A = LineB(1,1);
            B = LineB(2,1);
            C = LineB(3,1);
            % Calculate the distance between the point and the line in image B
            Dist = abs(A*PtbX+B*PtbY+C)/(sqrt(A^2+B^2)); 
            if (Dist < Thres) 
                % Increment the number of accepted points 
                CurrentPoints = CurrentPoints + 1; 
            end 
        end
        
        % Check if the fundamental matrix must be updated 
        if (CurrentPoints > MostAcceptedPoints) 
            MostAcceptedPoints = CurrentPoints; 
            BestFund = FM; 
        end    
    end 
        % Assign the homography matrix 
        RanFund.FM = BestFund; 
        % Recalculate the best matches using the best Homography matrix 
        Counter = 1; 
        for Pt = 1 : length(CC) 
            % Get the corrosponding point in image B
            PtbX = CC(1,2,Pt);              
            PtbY = CC(2,2,Pt);
            % LineB outputs (A;B;C), where Ax+By+C = 0 
            LineB = RanFund.FM*[CC(:,1,Pt);1];       % Calculate the epipolar in image B
            A = LineB(1,1);
            B = LineB(2,1);
            C = LineB(3,1);
            % Calculate the distance between the point and the line in image B
            Dist = abs(A*PtbX+B*PtbY+C)/(sqrt(A^2+B^2)); 
            if (Dist < Thres) 
                RanFund.m(1:2,1:2,Counter) = [CC(:,1,Pt), CC(:,2,Pt)]; 
                Counter = Counter +1; % Increment UniquePt 
            end 
        end 
end 