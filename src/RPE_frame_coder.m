function [FrmBitStrm,CurrFrmResd] = RPE_frame_coder(s0,PrevFrmResd)
% Apply Long Term Encoding to the frame 
    [LARc, Nc, bc, CurrFrmExFull, CurrFrmSTResd] = RPE_frame_SLT_coder(s0, PrevFrmResd);
    CurrFrmResd = CurrFrmSTResd;
    for a = 1: 4
        % apply weighting filter to 
        x = weighting_filter(CurrFrmExFull((a-1)*40+1:a*40));
        %adptive sample rate
        %+ find the x_m with the maximum power sequence
        P_rms = zeros(1,4)';
        x_m = zeros(4,13);
        for k = 1:13
            for m = 1:4
                x_m(m,k) = x(m+3*k);
                P_rms(m) = P_rms(m) + x_m(m,k).^2;            
            end
        end
        [~,Mc] = max(P_rms);
        x_max = max(x_m(Mc))*2^15;
        % find best x_m
        x_m_best = zeros(1,13)';
        for k = 1:13
            if m == Mc
                x_m_best(k) = x_m(m+3*k);
            end
        end
        %% quantization of xmax and x_m_best
        % xmax_c levels of the quantizer DLX_m
        DLX_max_c = 0:63;  
        % bellow are the upper and the lower limits which create the margin
        % that corresponds to each quantization level 
        lower_limits =[0 32 64 96 128 192 224 256 288  320 352 384,... 
                        416 448 480 512 576 640 704 768 832 896 920,... 
                        1024 1152 1280 1408 1536 1664 1792 1920 2048,...
                        2304 2560 2816 3072 3328 3584 3840 4096 4608,...
                        5120 5632 6144 6656 7168 7680 8192 9216 10240,...
                        11264 12288 13312 14336 15360 16384 18432 20480,...
                        22528 24576 26624 28672 30720 32767];
            
        for i = 1:64
            if x_max < lower_limits(i+1) &&  x_max >= lower_limits(i)
                x_max_c = DLX_max_c(i);
            end
        end
        x_max_d = (lower_limit(x_max_c+2)-1)*2^(-15);            
        for i = 1 : 13            
            x_m_best_c(i) = DLX_m(k);
        end
        x_M_hat = zeros(1,13)';
        for i = 1:13
                x_M_hat(i) = (x_m_best(i)/x_mac_d)*2^15;
        end
        %Decision Levels for x_M quantizer DLX_m
        DLX_m = [-32768 -24576 -16384 -8192  0  8192 16384 24576 32767];
        x_M_c = zeros(1,13)'; % 1-7
        for i = 1 : 13
            for k = 1 : length(DLX_m)
                if x_M_hat(i) < (DLX_m(k)-1) && x_M_hat(i) > DLX_m(k)) 
                    x_M_c(i) = k-1;
                end
            end
        end
        x_M_p = zeros(1,13)'; % decoded x_M is used to find e(n)
        for i = 1 : 13
            for k = 1 : length(DLX_m)
                if x_M_hat(i) < (DLX_m(k)-1) && x_M_hat(i) > DLX_m(k)) 
                   x_M_p(i) = x_M(i)*2^(-15)*x_max_d;
                end
            end
        end
        x_M_d_hat = zeros(1,40)';
        %synthesis 
        for k = 1:13
            for i = 1:40
                if m == Mc
                    x_M_d_hat(m+3*k) = x_M_p(k);
                    x_M_d_hat(i) = 0;
                end
            end
        end
        CurrFrmResd((a-1)*40+1:a*40) = CurrFrmSTResd((a-1)*40+1:a*40) - x_M_d_hat;
       % Decision levels of the decoding  Normalized Inverse mantisa to
       % compute Xm/xmax
       x_mc = x_M_c;
       ComposeFrame((a-1)*17+1:a*17) = [Mc,x_max_c ,x_mc,bc(a),Nc(a)];
    end
  %create the compose frame and the frame bitstream  
  FrmBitStrm = [LARc ComposeFrame];       
end

