%**************************************************************************
%             FUNCTION 1: Calculating the homography matrix 

function HM = HomogMatrix(CC)

% CC holds the corrosponding coordinates of the two images 
%                        [X1 X2;
% CC is of the form CC =  Y1 Y2]; 
% The third input for CC determines the image number. I.e. for coordinate
% X2 of image 3:  CC(1,2,3) 

% Finding the homogenous matrix using SVD 
% This will be done using 10 matched points on the two images 

%Building the A matrix, by vertically concatenating the 10 equations from
%the 5 different corrosponding points
A = [];     
    for Pt = 1 : length(CC)
        Ax = [-CC(1,1,Pt),-CC(2,1,Pt),-1,0,0,0,CC(1,2,Pt)*CC(1,1,Pt),CC(1,2,Pt)*CC(2,1,Pt),CC(1,2,Pt)];
        Ay = [0,0,0,-CC(1,1,Pt),-CC(2,1,Pt),-1,CC(2,2,Pt)*CC(1,1,Pt),CC(2,2,Pt)*CC(2,1,Pt),CC(2,2,Pt)];
        A = [A;Ax;Ay];
    end
    
    %Compute the singular value decomposition
[~,~,V] = svd(A);
h = V(:,9)/V(9,9); 
HM = [h(1:3,1)';h(4:6,1)';h(7:9,1)'];    % Output the homography matrix  
end 