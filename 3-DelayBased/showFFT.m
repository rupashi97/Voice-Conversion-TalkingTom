function showFFT( input, output, Fs )

figure; subplot(211); 
[y, x] = getFFT(input, Fs);
plot(x, y, 'g')
title('input')
subplot(212); 
[y, x] = getFFT(output, Fs);
plot(x, y, 'r')
title('output')
figure
spectrogram(x)
title('ip')
figure
spectrogram(y)
title('op')
