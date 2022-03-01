function [s0,CurrFrmSTResd] = RPE_frame_SLT_decoder(LARc, Nc, bc, CurrFrmExFull, PrevFrmSTResd)
    % Decision levels of the decoding
    QLB = [0.10 0.35 0.65 1.00];
    k0 = 161;
    CurrFrmSTResd = zeros(size(PrevFrmSTResd));
    for j = 1:4
        % Dequantize LTP gain
        b_dec = QLB(bc(j)+1);
        N_dec = Nc(j);
        
        % Update the concatenated every time the CurrFrmSTResd changes
        concatenated = [PrevFrmSTResd; CurrFrmSTResd];
        
        % Find d_hat (d'')
        d_hat = b_dec*concatenated(k0+(j-1)*40-N_dec:k0+j*40-N_dec-1);
        
        CurrFrmSTResd((j-1)*40+1:j*40) = CurrFrmExFull((j-1)*40+1:j*40) + d_hat;
    end
    
    
    % Short term decoder
    s0 = RPE_frame_ST_decoder(LARc,CurrFrmSTResd);


end

