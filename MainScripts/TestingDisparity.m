%% Calculate the disparity map 
clear all 
%load DispTestL
%load DispTestR

I1Rect = imread(['scene1.row3.col2.ppm']);
I2Rect = imread(['scene1.row3.col3.ppm']); 
%%
ImageLRect = I1Rect; 
ImageRRect= I2Rect; 
DispMap = Disparity(ImageLRect,ImageRRect,8,0.0001); 
%% Show the map 
disparityRange = [0 300];
imshow(DispMap,disparityRange);
title('Disparity Map');
colormap(gca,jet) 
colorbar






