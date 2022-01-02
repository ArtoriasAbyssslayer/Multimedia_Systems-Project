function r = LAR2r(LAR)
    alpha = 0.337500;
    beta = 0.796875;
    r = zeros(size(LAR));
    for i = 1:length(LAR)
        if (abs(LAR(i)) < 0.675)
            r(i) = LAR(i);
        elseif (abs(LAR(i))>= 0.675 && abs(LAR(i)) < 1.225)
            r(i) = sign(LAR(i))*(0.5*abs(LAR(i)) + alpha);
        else
            r(i) = sign(LAR(i))*(0.125*abs(LAR(i)) + beta);
        end
    end
end

