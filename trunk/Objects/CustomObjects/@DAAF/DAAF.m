function obj = DAAF(varargin)
% DAAF Base class constructor
%
% Inputs:
%
%   1. TimeSeries Object with Data
%   2. AudioFile Object
%   3. Segmentation Type
%


switch(nargin)
  case 0
    obj.Name  = 'DAAF';

    obj = class(obj, 'DAAF');
  case 1
    arg = varargin{1};

    if isa(arg, 'DAAF')
      % Copy constructor
      obj = arg;
    else
      error('Unknown argument');
    end

  case {3,4,5}
    ts = varargin{1};
    AudioObj = varargin{2};

    obj.Name           = ts.DataObj.Name;
    obj.Units          = ts.DataObj.DataInfo;
    obj.SegType        = lower(varargin{3});
    obj.DataObject     = ts;
    obj.DataThreshold  = [0 1];


    obj.OutputDataRate = ts.AnalyserObj.outputDataRate;
    obj.OutputSamples  = ts.AnalyserObj.outputSamples;
    obj.Stats          = ts.DataObj.stats;
    obj.StatFrames     = {};
    obj.FS             = ts.AnalyserObj.fs;
    obj.Duration       = ts.AnalyserObj.samples / obj.FS;
    obj.AudioFilename  = ts.AnalyserObj.filename;
    obj.AudioData      = AudioObj.data;
    obj.OutputFrames   = {};
    obj.OutputAudio    = [];
    obj.WindowFunction = 'hanning';
    obj.Overlap        = 0.25;              % Default percentage overlap - used in xfade
    switch lower(varargin{3})
      case 'simple'
        obj.TimePoints     = ts.DataObj.time;
        obj.Increment      = ts.DataObj.TimeInfo.Increment;
        if isnan(obj.Increment)
          obj.Increment = median(diff(ts.DataObj.time));
        end
        obj.FrameTimes     = obj.TimePoints;
        obj.DataPoints     = ts.DataObj.data;
        obj.FrameSamples   = floor(obj.FrameTimes * obj.FS) + 1;
        obj.WindowLength   = floor((obj.Increment + obj.Overlap * obj.Increment) * obj.FS); % This is the window we will take
        obj.FrameSamples   = [obj.FrameSamples (obj.FrameSamples + obj.WindowLength - 1)];

        % The original file has been padded with extra zeroes on front and end,
        % and so we have to use a similar file to create our matrix
        % We have also added some zeros to deal with the extra zeroes at the
        % end of the file added to fill out the final window.
        try
          extrazeros = zeros(floor((max(obj.TimePoints) - obj.Duration) * obj.FS - obj.WindowLength),1);
          tempFile           = [zeros(ts.AnalyserObj.windowLength/2,1); ...
            obj.AudioData; ...
            extrazeros; ...
            zeros(ts.AnalyserObj.Analyser.windowLength/2,1)];

        catch
          tempFile           = [zeros(ts.AnalyserObj.windowLength/2,1); ...
            obj.AudioData; ...
            zeros(ts.AnalyserObj.windowLength/2,1)];
        end


        % Check whether obj.FrameSamples refers to a common window size
        windows = obj.FrameSamples(:,1)-obj.FrameSamples(:,2);
        lengths = sum(diff(windows));
        if lengths == 0
          obj.AllWindowsSameLength = 1;
          windowLength = abs(windows(1))+1;
        else
          obj.AllWindowsSameLength = 0;
        end

        if obj.AllWindowsSameLength
          % create pre allocated matrix
          frames = zeros(windowLength,length(obj.FrameSamples));
          % Grab the frames from the new temp File
          % Matrix version (much faster!)
          for i = 1:length(obj.FrameSamples)
            try
              fr = tempFile(obj.FrameSamples(i,1):obj.FrameSamples(i,2));
            catch
              fr = tempFile(obj.FrameSamples(i-1,1):obj.FrameSamples(i-1,2));
            end

            [r,c] = size(fr);
            if r<c
              fr = fr';
            end
            frames(:,i)    = fr;
          end
          obj.Frames = num2cell(frames,1);
        else
          % Grab the frames from the new temp File
          % Cell array version (slower, but probably ok for most things)
          for i = 1:length(obj.FrameSamples)
            obj.Frames{i}    = tempFile(obj.FrameSamples(i,1):obj.FrameSamples(i,2));
          end
        end

      case 'specdiff'

      case 'beatspectrum'
        obj.Overlap        = 0.05;
        obj.FrameTimes           = varargin{4}.DataObj.Events; % beats
        obj.Increment            = ts.DataObj.TimeInfo.Increment;
        obj.WindowLength         = floor((obj.Increment + obj.Overlap * obj.Increment) * obj.FS);
        beats                    = varargin{4}.DataObj.Events; % fix beats
        % This is where we work out which beats are the start of a bar.

        prompt={'Anacrusis length:','Number of beats to average:','Decimation Factor'};
        name='Bar Parameters';
        numlines=1;
        defaultanswer={'0','4','8'};
        answer                   = inputdlg(prompt,name,numlines,defaultanswer);
        anacrusis                = str2num(answer{1});
        beatsToAvg               = str2num(answer{2});
        decFactor                = str2num(answer{3});
        beats                    = beats((1+anacrusis):beatsToAvg:length(beats));
        beats(2:end+1)           = beats;
        beats(end+1)             = beats(end);
        beats(1).Name            = num2str(0);
        beats(1).Units           = 'seconds';
        beats(1).Time            = 0;
        beats(end).Name        = num2str(obj.Duration);
        beats(end).Units       = 'seconds';
        beats(end).Time        = obj.Duration;
        

        for i = 1:length(beats)-1  % find indexs that are boundaries.
          obj.FrameSamples(i)    = find(AudioObj.Time > beats(i).Time,1,'first');
        end
        obj.FrameSamples(end+1) = length(AudioObj.Time)-1; % Don't forget last sample

        % add zero and double over.
        obj.FrameSamples         = [obj.FrameSamples(1:end-1)' obj.FrameSamples(2:end)'] + 1;


        for i = 2:length(beats)  % calculate data for the particular bar.
          timeslice           = find(ts.DataObj.time >= beats(i-1).Time & ts.DataObj.time < beats(i).Time);
          dataslice           = ts.DataObj.data(timeslice);
          obj.DataPoints(i-1) = median(dataslice);
          obj.TimePoints(i-1) = beats(i-1).Time;
        end
        
        blurFlag = questdlg('Would you like to blur the segments?', 'Frame Blurring', 'Blur', 'Original', 'Blur');
        for i = 1:length(obj.FrameSamples)
          adata               = AudioObj.Data(obj.FrameSamples(i,1):obj.FrameSamples(i,2));
          if strcmp(blurFlag,'Blur')
            obj.Frames{i}     = blurAudio2(adata, 2048, 0.25, decFactor);
          else
            obj.Frames{i}     = adata(1:(floor(end/decFactor)));
          end
        end

        if nargin > 4
          salience = varargin{5};

          for i = 1:length(beats)-1  % calculate data for the particular bar.
            % find time between first beat and second beat
            salRows = find(salience.DataObj.Time > beats(i).Time & salience.DataObj.Time < beats(i+1).Time);
            % find data that corresponds
            barSalience = salience.DataObj.Data(salRows,:);
            % send the data to FindChord
            barSalience = mean(barSalience.^2);
            chordname = FindChord(barSalience);
            % Put the resulting chord in appropriate EventData spot
            beats(i).EventData = chordname;
          end
        end

        if 0 % plotting
          figure;
          plot(salience.DataObj); hold on;
          for i = 1:length(beats)-1
            plot([beats(i).Time beats(i).Time],[1 12],'w');
            text(beats(i).Time,1,beats(i).EventData,'Color','w','Interpreter','none');
          end
        end
        obj.AllWindowsSameLength = 0;
        
        % fix stats
        obj.Stats    =  set(obj.Stats,'max',max(obj.DataPoints));
        obj.Stats    =  set(obj.Stats,'min',min(obj.DataPoints));
        obj.Stats    =  set(obj.Stats,'median',median(obj.DataPoints));
        obj.Stats    =  set(obj.Stats,'mean',mean(obj.DataPoints));
     
    end
    obj = class(obj, 'DAAF');

    % Put the frames for the stats into their place
    try obj = stats(obj); 
    catch
    end

  otherwise
    error(['Invalid number of arguments for DAAF : ', ...
      num2str(nargin)]);
