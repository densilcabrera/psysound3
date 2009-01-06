function SineToneCreation
% Systematically creating sine tones

carrier  = [16 32 63 125 250 500 1000 2000 4000 8000 16000];
level    = [20 30 40 50 60 70 80 90 100];
fs = [8000 44100 48000 96000];
flen = [1 10 60 600 1800];

for i=1:length(carrier)
  for j=1:length(level)
    for k =1:length(fs)
      % Create Sound and Save
      wave        = synthSound(carrier(i),fs(k),level(j),3,0,0,0,0);
      wave = wave * 0.000001;
      %wave        = wave/max(abs(wave));
      filename    = sprintf('%03.0fdB-%04.0fHz-Fs%05.0f.wav', level(j),carrier(i),fs(k));
      wavwrite(wave,fs(k),24,filename);
    end
  end
end




