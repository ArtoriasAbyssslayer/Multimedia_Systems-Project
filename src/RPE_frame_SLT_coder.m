function [LARc, Nc, bc, CurrFrmExFull, CurrFrmSTResd] = RPE_frame_SLT_coder(s0, PrevFrmSTResd)
    % Short term coder
    [LARc,CurrFrmSTResd] = RPE_frame_ST_coder(s0);
    
    % Decision levels of the quantizer
    DLB = [0.2 0.5 0.8];
    % Decision levels of the decoding
    QLB = [0.10 0.35 0.65 1.00];

    Nc = zeros(1,4)';
    bc = zeros(1,4)';
    CurrFrmExFull = zeros(size(CurrFrmSTResd));
    for j = 1:4
        % Select the j-th subframe
        d = CurrFrmSTResd((j-1)*40+1:j*40);
        
        % Concat subframe to a big frame
        concatenated = [PrevFrmSTResd; CurrFrmSTResd];
        
        % Start of current frame in concatenated
        k0 = 161;
        
        Prevd = concatenated(k0+(j-1)*40-120:k0+(j-1)*40-1);
        
        [N, b] = RPE_subframe_LTE(d, Prevd);
        Nc(j) = N;
        % Quantize LTP gain
        if b <= DLB(1)
            bc(j) = 0;
        elseif b <= DLB(2)
            bc(j) = 1;
        elseif b <= DLB(3)
            bc(j) = 2;
        else 
            bc(j) = 3;
        end
        % Dequantize LTP gain
        b_dec = QLB(bc(j)+1);
        N_dec = Nc(j);
        
        % Find d_hat (d'')
        d_hat = b_dec*concatenated(k0+(j-1)*40-N_dec:k0+j*40-N_dec-1);
        
        % Error without quantization
        CurrFrmExFull((j-1)*40+1:j*40) = d - d_hat;
        
    end
        
end