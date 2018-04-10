function [histogram] = gray_descriptor(pic_data, interest_points)
%The get_descriptors function returns the colour histogram of a patch
%extracted from a picture

%creating colour bins
%This is useless and can be deleted
nb_bins = 51;
histogram = zeros(length(interest_points), nb_bins);

%extracting patch: 5x5 pixels
for pt=1:length(interest_points)
    i=1;
    for x = interest_points(pt,1)-2:interest_points(pt,1)+2
        for y = interest_points(pt,2)-2:interest_points(pt,2)+2
            if x > 0 && y >0 && x <= size(pic_data,1) && y <= size(pic_data,2)
                patch(i) = pic_data(x,y);
                i=i+1;
            end
        end
    end

    %computing histograms
    for i=1:25
        %we have 51 bins containing 5 gray shades each
        bin = floor((patch(i)+5)/5);
        %bin number 51 contains 6 gray shades
        if bin == 52
            bin = 51;
        end
        histogram(pt, bin) = histogram(pt, bin) + 1;
    end
end
end

