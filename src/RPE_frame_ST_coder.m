function [LARc,CurrFrmResd] = RPE_frame_ST_coder(s0)
%   RPE_FRAME_ST_CODER Summary of this function goes here
%   Detailed explanation goes here
    %% Preprocessing and calculation of LAR
    s = preprocessing(s0);
    
    % Calculate the autocorrelations
    r_s = acf(s);
    w = w_calc(r_s);
    w_appended = [1 -w']';
    r_coefs = poly2rc(w_appended);
       
    LAR = log10((1+r_coefs)./(1-r_coefs));
%     LAR = r2LAR(r_coefs);

    %% LAR Quantization
    A = [20,20,20,20,13.637,15,8.334,8.824]';
    B = [0,0,4,-5,0.184,-3.5,-0.666,-2.235]';
    LARc = round(A.*LAR + B);

    %% DwE section    
    % Decode the quantized LAR
    LAR_dec = (LARc - B)./A;
    
    % calculation of d with FIR filter and AR coeffs [1, -a1,-a2,-a3...a8]
    rcoefs_dec = (10.^LAR_dec - 1)./(10.^LAR_dec + 1);
%     rcoefs_dec = LAR2r(LAR_dec);
    
    w_dec = rc2poly(rcoefs_dec)';
    
    % Remove the first value of w_dec which is 1
    a_dec = w_dec(2:end);

    CurrFrmResd = s - s_predicted(s, a_dec);
%     CurrFrmResd = short_term_analysis_filt(s, rcoefs_dec);
    
end

