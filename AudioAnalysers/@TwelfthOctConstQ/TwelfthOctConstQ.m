function obj = TwelfthOctConstQ(varargin)
% TwelfthOctConstQ Constructor
%
obj = struct;

% Subclass FFT
base = FFT(varargin{:});
obj  = class(obj, 'TwelfthOctConstQ', base);

% Set Name
obj = set(obj, 'Name', '1/12-Oct Spectrum Const Q Transform');

% Set default Overlap, Window size and Windowing function
ov.size = 75;
ov.type = 'percent';

obj = set(obj, 'overlap', ov);

fs = get(obj, 'fs');
minFreq = 27.5;
bins = 12;
Q= 1/(2^(1/bins)-1);
fftLen= 2^nextpow2( ceil(Q*fs/minFreq) );
obj = set(obj, 'windowLength', fftLen);
obj = set(obj, 'windowFunc', 'Rectangular');
% Set stereo mode
obj = set(obj, 'multiChannelSupport', true);

% Set the levelOffset
obj = setlevelOffset(obj, 0.66);
