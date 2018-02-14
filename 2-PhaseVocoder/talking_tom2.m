
% Phase Vocoder %

clear all
close all
clc
%%Initialization Phase
WindowLen = 256;
AnalysisLen = 50;
SynthesisLen = 90;
Hopratio = SynthesisLen/AnalysisLen;

[x,Fs]=audioread('test.wav');
reader = dsp.AudioFileReader('test.wav','SamplesPerFrame',AnalysisLen,'OutputDataType','double');
buff = dsp.Buffer(WindowLen, WindowLen - AnalysisLen); 

% Create a Window System object, which is used for the ST-FFT. This object applies a window to the buffered input data.
win = dsp.Window('Hanning', 'Sampling', 'Periodic');

dft=dsp.FFT;

% Create an IFFT System object, which is used for the IST-FFT.
idft = dsp.IFFT('ConjugateSymmetricInput',true,'Normalize',false);

player = dsp.AudioPlayer('SampleRate',Fs);

% Create a System object to log your data.
logger = dsp.SignalSink;

%nitializing variables used in processing loop
yprevwin = zeros(WindowLen-SynthesisLen,1);
gain = 1/(WindowLen*sum(hanning(WindowLen,'periodic').^2)/SynthesisLen);
unwrapdata = 2*pi*AnalysisLen*(0:WindowLen-1)'/WindowLen;
yangle = zeros(WindowLen,1);
firsttime = true;


%%Processing Loop
while ~isDone(reader)
    y = step(reader);
    y=y(:,1);
  
   % ST-FFT = FFT of a windowed buffered signal
    yfft = step(dft,step(win,step(buff,y)));

   % Convert complex FFT data to magnitude and phase.
    ymag       = abs(yfft);
    yprevangle = yangle;
    yangle     = angle(yfft);

    % Synthesis Phase Calculation
    yunwrap = (yangle - yprevangle) - unwrapdata;
    yunwrap = yunwrap - round(yunwrap/(2*pi))*2*pi;
    yunwrap = (yunwrap + unwrapdata) * Hopratio;
    if firsttime
        ysangle = yangle;
        firsttime = false;
    else
        ysangle = ysangle + yunwrap;
    end

    % Convert magnitude and phase to complex numbers.
    ys = ymag .* complex(cos(ysangle), sin(ysangle));

    % IST-FFT
    ywin  = step(win,step(idft,ys));    % Windowed IFFT

    % Overlap-add operation
    olapadd  = [ywin(1:end-SynthesisLen,:) + yprevwin; ywin(end-SynthesisLen+1:end,:)];
    yistfft  = olapadd(1:SynthesisLen,:);
    yprevwin = olapadd(SynthesisLen+1:end,:);

    % Compensate for the scaling that was introduced by the overlap-add operation
    yistfft = yistfft * gain;

    step(logger,yistfft);     % Log signal
end


release(reader);

%time stretched signal
loggedSpeech = logger.Buffer(205:end)';

disp('Playing Original Audio ..');
sound(x,Fs)
pause(.7)

%Play the pitch scaled signal
Fs_new = Fs*(SynthesisLen/AnalysisLen);
player = dsp.AudioPlayer('SampleRate',Fs_new);
disp('Playing pitch-scaled audio...');
step(player,loggedSpeech.');


%Plotting Original Vs Time Stretched Signal
ax1=subplot(2,1,1);
plot(x)
title('Original audio');
ax2=subplot(2,1,2);
plot(loggedSpeech.','r')
title('Time streched audio');
linkaxes([ax1,ax2],'xy')

disp('Duration of original signal :');
length(x)/Fs

disp('Duration of new signal');
length(loggedSpeech.')/Fs_new