end



function output = blurAudio(audio, wl, ol, dec)
% BLURAUDIO Blur Audio and place multiple copies in OutputFrames.

duration  = length(audio) / dec;

% how far past the last multiple of the window length have we gone?
remainder = mod(length(audio),wl);

% zero pad to next multiple of windowlength
adata     = [audio; zeros(wl-remainder,1)];

% reshape to matrix.
s         = reshape(adata,wl,[]);
[r,c]     = size(s);
copies    = ceil(duration / (wl * (1 - ol))) + 1;

% take mean across
for i = 1:copies
  fr           = ceil(rand(1,floor(c/4)) * c);
  outFrames{i} = mean(s(:,fr),2); % Turn up by 12 dB;
end

outFrames = cell2mat(outFrames);
wlr = ceil(wl * ol);

wind = hanning(wl * ol * 2);

[r,c] = size(outFrames);
ovFrames = [outFrames((wl - wlr + 1):wl,1:end-1)  .* repmat(wind((end/2+1):end), 1, c-1) + ...
  outFrames(1:wlr, 2:end)               .* repmat(wind(1:end/2)      , 1, c-1)];


output = reshape([ovFrames; outFrames(wlr+1:wl-wlr, 2:end)] ,[],1);
output = output(1:floor(length(audio)/dec)); % No really, exactly the same length.

