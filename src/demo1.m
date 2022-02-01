clear
clc

[s0,Fs] = audioread('../assets/a-little-sticious.wav');

no_frames = length(s0)/160;

% If the number of frames is not an integer add to the end of s0 0 values
if ~isinteger(no_frames)
    no_frames = ceil(no_frames);
    new_length = no_frames*160;
    s0 = [s0; zeros(1,new_length-length(s0))'];
end

s0_dec = zeros(size(s0));

% Iterate for every frame of the signal
for i = 1:no_frames
    start = (i-1)*160+1;
    if i == no_frames
        finish = length(s0);
    else
        finish = i*160;
    end
    % Coder
    [LARc,CurrFrmResd] = RPE_frame_ST_coder(s0(start:finish));

    % Decoder
    s0_dec(start:finish) = RPE_frame_ST_decoder(LARc,CurrFrmResd);
end

audiowrite('decoded.wav', s0_dec, Fs);
sound(s0_dec,Fs)
% Calculate the mean squared error
mse = mean((s0-s0_dec).^2);
disp(mse);
figure(1);
plot(1:length(s0),s0);
title("Original waveform")
figure(2)
plot(1:length(s0_dec),s0_dec);
title("Decoded waveform")