function s0 = RPE_frame_ST_decoder(LARc,CurrFrmResd)
    % Vectors used to decode LARc
    A = [20,20,20,20,13.637,15,8.334,8.824]';
    B = [0,0,4,-5,0.184,-3.5,-0.666,-2.235]';

    % Decode the quantized LARc
    LAR_dec = (LARc - B)./A;
    
    % inverse convertion LAR->rc
    rcoefs_dec = LAR2r(LAR_dec)';
    
    % The denominator coeffs of the filter
    w_dec = rc2poly(rcoefs_dec);
    windowSize = 2;
    b = (1/windowSize)*ones(1,windowSize);
    % Convolute with the filter Hs
    s = filter(b, w_dec, CurrFrmResd,[],2);
 
    %% Postprocessing
    % Deemphasis
    beta = 28180*2^(-15);
    s0 = zeros(length(s),1);
    s0(1) = s(1);
    for k = 2:length(s)
        s0(k) = s(k) + beta*s0(k-1);
    end
    
    
end