% EOF



function output = blurAudio2(audio, wl, ol, dec)
%% BLURAUDIO2 Blur Audio and place multiple copies in OutputFrames.
% New method with randomisation.


winNum=512;
ol = wl * ol;
win = hann(ol);
outdur = 0;
duration = length(audio);

duration = duration /dec+ wl +wl;
col = 1;

audio = audio - mean(audio); % Remove dc
while outdur < duration
  
  winsizerand = floor(rand * wl) + wl/2; % Choose Random Windowsize
  avWindows = zeros(winsizerand,512); % Init
  for i = 1:winNum
    winstart = floor(rand * (length(audio) - winsizerand*2))+1;
    avWindows(:,i) = audio(winstart:winstart+winsizerand-1);
  end
  
  % sum and concatenate with an overlap
  Frames{col} = sum(avWindows,2)/(sqrt(winNum));
  Frames{col} = Frames{col} - mean(Frames{col}); 
  outdur = outdur+winsizerand; %in samples
  col = col + 1;
end


output = Frames{1}(1:end-ol/2);
for i = 2:length(Frames)
  olSlice = Frames{i-1}(end-ol/2+1:end) .* win(ol/2+1:end)   + Frames{i}(1:ol/2).* win(1:ol/2);
  output = [output; olSlice; Frames{i}(ol/2+1:end-ol/2)]; 
end
try
  output = output(1:floor(length(audio)/dec)); % No really, exactly the same length.
end
  % EOF



function [chord,R2]= FindChord(chromata)
% finds the octave-spaced chord chroma profile that most closely matches the chroma profile%
% var	chroma, intervals: string;
% 	root: integer;
% 	rootX: integer;
% 	i: integer;
% 	r, SUMx, SUMx2: longreal; %correlation variables%
% 	rX: longreal;

%chromata = [chromata(11:end) chromata(1:10)];

if sum(chromata) == 0
  chord = 'none';
  return
end

% ChrdPr - one profile per row, each chroma in the 12 columns
ChrdPr= [...
  2.28, 0,    0.05, 0,    0,    0.35, 0,    0,    0.19, 0,    0.03, 0;
  1.44, 1.37, 0.03, 0.03, 0,    0.22, 0.21, 0,    0.13, 0.12, 0.03, 0.02;
  1.43, 0,    1.53, 0,    0.03, 0.18, 0,    0.18, 0.11, 0,    0.21, 0;
  1.38, 0.02, 0.03, 1.42, 0,    0.4,  0,    0,    0.66, 0,    0.02, 0.12;
  1.68, 0,    0.09, 0,    1.09, 0.16, 0.02, 0,    0.09, 0.17, 0.02, 0;
  0.95, 0.09, 0.02, 0.02, 0,    1.82, 0,    0.02, 0.08, 0,    0.25, 0;
  1.46, 0,    0.31, 0,    0.03, 0.23, 1.51, 0,    0.29, 0,    0.02, 0.23;
  0.45, 0.82, 0.01, 0.05, 0,    1.62, 0.06, 0.02, 0.04, 0.04, 0.24, 0.01;
  1.48, 0.04, 0.06, 0.01, 0.48, 1.1,  0.01, 0.01, 0.1,  0.07, 0.15, 0;
  0.79, 0.08, 0.72, 0.01, 0.01, 1.45, 0,    0.18, 0.06, 0,    0.46, 0;
  0.77, 0.11, 0.02, 0.68, 0,    1.46, 0,    0.01, 0.3,  0,    0.17, 0.05;
  0.82, 0,    1.34, 0,    0.06, 0.1,  0.95, 0.1,  0.16, 0,    0.12, 0.15;
  1.37, 0,    0.26, 0,    0.81, 0.14, 0.86, 0,    0.17, 0.1,  0.02, 0.1;
  1.35, 0,    0.68, 0.08, 0.01, 0.17, 0,    1.39, 0.05, 0.02, 0.1,  0;
  1.08, 0.02, 0.23, 0.93, 0.02, 0.31, 1.11, 0,    0.71, 0,    0.02, 0.49;
  1.34, 0.01, 0.02, 1.09, 0,    0.32, 0,    0.79, 0.32, 0.02, 0.01, 0.06;
  1.62, 0,    0.05, 0.05, 0.55, 0.17, 0.01, 0.58, 0.06, 0.16, 0.01, 0;
  1.22, 0.12, 0.07, 0,    1.24, 0.12, 0.07, 0,    1.26, 0.12, 0.06, 0;
  0.65, 0.77, 0.04, 0.01, 1.17, 0.05, 0.21, 0,    1.12, 0.24, 0.05, 0.01;
  0.33, 1.16, 0.01, 0.04, 0.06, 1.08, 0.1,  0.02, 0.94, 0.03, 0.27, 0.01;
  1.11, 0.04, 0.57, 0.1,  0.01, 1.05, 0,    1.11, 0.05, 0.01, 0.31, 0;
  0.96, 0.12, 0.63, 0,    1.09, 0.08, 0.05, 0.06, 1.13, 0.08, 0.18, 0;
  0.67, 0.09, 1.11, 0,    0.2,  0.09, 0.73, 0.08, 1.11, 0,    0.19, 0.09;
  0.51, 0.3,  0.01, 0.47, 0.05, 0.92, 0.01, 0.01, 1.28, 0,    0.19, 0.04;
  0.62, 0.31, 0.61, 0.01, 0.13, 1.1,  0.01, 0.15, 1.01, 0,    0.54, 0;
  0.51, 0.12, 0.09, 0.47, 0.08, 0.15, 0.49, 0,    1.38, 0,    0.04, 0.2;
  0.83, 0.02, 0.61, 0.86, 0.02, 0.61, 0.88, 0.02, 0.61, 0.87, 0.02, 0.62];

