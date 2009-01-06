function obj = CepstrumComplex(varargin)
% CEPSTRUM Constructor
%
obj = struct;

% Subclass FFT
base = FFT(varargin{:});

% set empty field for lifter frequency;
obj.LifterF = [];

obj  = class(obj, 'CepstrumComplex', base);

% Set Name
obj = set(obj, 'Name', 'Cepstrum (complex)');

% Set the levelOffset
obj = setlevelOffset(obj, 97.01); % should be same as FFT Spectrum
