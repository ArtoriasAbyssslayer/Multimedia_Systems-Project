function x = weighting_filter(signal)
   
%% Impulse Response of the filter based on the standard
   H = [-134, -374,0,2054,5741,8192,5741,2054,0,-374,-134] ./ 2^(13);
   x = zeros(1,40);
   for k = 1:40
       for i = 1:11
           temp = k+5-i;
           if temp < 1  || temp > 40
               x(k) = x(k) + 0;
           else
               x(k) = x(k) + H(i)*signal(temp);
           end
       end 
   end
end