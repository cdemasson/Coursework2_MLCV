%**************************************************************************
%              FUNCTION 2: Calculating the fundamental matrix 

function FM = FundMatrix(CC) 
% The input variable CC is defined in Function 1 above. 
    B = [];     
    for PT = 1 : length(CC) 
        Bx = [CC(1,1,PT)*CC(1,2,PT),CC(1,2,PT)*CC(2,1,PT),CC(1,2,PT),CC(1,1,PT)*CC(2,2,PT),CC(2,1,PT)*CC(2,2,PT),CC(2,2,PT),CC(1,1,PT),CC(2,1,PT),1];
        B = [B;Bx]; 
    end 
    %Compute the singular value decomposition
    [~,~,V] = svd(B);
    f = V(:,9)/V(9,9); 
    FM = [f(1:3,1)';f(4:6,1)';f(7:9,1)'];  % Output the fundamental matrix
end 

