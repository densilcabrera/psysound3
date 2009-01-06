function obj = Cepstrum(varargin)
% CEPSTRUM Constructor
%
obj = struct;

% Subclass FFT
base = FFT(varargin{:});
obj  = class(obj, 'Cepstrum', base);

% Set Name
obj = set(obj, 'Name', 'Cepstrum (real)');

% Set the levelOffset
obj = setlevelOffset(obj, 97.01);