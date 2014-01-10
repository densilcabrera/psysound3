function out = dataAnalysis(obj, option, varargin)
% DATAANALYSIS  Gateway function for data analysis.
%
%

out = [];

% Switch on option
switch(option)
 case 'GetList'
  out = {'fft', 'downsample', 'difference'};
  
 case 'fft'
  out = do_fft(obj);
  
 case 'autocorr'
  out = do_autocorr(obj);
  
 case 'crosscorr'
  if isempty(varargin)
    error(['Please supply the other data object for cross-correlation ' ...
           'analysis']);
  end
  otherObj = varargin{1};
  out = do_crosscorr(obj, otherObj);
  
 case 'downsample'
  if ~(length(varargin) == 2)
    error('Please supply timing information');
  end
  arg1 = varargin{1};
  arg2 = varargin{2};
  out = do_downsample(obj, arg1, arg2);
 
 case 'difference'
  out = do_difference(obj);
 
 otherwise
  error(['Unknown option, ''', option, ''', specified']);
end

%%%%%%%%%%%%%%%%%%%
% Local functions %
%%%%%%%%%%%%%%%%%%%

%
% FFT
%
function specObj = do_fft(obj)
% Computes the spectrum of this timeseries object

ts = obj.tsObj;

len = length(ts.Data);
N   = 2^nextpow2(len);

% Magnitude data
data    = 10 .^ (ts.Data/20);
datafft = fft(data-mean(data), N)/N;  % remove mean and scale
spec    = abs(datafft) .^ 2;
fs      = inv(ts.TimeInfo.Increment);
N2      = N/2;
freqs   = (fs/N) * (0:N2-1);

% Create a spectrum object
specObj = createDataObject('Spectrum', freqs, spec(1:N2));

% Set properties
specObj.Name     = 'fft';
specObj.DataName = 'Magnitude';
specObj.DataUnit = 'Units';

% end do_fft

%
% DOWNSAMPLE
%
function ts = do_downsample(obj, P, Q)
% Downsamples the timeseries object by a factor of (P/Q) times the
% sampling rate

% Note : uses Matlab's resample function. We may want to use upfirdn
% instead?

% Note the timeseries version of resample is not quite adequate
tsObj = obj.tsObj;

data = tsObj.data;
fs   = 1/tsObj.TimeInfo.Increment;

% This is the new sampling rate
Fs  = (P/Q)*fs;
Inc = 1/Fs;

% Offset to zero
offset = data(1);

% Call resample
Data = resample(data - offset, P, Q) + offset;

% Create a new timeseries object
ts = createDataObject('tSeries', Data);

% Copy over some attributes
ts.tsObj.Name = sprintf('%s, fs = %.2f Hz', tsObj.Name, Fs);
ts1 = setuniformtime(ts.tsObj,'Interval',Inc);
ts=set(ts,'time',get(ts1,'time'));
% ts.tsObj.TimeInfo.Increment = Inc;
ts.tsObj.DataInfo = tsObj.DataInfo;

% end do_downsample

%
% AUTOCORRELATION
%
function tSpec = do_autocorr(obj)
% Computes the AutoCorrelation of the time data.
% NOTE: This is almost identical to the AudioAnalyser

ts = obj.tsObj;

ACF = autocorrelation(ts.data);

N  = length(ts.data);
fs = 1/ts.TimeInfo.Increment;

lagsListing = [0:(1/fs):(N/fs)]';
lagsListing = lagsListing(1:ceil(end/2));

% Create the Time Spectrum
tSpec = createDataObject('tSpectrum', lagsListing, ACF, ts.Time);

tSpec.Name     = 'Correlogram';
tSpec.DataName = 'Correlation';
tSpec.DataUnit = 'Coefficient';
tSpec.FreqName = 'Lag';
tSpec.FreqUnit = 's';

% end do_autocorr

%
% CROSSCORRELATION
%
function tSpec = do_crosscorr(obj1, obj2)
% Computes the CrossCorrelation of the time data.
% NOTE: This is almost identical to the AudioAnalyser

ts1 = obj1.tsObj;
ts2 = obj2.tsObj;

if length(ts1.data) ~= length(ts2.data)
  error(['Please supply timeseries objects of same length for ' ...
         'cross-correlation analysis']);
end

ACF = crosscorrelation(ts1.data, ts2.data);

N  = length(ts1.data);
fs = 1/ts1.TimeInfo.Increment;

lagsListing = [0:(1/fs):(N/fs)]';
lagsListing = lagsListing(1:ceil(end/2));

% Create the Time Spectrum
tSpec = createDataObject('tSpectrum', lagsListing, ACF, ts1.Time);

tSpec.Name     = ['Correlogram:', ts1.Name, '-', ts2.Name];;
tSpec.DataName = 'Correlation';
tSpec.DataUnit = 'Coefficient';
tSpec.FreqName = 'Lag';
tSpec.FreqUnit = 's';

% end do_crosscorr

%
% DIFFERENCE
%
function ts = do_difference(obj)
% Downsamples the timeseries object by a factor of (P/Q) times the
% sampling rate

% Note : uses Matlab's resample function. We may want to use upfirdn
% instead?

% Note the timeseries version of resample is not quite adequate
tsObj = obj.tsObj;

data = tsObj.data;
fs   = 1/tsObj.TimeInfo.Increment;

% Call resample
Data = diff(data);
Data = [Data; Data(end)];

% Create a new timeseries object
ts = createDataObject('tSeries', Data);

% Copy over some attributes
ts.tsObj.Name = sprintf('%s, Differenced', tsObj.Name);
ts.tsObj.TimeInfo.Increment = tsObj.TimeInfo.Increment;
ts.tsObj.DataInfo = tsObj.DataInfo;

% EOF

function ts = do_threshold(obj,obj2)
% Thresholds the timeseries object by another (synchronised) timeseries result

% Note the timeseries version of resample is not quite adequate
tsObj1 = obj.tsObj;
tsObj2 = obj2.tsObj;

data1 = tsObj1.data;
data2 = tsObj2.data;
fs1   = 1/tsObj1.TimeInfo.Increment;
fs2   = 1/tsObj2.TimeInfo.Increment

% do threshold 
Data = diff(data);

% Create a new timeseries object
ts = createDataObject('tSeries', Data);

% Copy over some attributes
ts.tsObj.Name = sprintf('%s, Thresholded by %s', tsObj1.Name, tsObj2.Name);
ts.tsObj.TimeInfo.Increment = tsObj.TimeInfo.Increment;
ts.tsObj.DataInfo = tsObj.DataInfo;

% EOF
