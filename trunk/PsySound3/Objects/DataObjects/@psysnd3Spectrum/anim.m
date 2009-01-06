function varargout = anim(obj, varargin)
% MOVIE  Movie function for tSpectrum

out    = [];
doPlot = true;

data = get(obj, 'Data');
freq = get(obj, 'Freq');

option = 'image';
if nargin == 2
  option = varargin{1};
end

pTitle = '';
if nargin == 3
  pTitle = varargin{2};
end

% Switch on option
switch(option)
 case 'GetList'
  out    = {};
  doPlot = false;
    
 otherwise
  error(['Unknown option : ', option, ' given']);
end


% Assign output, if needed
if nargout
  varargout{1} = out;
end

% [EOF]
