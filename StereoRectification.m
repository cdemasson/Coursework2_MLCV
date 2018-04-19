%  Stereo Image Rectification 

% Read Image 
clear all 
close all 
for FIG = 1:2
    % READING FD IMAGES
    % SELECT WHICH FD IMAGES TO USE
    FDimages(FIG).fig = imread(['FD' num2str(FIG) '.jpeg']);  
    % Uncomment if you need to rotate the images
    %FDimages(FIG).fig = imrotate(FDimages(FIG).fig,-90);           
end

%%  Collect corresponding points 

FDcc = zeros(2,2,4);      % FD Corrosponding Coordinates
Picture = [1,2];       % Select the pictures to compare
Pic1 = Picture(1,1); 
Pic2 = Picture(1,2); 
for PT= 1:10
    for FIG = 1:2
        figure(FIG);
        % This ensures the pictures swap regardness of which pictures are
        % chosen 
        if (FIG == 1)
            Pic = Pic1; 
        else 
            Pic = Pic2; 
        end 
        imshow(FDimages(Pic).fig);
        [FDcc(1,FIG, PT), FDcc(2,FIG, PT)] = ginput(1);
    end
end

%% Find homography and fundamental matrix 
HM = HomogMatrix(FDcc); 
FM = FundMatrix(FDcc);

%% Begin the process 





