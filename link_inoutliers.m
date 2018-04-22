function link_inoutliers(pic_data, pic1, pic2, matching_points)
% This function displays two images side to side and links the matching
% points by a line.
% Further functionnality: inliers are green lines and outliers are red
% lines.

width = size(pic_data(pic1).fig, 2);
new_pic(:,1:width,:) = pic_data(pic1).fig;
new_pic(:,width+1:width*2,:) = pic_data(pic2).fig;
matching_points(:,3) = matching_points(:,3);
matching_points(:,4) = matching_points(:,4)+width;
match_pts_conv = convMatrix(matching_points);
RanHomog = RANSACHomog(match_pts_conv, 10);
figure(1);
title('Showing inliers between two scenes');
imshow(new_pic);
hold on;
nb_pts = size(RanHomog.m, 3);
for pts = 1:nb_pts
    plot(RanHomog.m(2,1,pts), RanHomog.m(1,1,pts), 'gr+');
    plot(RanHomog.m(2,2,pts), RanHomog.m(1,2,pts), 'gr+');
    plot([RanHomog.m(2,1,pts) RanHomog.m(2,2,pts)],[RanHomog.m(1,1,pts) RanHomog.m(1,2,pts)], 'g');
end
end

