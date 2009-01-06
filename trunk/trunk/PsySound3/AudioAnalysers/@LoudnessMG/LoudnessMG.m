function obj = LoudnessMG(varargin)
% LoudnessMG Constructor
%

obj = struct('levelOffset', 0);

switch nargin
 case 0
  % Default Constructor
  % Inherit from the Analyser base class
  base = Analyser();
  
  obj = class(obj, 'LoudnessMG', base);

 case 1
  % Copy Constructor
  % if single argument of class LoudnessMG, return it
  arg1 = varargin{1};
  if isa(arg1, 'LoudnessMG')
    obj = arg1;
  elseif isstruct(arg1)
    % This should be a file handle
    base = Analyser(arg1);
    
    obj = class(obj, 'LoudnessMG', base);
  
  else
    error('LoudnessMG: Invalid Argument type');
  end
  
 otherwise
  error('LoudnessMG: Invalid number of input arguments')
end

% Set name
obj = set(obj, 'Name', 'Loudness (MG & B PsySound2)');

% Set default Overlap, Window size and Windowing function
ov.size = 75;
ov.type = 'percent';

obj = set(obj, 'overlap', ov);
obj = set(obj, 'windowLength', 4096);
obj = set(obj, 'windowFunc', 'Blackman');
% Note - PsySound2 used a hanning window function. However, Blackman is
% probably better.

% Specify analyser type
obj = set(obj, 'type', 'Psychoacoustic');

obj = setlevelOffset(obj, 104.11);
% obj = setlevelOffset(obj, 92.225);

end % LoudnessMG Constructor