interval{1} = '___';
interval{2} = '__M';
interval{3} = '__m';
interval{4} = 'm__';
interval{5} = 'M__';
interval{6} = '_P_';
interval{7} = '_d_';
interval{8} = 'M_M';
interval{9} = '_PM';
interval{10} = 'm_m';
interval{11} = '_Pm';
interval{12} = 'M_m';
interval{13} = '_dm';
interval{14} = 'SP_';
interval{15} = 'md_';
interval{16} = 'mP_';
interval{17} = 'MP_';
interval{18} = 'MA_';
interval{19} = 'mPM';
interval{20} = 'MPM';
interval{21} = 'SPm';
interval{22} = 'MAm';
interval{23} = 'Mdm';
interval{24} = 'mPm';
interval{25} = 'mdm';
interval{26} = 'MPm';
interval{27} = 'mdd';

modOffset = [0 1 2 0 0 5 6 1 5 2 5 2 6 7 0 0 0 8 1 5 7 2 2 5 2 8 6];
chromaNames = {'A ','B flat ','B ','C ','D flat ','D ','E flat ','E ','F ','F sharp ','G ','A flat '};

r       = 0;
SUMx    = 0;
SUMx2   = 0;
SUMx  = sum(chromata);
SUMx2 = sum(chromata.^2);

for i = 1:27
  [rX, rootX] = ChordProfile(ChrdPr(i,:), SUMx, SUMx2, chromata);
  if r < rX
    r = rX;
    root = mod((rootX + modOffset(i)),12);
    intervals = interval{i};
  end
  chroma = chromaNames{root+1};

  chord = [chroma  intervals];
  R2 = r^2;
end


function [rX, rootX] =  ChordProfile(chord, SUMx, SUMx2, chromata)
% ChordProfile is called by FindChord for correlation calculations%
% type	localarray = array (0..11)  real;
% var	i, j: integer;
% 	chordsum: longreal;
% 	chordsum2: longreal; %sum  squares%
% 	SUMxy, SUMy, SUMy2, SP, SSx, SSy: longreal; %correlation variables%
% 	chord: localarray;
rX = 0;
% chord(1) = w0;
% chord(2) = w1;
% chord(3) = w2;
% chord(4) = w3;
% chord(5) = w4;
% chord(6) = w5;
% chord(7) = w6;
% chord(8) = w7;
% chord(9) = w8;
% chord(10) = w9;
% chord(11) = w10;
% chord(12) = w11;

SUMy = sum(chord);
SUMy2 = sum(chord.^2);
SSy = SUMy2 - (SUMy^2) / 12;

for i = 0:11
  SUMxy = 0;
  for j = 0:11
    SUMxy = SUMxy + chord(j+1)  * chromata(mod((i + j),  12) + 1);
  end
  SP    = SUMxy - SUMx      * SUMy / 12;
  SSx   = SUMx2 - (SUMx^2) / 12;
  if (rX < (SP / sqrt(SSx * SSy)))
    rX     = SP / sqrt(SSx * SSy);
    rootX  = i+1;
  end
end % for i = 1:12  %




