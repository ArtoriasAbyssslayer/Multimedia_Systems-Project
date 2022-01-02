function [LARc,CurrFrmResd] = RPE_frame_ST_coder(s0,PrevFrmResd)
%   RPE_FRAME_ST_CODER Summary of this function goes here
%   Detailed explanation goes here
    CurrFrmResd = zeros(size(PrevFrmResd));
    s = preprocessing(s0);
    r_s = acf(s);
    LAR = zeros(1,9)';
    w = w_calc(r_s);
    w_appended = [1 -w']';
    efinal = 0.2;
    [r_coefs,r0] = poly2rc(w_appended,efinal);
       
    %LAR = log10((1+r_coefs)./(1-r_coefs));
    
    % TODO ask if we need to do the optimized calculation of LARs
    LAR = r2LAR(r_coefs);
%% LAR Quantization
    A = [20,20,20,20,13.637,15,8.334,8.824];
    B = [0,0,4,-5,0.184,-3.5,-0.666,-2.235];
    LARc = round(A.*LAR' + B)';
%% DwE section
    d = s - s_predicted(s,w);
    
    % calculation of d with FIR filter and AR coeffs [1, -a1,-a2,-a3...a8]
    % d_fir = s_predicted(d,w_appended(2:8)); 
    rcoefs_d = LAR2r(LARc)';
    a = rc2poly(rcoefs_d,r0);
    s_predicted_hat = s_predicted(s,a);   
    d_hat = s - s_predicted_hat;
    CurrFrmResd = d_hat;
    
end

