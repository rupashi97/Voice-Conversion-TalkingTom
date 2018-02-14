%  Resampling Technique  %
close all
clear all
clc

[input,Fs]=audioread('test.wav');        %reading input file
factor=[1 0.8 1.5 1.8 2];             %pitch scaling factor
original_sampling_rate=Fs;

disp('Press Enter To Play Different Output Audios');
disp('Various voices : ');

for i=1:length(factor)
  disp('Fs changed by a factor of :');
  factor(i)
  Fs=Fs*factor(i);
  sound(input,Fs);
  pause
  Fs=original_sampling_rate;
end







