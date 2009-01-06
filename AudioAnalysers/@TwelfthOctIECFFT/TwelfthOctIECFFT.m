function obj = TwelfthOctIECFFT(varargin)
% TwelfthOctIECFFT Constructor
%
obj = struct;

% Subclass FFT
base = FFT(varargin{:});
obj  = class(obj, 'TwelfthOctIECFFT', base);

% Set Name
obj = set(obj, 'Name', '1/12-Oct Spectrum IEC (FFT)');

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
