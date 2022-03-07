function x = weighting_filter(signal)
   
%% Impulse Response of the filter based on the standard
   H = [-134, -374,0,2054,5741,8192,5741,2054,0,-374,-134];
   x = zeros(1,40);
   for k = 1:40
       for i = 1:11
           temp = k+5-i;
           if temp < 0  || temp > 39
               x(k) = x(k) + 0;
           else
               x(k) = x(k) + H(i)*signal(k+5-i);
           end
       end 
   end
end