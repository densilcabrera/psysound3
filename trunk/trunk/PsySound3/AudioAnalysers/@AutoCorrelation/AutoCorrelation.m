function obj = AutoCorrelation(varargin)
% AUTOCORRELATION Constructor
%
obj = struct;

% Subclass FFT
base = FFT(varargin{:});
obj  = class(obj, 'AutoCorrelation', base);

% Set name
obj = set(obj, 'Name', 'Auto-Correlation');

% Specify analyser type
obj = set(obj, 'type', 'FrequencyDomain');

% Set the levelOffset
obj = setlevelOffset(obj, 0);