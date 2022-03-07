function s_p = s_predicted(s,w)
    s_p = zeros(size(s));
    % s_p(1) = s(1);
      s_p(1) = 0;
    for n = 2:length(s)
        for k = 1:8
            if n<=k
                break;
            end
            s_p(n) = s_p(n)+ w(k)*s(n-k); 
        end
    end
end