function obj = CPBFFT(varargin)
% CPBFFT Constructor
%
obj = struct;

% Subclass FFT
base = FFT(varargin{:});
obj  = class(obj, 'CPBFFT', base);

% Set Name
obj = set(obj, 'Name', '1/3-Oct & Oct Spectrum (FFT)');

% Set default Overlap, Window size and Windowing function
ov.size = 75;
ov.type = 'percent';

obj = set(obj, 'overlap', ov);
obj = set(obj, 'windowLength', 65536);
obj = set(obj, 'windowFunc', 'Blackman');
% Set stereo mode
obj = set(obj, 'multiChannelSupport', true);

% Set the levelOffset
obj = setlevelOffset(obj, 0.66);
