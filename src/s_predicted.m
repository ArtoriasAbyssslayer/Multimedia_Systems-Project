function s_p = s_predicted(s,w)
    s_p = zeros(size(s));
    s_p(1:8) = s(1:8);
    for n = 9:length(s)
        for k = 1:8
            s_p(n) = s_p(n)+ w(k)*s(n-k); 
        end
    end
end