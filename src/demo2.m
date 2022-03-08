clear 
clc 
clf
[s0,Fs] = audioread('../assets/a-little-sticious.wav');

no_samples = length(s0)/160;

% If the number of samples is not an integer add to the end of s0 0 values
if ~isinteger(no_samples)
    no_samples = ceil(no_samples);
    new_length = no_samples*160;
    s0 = [s0; zeros(1,new_length-length(s0))'];
end

s0_dec = zeros(size(s0));


[LARc,CurrFrmSTResd] = RPE_frame_ST_coder(s0(1:160));
s0_dec(1:160) = RPE_frame_ST_decoder(LARc,CurrFrmSTResd);
  
% Iterate for every frame of the signal
for i = 1:no_samples
    start = (i-1)*160+1;
    if i == no_samples
        finish = length(s0);
    else
        finish = i*160;
    end   
    %Iterate for the first frame Short Term Analysis
    if start == 1
        PrevFrmSTResd = CurrFrmSTResd; 
    else 
        [LARc, Nc, bc, CurrFrmExFull, ~] = RPE_frame_SLT_coder(s0(start:finish), PrevFrmSTResd);
        [s0_dec(start:finish),CurrFrmSTResd] = RPE_frame_SLT_decoder(LARc, Nc, bc, CurrFrmExFull, PrevFrmSTResd);
        PrevFrmSTResd = CurrFrmSTResd;
    end
     
end

audiowrite('decoded.wav', s0_dec, Fs);
sound(s0_dec,Fs)
% Calculate the mean squared error
mse = mean((s0-s0_dec).^2);
fprintf('Mean squared error:')
disp(mse);
figure(1);
plot(1:length(s0),s0);
title("Original waveform")
figure(2)
plot(1:length(s0_dec),s0_dec);
title("Decoded waveform")