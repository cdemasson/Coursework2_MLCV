function [histogram] = gray_descriptor(pic_data, interest_points)
%The get_descriptors function returns the colour histogram of a patch
%extracted from a picture

%creating colour bins
%This is useless and can be deleted
nb_bins = 100;
bins = zeros(1,nb_bins);
for i=1:nb_bins
    bins(i) = i;
end

%extracting patch: 5x5 pixels
for pt=1:length(interest_points)
    i=1;
    for x = interest_points(pt,1)-2:interest_points(pt,1)+2
        for y = interest_points(pt,2)-2:interest_points(pt,2)+2
            if x >= 0 && y >=0 && x < size(pic_data,1) && y < size(pic_data,2)
                patch(i) = pic_data(x,y);
                i=i+1;
            end
        end
    end

    %computing histogram
    for i=1:25
        %we have 51 bins containing gray shades each
        histogram(pt, i) = floor((patch(i)+5)/5);
        if histogram(pt,i) == 52
            histogram(pt,i) = 51;
        end
    end
end
end

