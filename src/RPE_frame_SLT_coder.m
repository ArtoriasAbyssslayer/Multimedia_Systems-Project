function [LARc, Nc, bc, CurrFrmExFull, CurrFrmSTResd] = RPE_frame_SLT_coder(s0, PrevFrmSTResd)
    % Short term coder
    [LARc,CurrFrmSTResd] = RPE_frame_ST_coder(s0);
    
    % Decision levels of the quantizer
    DLB = [0.2 0.5 0.8];
    % Decision levels of the decoding
    QLB = [0.10 0.35 0.65 1.00];
    % Start of current frame in concatenated
        k0 = 161;
    Nc = zeros(1,4)';
    bc = zeros(1,4)';
    CurrFrmExFull = zeros(size(CurrFrmSTResd));
    for j = 1:4
        % Select the j-th subframe
        d = CurrFrmSTResd((j-1)*40+1:j*40);
        
        % Concat subframe to a big frame
        concatenated = [PrevFrmSTResd; CurrFrmSTResd];
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
        
        % Find d_hat (d'') %% d''(n) = b_dec*cpmcatemated
        d_hat = b_dec*concatenated(k0+(j-1)*40-N_dec:k0+j*40-N_dec-1);
        
        % Error without quantization
        CurrFrmExFull((j-1)*40+1:j*40) = d - d_hat;
        
        % apply weighting filter to 
        x = weighting_filter(CurrFrmExFull((j-1)*40+1:j*40));
        %adptive sample rate
        %+ find the x_m with the maximum power sequence
        P_rms = zeros(1,4)';
        x_m = zeros(1,39)';
        for j = 1:13
            for m = 1:4
                x_m(j) = x(k0+(j-1)*40+m+3*j);
                P_rms(m) = P_rms(m) + x_m(j).^2;            
            end
        end
        [~,Mc] = max(P_rms);
        x_max = max(x_m(Mc));
         % find best x_m
        x_m_best = zeros(1,13)';
        for j = 1:13
            if m == Mc
                x_m_best(j) = x_m(k0+(j-1)*40+m+3*j);
            end
        end
        %% quantization of xmax and x_m_best
        % decision levels of the quantizer DLX_m
        DLX_m = zero(1,64)';
        for i = 1 : 64
            DLX_m(i) =  2^(i-1);
        end
        for i = 1 : 13
            for j = 1:64
                if x_m_best(i) <= DlX_m(j) && x_m_best(i) > DLX_m(j)  
                    x_m_best_c(i) = DLX_m(j);
                end
            end
        end
        x_max_c = max(x_m_best_c);
        for i = 1:13
            x_hat(i) = x_m_best(i)/x_mac_c;
        end
        DLX_m = [-32768 -24576 -16384 -8192  0  8192 16384 24576 32767];
        x_hat_m_c = zeros(1,13)';
        for i = 1 : 13
            for j = 1 : length(DLX_m)
                if x_m_best(i)*(2^15) > DLX_m(j) 
                    x_hat_m_c(i) = floor((DLX_m(j+1)-1 - DLX_m(j))/2 + DLX(j));
                end
            end
        end
        x_max_c = max(x_hat_m_c);
       % Decision levels of the decoding  Normalized Inverse mantisa to
       % compute Xm/xmax
        
        for j = 1:13
             x_hat(i) =    
        end
       x_mc = x_m;
       
      
       ComposeFrame((j-1)*40+1:j*40) = [Mc,x_max_c ,x_mc,bc(j),Nc(j)];
%         for i = 1:4 
%             P_rms(i) = rms(x_m(i))^2;l
%         end
      
        
    end   
end