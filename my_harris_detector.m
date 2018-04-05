function [interest_points] = my_harris_detector(pic_data)
% The Harris detector function is an intensity based method which computes
% interest point of a given image

%step 1: compute the x and y derivatives of the image (sobel derivatives)
derivativeFilter = [-1 -2 -1; 0 0 0; 1 2 1];
Ix = conv2(pic_data(:,:), derivativeFilter, 'same');
Iy = conv2(pic_data(:,:), derivativeFilter.', 'same');

%step 2: compute squares of derivatives
Ix2 = conv2(Ix, Ix, 'same'); %or Ix2 = Ix.^2;
Iy2 = conv2(Iy, Iy, 'same');
Ixy = conv2(Ix, Iy, 'same');

%step 3: apply gaussian filter
sigma = 2; %make it vary
GIx2 = imgaussfilt(Ix2, sigma);
GIy2 = imgaussfilt(Iy2, sigma);
GIxy = imgaussfilt(Ixy, sigma);

%step 4: cornerness function
alpha = 0.05; %make it vary
har = GIx2.*GIy2 - GIxy.^2 - alpha*(GIx2 + GIy2).^2;

%step 5: non maxima suppression

interest_points = pic_data;
end

