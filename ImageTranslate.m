%% FUNCTION: IMAGE TRANSLATOR 
% Given an image and a translation matrix, this function translates each pixle of the image 

function ImageB = ImageTranslate(ImageA,TranslationMatrix)
    % Iterate through all the rows 
    for rows =  1 : size(ImageA,1) 
        % Iterate through all the cols 
        for cols = 1 : size(ImageA,2)
            try 
            PixelNewPosition = TranslationMatrix\[cols;rows;1];
            PixelNewPosition = round(PixelNewPosition/PixelNewPosition(3,1));
                if (PixelNewPosition > 0) 
                ImageB(PixelNewPosition(2,1),PixelNewPosition(1,1)) = ImageA(rows,cols); 
                end 
            catch 
            disp("Error, something went wrong") 
            pause()
            end 
        end 
    end 

end 