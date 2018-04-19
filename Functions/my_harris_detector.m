function [interest_points] = my_harris_detector(pic_data, alpha, trshld, r)
% The Harris detector function is an intensity based method which computes
% interest point of a given image
% This function works well with the boat dataset because it is a gray
% scaled image. It doesn't take into account the three RGB components for
% the tsukuba dataset. 

%step 1: compute the x and y derivatives of the image (sobel derivatives)
derivativeFilter = [-1 -2 -1; 0 0 0; 1 2 1];
Ix = conv2(pic_data(:,:), derivativeFilter, 'same');
Iy = conv2(pic_data(:,:), derivativeFilter.', 'same');

%step 2: compute squares of derivatives
Ix2 = Ix.^2;
Iy2 = Iy.^2;
Ixy = Ix.*Iy;

H = size(Ix2, 1);
L = size(Ix2, 2);

%step 3: defining M matrix (structure tensor)
M1 = zeros(H, L, 2, 2);
M1(:,:,1,1) = Ix2;
M1(:,:,1,2) = Ixy;
M1(:,:,2,1) = Ixy;
M1(:,:,2,2) = Iy2;

M2 = zeros(H, L, 2, 2);
for i=1:H-1
    for j=1:L-1
        M2(i,j,1,1) =  sum(M1(i:i+1,j,1,1)) + sum(M1(i:i+1,j+1,1,1));
        M2(i,j,1,2) =  sum(M1(i:i+1,j,1,2)) + sum(M1(i:i+1,j+1,1,2));
        M2(i,j,2,1) =  sum(M1(i:i+1,j,2,1)) + sum(M1(i:i+1,j+1,2,1));
        M2(i,j,2,2) =  sum(M1(i:i+1,j,2,2)) + sum(M1(i:i+1,j+1,2,2));
    end
end

%step 4: Harris response calculation
determinant = zeros(H,L);
for i=1:H
    for j=1:L
        Mtmp = [M2(i,j,1,1) M2(i,j,1,2); M2(i,j,2,1) M2(i,j,2,2)];
        determinant(i,j) = det(Mtmp);
    end
end
trace = M2(:,:,1,1) + M2(:,:,2,2);
R = determinant - alpha * trace.^2;

%scaling har such as its values are <= 100
R_max = max(max(R));
R = R / R_max * 100;

%step 5: non maxima suppression
sze = 2*r+1;
mx = ordfilt2(R,sze^2,ones(sze));
R = (R==mx)&(R>trshld); 

%interest_points = zeros(1,2);
[interest_points(:,1), interest_points(:,2)] = find(R);

%this line allows us to use this function with coloured pictures too
interest_points(:,2) = mod(interest_points(:,2),size(pic_data,2))+1;
interest_points = unique(interest_points, 'rows');

if isempty(interest_points)
    disp('No interest points were found');
else
    imshow(pic_data);
    hold on;
    for pts = 1:size(interest_points,1)
        plot(interest_points(pts,2), interest_points(pts,1), 'r+');
    end
end
end

