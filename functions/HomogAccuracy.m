function Accuracy = HomogAccuracy(CC,HM)
% This function calculates the accuracy - In average pixel length - of two 
% images, image A and image B. It does so by estimating the corresponding
% coordinates of an interest point in image A, using the inverse of the
% homographic matrix and the coordinates in B: A' = H\B
% It then calcualtes the distance between the estimated coordinates of A' 
% and the actual coordinates of A. 

% NB: This means the accuracy is subject to poor and inaccuracy interest
% point selection if manually selected.

A_Est = zeros(2,5);     % Estimation of points in image A
Dist = zeros(1,5);      % Initialise a distance vector for accuracy

% Iterate through the 5 points 
for Pt = 1 : length(CC)
    Atemp= HM\[CC(:,2,Pt);1]; 
    A_Est(:,Pt) = Atemp(1:2,1);
    Dist(1,Pt) = sqrt((Atemp(1,1)-CC(1,1,Pt))^2+(Atemp(2,1)-CC(2,1,Pt))^2);
end 

Accuracy = sum(Dist)/length(CC); 
fprintf(" The average homographic accuracy is %4.2f pixels \n", Accuracy); 
end 