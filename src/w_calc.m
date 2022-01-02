function [w] = w_calc(r_s)
%W_CALC Summary of this function goes here
%   Detailed explanation goes here
 w =  zeros(1,9)';
    
    %% Compose R matrix
    r = r_s(2:9);
    R =  zeros(8);
    for i = 1:8
        for j = 1:8
            if (i == j)
                R(i,j) = r_s(1);
            elseif (i < j)
                temp = r_s(j-i+1);
                if(j >= 2)
                    R(i,j) = temp;
                else
                    R(i,j) = r_s(j); 
                end
            end
        end
    end
    temp_R = R';
    R = temp_R + R - diag(diag(R));
    %% Linsolve R*w = r
    w = linsolve(R,r);
end

