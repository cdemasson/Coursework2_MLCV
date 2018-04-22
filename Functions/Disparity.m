%                        Disparity map function
% Function Inputs: 
% IL: Left image
% IR: Right image 
% Range: Disparity range
% W: Window size, defined as the thickness of the window. So a W value of 
% would result in a 3x3 window. A W value of 2 would result in a 5x5 window

function  DisparityMap = Disparity(IL,IR,W,Threshold) 
tic
IL = rgb2gray(IL); 
IR = rgb2gray(IR); 
DisparityMap = zeros(size(IL)); 
    % Iterate through all the rows (Y Coordinates)
    for row =  1 : size(IL,1) 
        fprintf(" The current row is %4.2f \n", row); 
        % Iterate through all the cols (X Coordinates) 
        for col = 1 : size(IL,2)
            % Calculate the window ranges 
            XminL = boundary(col - W,col,IL,1); 
            XmaxL = boundary(col + W,col,IL,1); 
            Ymin = boundary(row - W,row,IL,0); 
            Ymax = boundary(row + W,row,IL,0); 
            %Initialise the SSD to an unrealistically large value 
            SSDmin = 10000000;     
            % Iterate through the disparity range 
            for Xr = 1 : size(IL,2) 
                % Subtract 1 to start at 0 disparity
                % Shift the centre of the right window
                XminR = boundary((Xr) - W,(Xr),IL,1); 
                XmaxR = boundary((Xr) + W,(Xr),IL,1); 
                
                %           Dealing with four more boundary cases: 
                % Case 1: First column of left image
                if (col == 1) 
                    XminR = boundary((Xr),(Xr),IL,1);
                end 
                % Case 2: Last column of left image
                if (col == size(IL,2)) 
                    XmaxR = boundary((Xr),(Xr),IL,1); 
                end 
                % Calculate window sizes 
                Lwindow = IL(Ymin:Ymax,XminL:XmaxL);
                Rwindow = IR(Ymin:Ymax,XminR:XmaxR);
                
                % Case 3: First column of right image
                if (Xr == 1  && col ~=1) 
                    XminLtemp = boundary(col,col,IL,1);
                    % Recalculate left window size
                    Lwindow = IL(Ymin:Ymax,XminLtemp:XmaxL); 
                end 
                % Case 4: last column of right image
                if (Xr == size(IL,2)  && col ~=size(IL,2)) 
                    XmaxLtemp = boundary(col,col,IL,1); 
                    % Recalculate left window size
                    Lwindow = IL(Ymin:Ymax,XminL:XmaxLtemp); 
                end 
                
                % CALCULATING THE CURRENT SSD 
                try % TRY/CATCH STATEMENT 
                SSDcurrent = sum(sum((Lwindow - Rwindow).^2)); 
                catch 
                    disp("Error 1: Window sizes do not match") 
                    pause()
                end 
                % If the current SSD is less than the minimum, assign the
                % disparity and update the minimum SSD
                
                % COMPARING THE CURRENT SSD 
                try% TRY/CATCH STATEMENT 
                if (SSDcurrent < SSDmin) 
                    SSDmin = SSDcurrent; 
                    DisparityMap(row,col) = abs(col-Xr); 
                    
                    % BREAK OUT IF SSD is less than the threshold
                    if (SSDmin < Threshold)
                        break
                    end 
                    
                end 
                catch 
                    disp("Error 2: Unable to calculate the SSD") 
                    pause()
                end 
             
            end 
        end
    end 
    
% <<<<<<<<<<<<<     BOUNDARY CASE CHECKING FUNCTION  >>>>>>>>>>>>>>>>>>>>>
    function K = boundary(RangeValue,PixelPosition,IL,XorY) 
        % Case 1: Less than or equal to 1
        if (RangeValue <= 0) 
            K = PixelPosition;  
        % Case 2: Bigger than the image size 
        elseif ((RangeValue > size(IL,1) && XorY == 0) ||  (RangeValue > size(IL,2) && XorY == 1))
            K = PixelPosition; 
        else 
            K = RangeValue; 
        end 
    end     
toc
end 

