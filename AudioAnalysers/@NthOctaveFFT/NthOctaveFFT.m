function obj = NthOctaveFFT(varargin)
% 1/N-octave Constructor
%   three .m files; [readData], processWindow and assignOutputs, are repeated until the
%   entire analysis audio file is completed.
%   allocOutputDataStorage.m - allocates storage memory
%   constructDataObjects.m - puts output data into correct format for PsySound object
    % (Spectrum object, Timeseries object, or Timespectrum object)
%

% default to ten 1/3-octave bands starting at 100 Hz
obj = struct('NOct', 3, 'NOctStartHz', 100, 'NOctG', 2, ...
    'NOctNumBands', 10, ...
    'NOctCentreFreq', [100 125 160 200 250 315 400 500 630 800], ...
    'NOct_FFT_2_NOctFreq', [1 1 1 1 1 1 1 1 1 1]);

% Subclass FFT
base = FFT(varargin{:});
obj  = class(obj, 'NthOctaveFFT', base);

% Set Name
obj = set(obj, 'Name', '1/N-Octave Band Spectrum (FFT)');

% Set default Overlap, Window size and Windowing function
ov.size = 75;
ov.type = 'percent';

obj = set(obj, 'overlap', ov);
obj = set(obj, 'windowLength', 65536);
obj = set(obj, 'windowFunc', 'Blackman');

% Set the levelOffset
obj = setlevelOffset(obj, 0.66);
