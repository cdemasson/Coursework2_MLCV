% RANSAC Applied to the homography matrix 
% This function uses the RANSAC method to eliminate bad matches and
% calculate the best homography matrix using the good matches

function RanFund = RANSACHFund(CC,Thres)
% This function takes in the corresponding coordinates in the same form as
% all of the other functions, as a multi-dimensional matrix where the third
% dimension is the number of the match point
% ***********************************************************************
Threshold = Thres;      % Select the pixel threshold used to evaluate matches
UniquePt = 1;           % Initialise the unique point holder

% Perform 500 random samples 
    for I = 1 : 5000
        % Step 1: Select 4 random corresponding points
        RandMatches = CC(:,:,randperm(length(CC),9)); 
        % Step 2: Calculate the homography matrix, using the RandMatches 
        FM = FundMatrix(RandMatches); 
        % Step 3: Iterate through all points and calculate and calculate
        % the distance between the mapped point and actual point
        for Pt = 1 : length(CC) 
             % Get the corrosponding point in image B
            PtbX = CC(1,2,PT);              
            PtbY = CC(2,2,PT);
            % LineB outputs (A;B;C), where Ax+By+C = 0 
            LineB = FM*[CC(:,1,PT);1];       % Calculate the epipolar in image B
            A = LineB(1,1);
            B = LineB(2,1);
            C = LineB(3,1);
            % Calculate the distance between the point and the line in image B
            Dist = abs(A*PtbX+B*PtbY+C)/(sqrt(A^2+B^2)); 
            if (Dist < Threshold) 
                % Store the match points as a row matrix of the form:  
                % [x1 y1 x2 y2], if the point falls within the threshold
                inliersTemp(UniquePt,:) = [CC(:,1,Pt).', CC(:,2,Pt).']; 
                UniquePt = UniquePt +1; % Increment UniquePt 
            end 
        end 
    end 
    
    try 
        % Select only the unique match points 
        UniquePnts = unique(inliersTemp,'rows'); 
        % Convert them back to struct form 
        for i = 1: length(UniquePnts)
        RanFund.m(1:2,1:2,i) =  [UniquePnts(i,1:2).',UniquePnts(i,3:4).']; 
        end 
        % Calculate the best homography matrix based on the selected
        % matched corresponding points
        RanFund.HM = HomogMatrix(RanFund.m); 
    catch 
        disp("!!!!!! Not enough matches generated !!!!!!") 
        pause()
    end 
end 






