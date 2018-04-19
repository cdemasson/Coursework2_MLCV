%**************************************************************************
%              FUNCTION 4: Epipole and Epipolar Line 

function Epipolar = EpiLine(FM,Point,B2A,range)
% FM is the fundamental matrix between image A and B. Point is the Point 
% in image A or B. If the epipole in image A is required then B2A = true,
% if the epipole in image B is required then B2A = false. 
% range is the domain of the image (Full X domain) 
if (B2A == false)
    FM = FM.';          % Take the transpose when projecting from A to B 
end 

% Calculate the Epipole in the image 
[~,~,V] = svd(FM);
Epipole = V(:,3)/V(3,3);
Epipole = Epipole(1:2,1);     %Only use the x,y coordinates

%Create a line for the first point in image A 
% Point = (X1,Y1) 
% Epipole = (X2,Y2)
x = 1 : range; 
y = ((Epipole(2,1)-Point(2,1))/(Epipole(1,1)-Point(1,1)))*(x-Point(1,1)) + Point(2,1); 
Epipolar.x = x; 
Epipolar.y = y; 
Epipolar.e = Epipole; 
end 

