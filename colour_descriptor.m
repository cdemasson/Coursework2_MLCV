function [histogram] = colour_descriptor(pic_data, interest_points)
%The get_descriptors function returns the colour histogram of a patch
%extracted from a picture

%extracting patch: 5x5 pixels
for pt=1:length(interest_points)
    i=1;
    for x = interest_points(pt,1)-2:interest_points(pt,1)+2
        for y = interest_points(pt,2)-2:interest_points(pt,2)+2
            if x > 0 && y > 0 && x <= size(pic_data,1) && y <= size(pic_data,2)
                bins = zeros(1,3);
                for rgb=1:3
                    if pic_data(x,y,rgb) <= 63
                        bins(rgb) = 0;
                    elseif pic_data(x,y,rgb) <= 127
                        bins(rgb) = 1;
                    elseif pic_data(x,y,rgb) <= 191
                        bins(rgb) = 2;
                    else 
                        bins(rgb) = 3;
                    end
                end
                %the base 4 number gives the final bin
                histogram(pt,i) = base2dec(int2str(bins(1)+10*bins(2)+100*bins(3)), 4);
                i=i+1;
            end
        end
    end
end
end

