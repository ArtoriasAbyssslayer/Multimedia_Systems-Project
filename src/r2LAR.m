function LAR = r2LAR(r)
    alpha = -0.675;
    beta = -6.375;
    LAR = zeros(size(r));
    for i = 1:length(LAR)
        if (abs(r(i)) < 0.675)
            LAR(i) = r(i);
        elseif (abs(r(i))>= 0.675 && abs(r(i)) < 0.950)
            LAR(i) = sign(r(i))*(2*abs(r(i)) + alpha);
        else 
            LAR(i) = sign(r(i))*(8*abs(r(i)) + beta);
        end
    end
end
