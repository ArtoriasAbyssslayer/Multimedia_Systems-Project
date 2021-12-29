function r = acf(s)

    r = zeros(9,1);
    for k = 1:9
        acf = 0;
        for i = k:160
            acf = acf + s(i)*s(i-k+1);
        end
        
        r(k) = acf;
    end
end