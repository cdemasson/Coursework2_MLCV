%% FUNCTION: IMAGE TRANSLATOR 
% Given an image and a translation matrix, this function translates each pixle of the image
% !!!!!!!! NB ::::: YOU MAY HAVE TO CHANGE TO MULTIPLY TO INVERSE IN LINE
% 11

% !!! Set focal to 1 if not for stereo rectification 
function ImageB = ImageTranslate(ImageA,TranslationMatrix,focal)
    % Iterate through all the rows 
    for rows =  1 : size(ImageA,1) 
        % Iterate through all the cols 
        for cols = 1 : size(ImageA,2)
            try 
            PixelNewPosition = TranslationMatrix*[cols;rows;focal];
            PixelNewPosition = -1*round(focal*PixelNewPosition/PixelNewPosition(3,1));
                if (PixelNewPosition(1:2,1) > 0) 
                ImageB(PixelNewPosition(2,1),PixelNewPosition(1,1),:) = ImageA(rows,cols,:); 
                end 
            catch 
            disp("Error, something went wrong") 
            pause()
            end 
        end 
    end 

end 