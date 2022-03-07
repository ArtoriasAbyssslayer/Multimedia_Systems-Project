function [N,b] = RPE_subframe_LTE(d,PrevSubframe)
% PrevSubFrame is the subframe from the concatenated frame
subframe_size = 40;
    %% similarity testing of the previous subframes
    % index = size(PrevSubframe)+39-lambda;
    % lagged autocorrelation
    R = zeros(1,81)';
    for lambda = subframe_size:120
        index = size(PrevSubframe)-lambda+1;
        R(lambda-subframe_size+1) = sum(d.*PrevSubframe(index:index+39));
    end
    [R_max,maximizer_index] = max(R);
    N = maximizer_index + 39;   

    %beta estimation - amplitude difference
    %prev_frame that matches
    Prev_Match =  PrevSubframe(size(PrevSubframe)-N+1:size(PrevSubframe)-N+40);
    prevd_autocorr = sum(Prev_Match.*Prev_Match);
    b = R_max/prevd_autocorr;

end

