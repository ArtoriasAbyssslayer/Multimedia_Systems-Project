function s = preprocessing(s0)

    alpha = 32735*2^(-15);
    beta = 28180*2^(-15);
    %% preallocate the sample buffers
    s_of = zeros(size(s0));
    s = zeros(size(s0));
    %% preprocessing (Offset compensation + Preemphasis)
    for k = 1:length(s0)
        if (k == 1)
            % no prev sample
            s_of(k) = s0(k);
            s(k) = s_of(k);
        else
            s_of(k) = s0(k) - s0(k-1) + alpha*s_of(k-1);
            s(k) = s_of(k) - beta*s_of(k-1);
        end
    end
end