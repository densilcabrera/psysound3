function [vPitch, sPitch] = terhardtVPitch(fs, data, varargin)
% TERHARDTVPITCH 
%
% fs   - sample rate
% data - power spectrum
% varargin - this is just to get the window length

lowerLimitHz = 20; % 20Hz lower freq. limit
upperLimitHz = 5e3;% 5kHz upper freq. limit.

% Output variables
vPitch=[]; sPitch=[];

% if run with one argument, spit back the required window size.
if nargin > 2
  vPitch = round(fs/12.5); % 12.5 Hz bin seperation
  return
end

if ~isvector(data)
  error('terhardtVPitch: cannot handle matrix data');
end

% for multi channel data, sum power spectra across channels
% [r, c] = size(data);
% if c > 1
%     data = sum(data')/c;
% end

if 0
  if length(data)~=fs
    error(['Incorrect data block length call' ,...
           'moduleTerhardtVPitch(fs) to get the correct length']);
    return;
  end
end

% isolate the relevant frequencies to process ...
fsBin = length(data);

if fsBin == 1
  % Early return otherwise binFreq becomes NaN
  return;
end

binFreq = 0:fs/(fsBin-1):fs;
fBins   = find((binFreq>lowerLimitHz)&(binFreq<upperLimitHz));

if isempty(fBins)
  % Early return for no bins
  return;
end

if fBins(1)~=1
  missedLowerBins=1:fBins(1)-1;
else
  missedLowerBins=[];
end
dataTrimmed=10*log10(data(fBins)); % dB SPL
data=10*log10(data(1:fBins(end)));
% plot(binFreq(fBins),data); pause
%  set negative dB SPLs to zero
% indexes=find(data<0);
% if ~isempty(indexes)
%    data(indexes)=0;
% end
% plot(data); pause

% peak pick most significant spectral peaks to enter ...
% write the data to a temp. file ...

peaks=peakPick(dataTrimmed); % returns bin indexes
if ~isempty(missedLowerBins)
  peaks=peaks+missedLowerBins(end); % re-shift up by the number of bins missed
end
if isempty(peaks)
%  disp('no peaks found in window of data - returning');
  return
end

if 0
  figure(2);
  plot(binFreq(fBins),data(fBins)); hold on
  plot(binFreq(peaks),data(peaks),'go'); hold off
  pause
end

% catch with error if there are more peaks then the Terhardt file
% can handle ...
if length(peaks)>60
  error([' Too many peaks found ... please alter PTMAX in Terhardt''s ' ...
         'ptp2svp.c file and compile again']);
  return
end

% interpolate for a better frequency estimate
% this loop may need speeding up (i.e. removal) ...
for j=1:length(peaks)
  fc(j) = binFreq(peaks(j))+0.46*(data(peaks(j)+1)-data(peaks(j)-1));
  %[binFreq(peaks(j)) fc(j)]
  %pause
end

if isempty(fc)
  disp('no peaks found');
end

if size(data(peaks)+2)~=size(fc) % fix transposition
  fc=fc';
end

% use ported ptp2svp code
[vPitch, sPitch] = ptp2svp(fc, data(peaks)+2);

end % function terhardtVPitch

function peaks = peakPick(data)
% pad data by zeros on front and back ... aids the processing
[r,c]=size(data);
if r>c data=data'; end
data=[zeros(1,5) data zeros(1,5)];

% peak picking ...
% stage 1 : roughly prune the spectrum back to peaks
% Pruning can half the looping time ...
% a] find differences ...
ref=diff(data);

% b] derive a suitable correlation mask ...
mask=[1 -1 zeros(1,length(ref)-2)]*max(abs(ref));

% c] correlate
REF=fft(ref); MASK=fft(mask);
res=real(ifft(REF.*conj(MASK)));
% peak indexes are now held ... with some 'peaky slopes' erroneously marked
indexes=find(res>0)+1;
remove=find(indexes<6);
if ~isempty(remove)
  indexes=indexes(max(remove)+1:end);
end
remove=find(indexes>(length(data)-6));
if ~isempty(remove)
  indexes=indexes(1:min(remove)-1);
end
% peak criterion ...
oldIndexes=indexes; clear indexes
indexes=[];
for j=1:length(oldIndexes)
  if all(data(oldIndexes(j))>data(oldIndexes(j)+[-1 1]))
    indexes(length(indexes)+1)=oldIndexes(j);
  end
end
% 7 dB criterion ...
oldIndexes=indexes; clear indexes
indexes=[];
for j=1:length(oldIndexes)
  if all(data(oldIndexes(j))-data(oldIndexes(j)+[-3 -2 2 3])>=7)
    indexes(length(indexes)+1)=oldIndexes(j);
  end
end
if 0
  figure(1);
  plot(indexes,data(indexes),'go'); hold on
  plot(data); hold off
  pause
end

peaks=indexes-5; % remove zero padded indexes
end % function peakPick

% [EOF]
