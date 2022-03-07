function [s0,CurrFrmResd] = RPE_frame_decoder(FrmBitStrm,PrevFrmResd)
    ComposeFrame = FrmBitStrm[9:end];
    for a = 1:4
        ComposeSubFrame = ComposeFrame((a-1)*17+1:a*17);
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
        for k = 1:13a
            for i = 1:40
                if m == Mc
                    x_M_d_hat(m+3*k) = x_M_p(k);
                    x_M_d_hat(i) = 0;
                end
            end
        end
        CurrFrmResd((a-1)*40+1:a*40) = CurrFrmSTResd((a-1)*40+1:a*40) - x_M_d_hat;
    end
end