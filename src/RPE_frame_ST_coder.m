function [LARc,CurrFrmResd] = RPE_frame_ST_coder(s0,PrevFrmResd)
%   RPE_FRAME_ST_CODER Summary of this function goes here
%   Detailed explanation goes here
    CurrFrmResd = zeros(size(PrevFrmResd));
    s = preprocessing(s0);
    r_s = acf(s);
    LAR = zeros(1,9)';
    w =  zeros(1,9)';
    
    %%
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
    % Rw=r;
    w = linsolve(R,r);
    disp(w);
%    LAR = log10((1+r_s)./(1-r_s));
%   TODO ask if we need to do the optimized calculation of LARs

%% LAR Quantization
    A = [20,20,20,20,13.637,15,8.334,8.824];
    B = [0,0,4,-5,0.184,-3.5,-0.666,-2.235];
    LARc = round(A.*LAR + B);
%% LARc DwE section
    LAR_Resd = LARc - LAR;
    
end

