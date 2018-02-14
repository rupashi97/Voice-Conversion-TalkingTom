% Delay Based Pitch SHift
clc
clear
%% Pitch Shift
input_file = 'test.wav';
semitones = 8;
output = pitch_shift(input_file, semitones);

%% See Results
[input, Fs]= audioread(input_file);
showFFT(input, output, Fs)

%% Play Results (press key to end pause)
soundsc(input, Fs) 
pause()
soundsc(output, Fs)

subplot(2,1,1)
plot(output,'r')
