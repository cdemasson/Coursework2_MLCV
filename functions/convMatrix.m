function newM = convMatrix(M)

% input is M = [X1 Y1 X2 Y2]
% output must be newM = [X1 X2; Y1 Y2]

% newM(:,:,1) = X1 X2
%				Y1 Y2
% newM(:,:,2) = X1 X2
%				Y1 Y2
% etc.
newM = zeros(2,2,size(M,1));
for i = 1:size(M,1)
	newM(:,1,i) = M(i,1:2);
	newM(:,2,i) = M(i,3:4);
end

end