function [interest_points] = my_harris_detector(pic_data, sigma, alpha, trshld, r)
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
Ix2 = conv2(Ix, Ix, 'same'); %or Ix2 = Ix.^2;
Iy2 = conv2(Iy, Iy, 'same');
Ixy = conv2(Ix, Iy, 'same');

%step 3: apply gaussian filter
GIx2 = imgaussfilt(Ix2, sigma);
GIy2 = imgaussfilt(Iy2, sigma);
GIxy = imgaussfilt(Ixy, sigma);

%step 4: cornerness function
har = GIx2.*GIy2 - GIxy.^2 - alpha*(GIx2 + GIy2).^2;

%scaling har such as its values are <= 100
har_max = max(max(har));
R = har / har_max * 100;

%step 5: non maxima suppression
sze = 2*r+1;
mx = ordfilt2(R,sze^2,ones(sze));
R = (R==mx)&(R>trshld); 

clear interest_points;
[interest_points(:,1), interest_points(:,2)] = find(R);

if isempty(interest_points)
    disp('No interest points were found');
else
    imshow(pic_data);
    hold on;
    for pts = 1:length(interest_points)
        plot(interest_points(pts,2), interest_points(pts,1), 'r+');
    end
end

end

