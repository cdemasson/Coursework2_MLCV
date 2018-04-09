%**************************************************************************
%              FUNCTION 5: Average distance between point and epipolar line

function FA = Fund_Matrix_Accuracy(FM,CC)
% This function calculates the average distance between points in image B 
% and the mapped epipolar line generated using the fundamental matrix and 
% corrosponding coordinates L' = FM*X, where X is the point in image A and 
% X' is the corrosponding point in image B. 
Total_Distance = 0;         % Initilise the total distance to zero 
for PT = 1: length(CC)
 % Get the corrosponding point in image B
PtbX = CC(1,2,PT);              
PtbY = CC(2,2,PT);
% LineB outputs (A;B;C), where Ax+By+C = 0 
LineB = FM*[CC(:,1,PT);1];       % Calculate the epipolar in image B
A = LineB(1,1);
B = LineB(2,1);
C = LineB(3,1);
% Calculate the distance between the point and the line in image B
Total_Distance = Total_Distance + abs(A*PtbX+B*PtbY+C)/(sqrt(A^2+B^2)); 
end 
FA = Total_Distance/PT;     % Calculate the average distance for all the points
fprintf(" The average fundamental accuracy is %4.2f pixels \n", FA); 
end 
