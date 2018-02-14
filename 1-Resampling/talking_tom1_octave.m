%  Resampling Technique  %

%Recording speaker and changing Fs [Works only in Octave]
object=audiorecorder(44100,16,1);            %creating object of type audiorecorder 
disp('Start Speaking [Press Enter To Stop Recording]');
record(object,3)                             %recording user
pause
disp('End of Recording');
obj_data=getaudiodata(object);           
plot(obj_data)                               

factor=[1 0.8 1.5 1.8];                      %pitch scaling factor
original_sampling_rate=object.SampleRate;

disp('Press Enter To Play Different Output Audios');
disp('Various voices : ');
for i=1:length(factor)
  object.SampleRate=object.SampleRate*factor(i);
  play(object)
  pause
  object.SampleRate=original_sampling_rate;
end
