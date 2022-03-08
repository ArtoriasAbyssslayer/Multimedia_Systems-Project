function [s0,CurrFrmResd] = RPE_frame_decoder(FrmBitStrm,PrevFrmResd)
    % Decoding levels of the normalized RPE-samples
    DL_norm = [-28672 -20480 -12288 -4096 4096 12288 20480 28672];
    
    upper_limits =[0 31 63 95 127 159 191 223 255 287  319 351 383,... 
                        415 447 479 511 575 639 703 767 831 895 959,... 
                        1023 1151 1279 1407 1535 1663 1791 1919 2047,...
                        2303 2559 2815 3071 3327 3583 3839 4095 4607,...
                        5119 5631 6143 6655 7167 7679 8191 9215 10239,...
                        11263 12287 13311 14335 15359 16383 18431 20479,...
                        22527 24575 26623 28671 30719 32767];
    
    % Decision levels of the decoding
    QLB = [0.10 0.35 0.65 1.00];
    k0 = 161;
    
    CurrFrmResd = zeros(size(PrevFrmResd));
    
    LARc = FrmBitStrm(1:8);
    ComposeFrame = FrmBitStrm(9:end);
    % Iterate every subframe
    for a = 1:4
        Mc = ComposeFrame((a-1)*17+1);
        x_max_c = ComposeFrame((a-1)*17+2);
        x_M_c = ComposeFrame((a-1)*17+3:(a-1)*17+15);
        bc(a) = ComposeFrame((a-1)*17+16);
        Nc(a) = ComposeFrame(a*17);
        
        % Find the decoded x_max
        x_max_d = upper_limits(x_max_c+1)*2^(-15);
        
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
        
        % Decode Nc and bc
        b_dec = QLB(bc(a)+1);
        N_dec = Nc(a);
        
        % Update the concatenated every time the CurrFrmResd changes
        concatenated = [PrevFrmResd; CurrFrmResd];
        
        % Find d_hat (d'')
        d_hat = b_dec*concatenated(k0+(a-1)*40-N_dec:k0+a*40-N_dec-1);
        
        CurrFrmResd((a-1)*40+1:a*40) = e_dec + d_hat;
    end
    
    % Short term decoder
    s0 = RPE_frame_ST_decoder(LARc,CurrFrmResd);
end