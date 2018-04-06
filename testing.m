clc
syms x y z X Y Z f11 f12 f13 f21 f22 f23 f31 f32 

A = [X;Y;1];
A.'
F = [f11,f12,f13;f21,f22,f23;f31,f32,1]
B = [x;y;1];

A.'*F*B