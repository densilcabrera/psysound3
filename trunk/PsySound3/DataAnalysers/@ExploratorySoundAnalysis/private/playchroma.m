function playchroma(method,dataObj,beats,decimation)
% PLAYCHROMA play chroma pattern


chro       = dataObj.data;
timePointsAll = dataObj.time;
below1000 = find(timePointsAll <1000);

chro = chro(below1000,:);
timePoints = timePointsAll(below1000);

chroma   =   [0:11]';
[r,c]    =   size(chro);

% make 12 tones 
notes    = 440 * 2 .^ (chroma / 12);

% sample period   % sample rate
timestep = diff(timePoints);
fs       = 1./timestep;
overlap  = 100; %in samples

% resample time axis 
timeaxis = [min(timePoints):(1/44100):max(timePoints)]';

%%%%%%%%%%%%%%%%%%%%%%%
% points to average at.
% none, or beats/chords

% if fail go to catch
temp = beats; clear('temp');

%fix beats
beats = beats([1:4:length(beats)]);

% find indexs that are beats.
for i = 1:length(beats)
  indexs(i)  = find(timeaxis > beats(i).Time,1,'first');
end

% add zero and double over.
indexs = [indexs(1:end-1)' indexs(2:end)']+1;
indexs = [indexs; indexs(end) length(chro)];



%%%%%%%%%%%%%%%%%%%%
%%% spectrum/tones
switch method
  
  case {'chromaBeats','chromaPattern'}
    
    for chroma = 1:12
      % chroma pattern
      ts     = resample(timeseries(chro(:,chroma),timePoints),timeaxis);
      chroT(:,chroma) = ts.data;
    end

    if strcmp(method,'chromaBeats')
      for ind = 1:length(indexs)
        % average these indexs and replace
        av = mean(chroT([indexs(ind,1):indexs(ind,2)]',:));
        chroT([indexs(ind,1):indexs(ind,2)]',:) = repmat(av,(indexs(ind,2)-indexs(ind,1) + 1),1);
      end
    end
    
    %%%%%%%%%%%%%%%%%%%%%
    %%% creation of tones

    for chroma = 1:length(notes)
      tones(:,chroma) = synthSound(notes(chroma),44100,max(timeaxis));
    end
    tones =  tones.*(chroT.^2);
    tones = sum(tones,2);
    sound(tones./max(abs(tones)),44100); 
    
  case 'spectrumBeats'
    for i = 1:length(indexs)
      bits{i} = summSpec(chro(indexs(i,1):indexs(i,2)),2 )';
    end
    out = cell2mat(bits);
    out = reshape(out,[],1);
    wavwrite(out ./ max(abs(out)),44100,'preludeSon.wav');
    % sound(out,44100);

end





function [s]= synthSound(F0,Fs,d)
%usage [signal] = synthSound(F0, am, ami, fm, fmi, g, Fs, d)

n      = Fs * d;        
c      = (0:n)/Fs;                
c      = 2 * pi * F0 * c;  
s      = sin(c);        

function specAudio = summSpec(audioData,varargin)
% SUMMSPEC Make summary frame and place multiple copies in OutputFrames.
overlap = 256;
windowLength = 4096;
fs = 44100;
method = 'random';

% how far past the last multiple of the window length have we gone?
remainder = mod(length(audioData),windowLength);

% zero pad to next multiple of windowlength
adata = [audioData; zeros(windowLength-remainder,1)];

% reshape to matrix.
s = reshape(adata,windowLength,[]);

% s = [s [s(1:overlap),
[r,c] = size(s);


% xfade


duration = length(audioData)/fs /5;
copies = ceil(fs/r * duration);

% take mean across
for i = 1:copies
  fr =  ceil(rand(1,floor(c/2)) * c);
  specData{i} = mean(s(:,fr),2);
end

% cells to matrix
specAudio = cell2mat(specData);

%xfade
wind = hanning(overlap*2);
[r,c] = size(specAudio);

specAudio(1:overlap,2:end) = (specAudio(1:overlap,2:end)  .* repmat(wind(1:overlap),1,c-1)) + ...
                             (specAudio((r-overlap+1):r,1:end-1) .* repmat(wind((overlap+1):(overlap+overlap)),1,c-1)) ;

specAudio = specAudio(1:(r-overlap),:);

% make into list
specAudio = reshape(specAudio,[],1);