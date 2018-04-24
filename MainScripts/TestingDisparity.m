%% Calculate the disparity map 
clear all 
load DispTestL
load DispTestR
%%
ImageLRect = I1Rect; 
ImageRRect= I2Rect; 
DispMap = Disparity(ImageLRect,ImageRRect,1,0.01); 
%% Show the map 
disparityRange = [0 400];
imshow(DispMap,disparityRange);
title('Disparity Map');
colormap(gca,jet) 
colorbar






