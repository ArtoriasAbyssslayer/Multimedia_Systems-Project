function [s0,CurrFrmResd] = RPE_frame_ST_decoder(LARc,PrevFrmResd)
    % CurrFrmResd = dhat 
    rcoefs_d = LAR2r(LARc)';
    a = rc2poly(rcoefs_d);
    % PrevFrmResd -> CurrFrmResidual --  ADPCM
    PrevFrmResd = 
    s0 = d + PrevFrmResd;
    % UNFINISHED
end

