function [FrmBitStrm,CurrFrmResd] = RPE_frame_coder(s0,PrevFrmResd)
    % Apply Long Term Encoding to the frame 
    [LARc, Nc, bc, CurrFrmExFull, CurrFrmSTResd] = RPE_frame_SLT_coder(s0, PrevFrmResd);
    QLB = [0.10 0.35 0.65 1.00];
    k0 = 161;
    % Decision levels of the quantizer
    DLB = [0.2 0.5 0.8];
    % xmax_c levels of the quantizer DLX_m
    DLX_max_c = 0:63;  
    % bellow are the upper limits which create the margin
    % that corresponds to each quantization level 
    upper_limits =[0 31 63 95 127 159 191 223 255 287  319 351 383,... 
                    415 447 479 511 575 639 703 767 831 895 959,... 
                    1023 1151 1279 1407 1535 1663 1791 1919 2047,...
                    2303 2559 2815 3071 3327 3583 3839 4095 4607,...
                    5119 5631 6143 6655 7167 7679 8191 9215 10239,...
                    11263 12287 13311 14335 15359 16383 18431 20479,...
                    22527 24575 26623 28671 30719 32767];
    
    CurrFrmResd = CurrFrmSTResd;
    ComposeFrame = zeros(1,17*4)';
    
    for a = 1: 4
        % apply weighting filter to 
        x = weighting_filter(CurrFrmExFull((a-1)*40+1:a*40));
        %adptive sample rate
        %+ find the x_m with the maximum power sequence
        P_rms = zeros(1,4)';
        x_m = zeros(4,13);
        for k = 1:13
            for m = 1:4
                x_m(m,k) = x(m+3*(k-1));
                P_rms(m) = P_rms(m) + x_m(m,k).^2;            
            end
        end
        [~,Mc] = max(P_rms);
        x_max = max(abs(x_m(Mc)))*2^15;
        % find best x_m
        x_m_best = x_m(Mc,:);
        
        %% quantization of xmax and x_m_best
        for i = 1:64
            if x_max <= upper_limits(i+1) &&  x_max >= upper_limits(i)
                x_max_c = DLX_max_c(i);
                break
            end
        end
        % Find the decoded x_max
        x_max_d = upper_limits(x_max_c+1)*2^(-15);
        
        % The normalized RPE-samples
        x_norm = (x_m_best./x_max_d)*2^15;

        %Decision Levels for x_M quantizer DLX_m
        DLX_m = [-32768 -24577 -16385 -8193  0  8191 16383 24575 32767];
        % Quantize the normalized RPE-samples
        x_M_c = zeros(1,13)'; % 1-7
        for i = 1 : 13
            for k = 1 : 8
                if x_norm(i) <= DLX_m(k+1) && x_norm(i) >= DLX_m(k) 
                    x_M_c(i) = k-1;
                    break
                end
            end
        end
        
        % Decoding levels of the normalized RPE-samples
        DL_norm = [-28672 -20480 -12288 -4096 4096 12288 20480 28672];
        % Decode x_M_c
        x_M_d = zeros(1,13)';
        for i = 1:13
            x_M_d(i) = DL_norm(x_M_c(i)+1) * 2^(-15) * x_max_d;
        end
        
        
        % Synthesis of long term residual
        e_dec = zeros(1,40)';
        for i = 1:13
            e_dec((i-1)*3+Mc) = x_M_d(i);
        end
        
        % Update the concatenated every time the CurrFrmResd changes
        concatenated = [PrevFrmResd; CurrFrmSTResd];
        % Select the j-th subframe
        d = CurrFrmSTResd((a-1)*40+1:a*40);
        Prevd = concatenated(k0+(a-1)*40-120:k0+(a-1)*40-1);
        
        [N, b] = RPE_subframe_LTE(d, Prevd);
        Nc(a) = N;
        % Quantize LTP gain
        if b <= DLB(1)
            bc(a) = 0;
        elseif b <= DLB(2)
            bc(a) = 1;
        elseif b <= DLB(3)
            bc(a) = 2;
        else 
            bc(a) = 3;
        end
        
        % Decode Nc and bc
        b_dec = QLB(bc(a)+1);
        N_dec = Nc(a);
        
        % Find d_hat (d'')
        d_hat = b_dec*concatenated(k0+(a-1)*40-N_dec:k0+a*40-N_dec-1);
        
        for i = 1:40
            if e_dec == 0
                CurrFrmResd((a-1)*40+1:a*40) = mean(d_hat);
            else
                CurrFrmResd((a-1)*40+1:a*40) = e_dec + d_hat;
            end
        end

        ComposeFrame((a-1)*17+1:a*17) = [Mc; x_max_c; x_M_c; bc(a); Nc(a)];
    end
    %create the compose frame and the frame bitstream  
    FrmBitStrm = [LARc; ComposeFrame];
end