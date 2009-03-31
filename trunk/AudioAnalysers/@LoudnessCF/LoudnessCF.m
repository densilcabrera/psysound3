function obj = LoudnessCF(varargin)
% LOUDNESSCF Constructor
%
obj = struct;

switch nargin
 case 0
  % Default Constructor
  % Inherit from the Analyser base class
  base = Analyser();

  obj = class(obj, 'LoudnessCF', base);

 case 1
  % Copy Constructor
  % if single argument of class LoudnessCF, return it
  arg1 = varargin{1};
  if isa(arg1, 'LoudnessCF')
    obj = arg1;
  elseif isstruct(arg1)
    % This should be a file handle
    base = Analyser(arg1);
    
    obj = class(obj, 'LoudnessCF', base);
  
    % Set window length
    fs = get(obj, 'fs');
    wl = dlm(fs, 1);
    if mod(wl, 2)
      wl = wl + 1; % xxx can I do this?
    end
    obj = set(obj, 'windowLength', wl);
    
  else
    error('LoudnessCF: Invalid Argument type');
  end
  
 otherwise
  error('LoudnessCF: Invalid number of input arguments')
end

% Set name
obj = set(obj, 'Name', 'Dynamic Loudness (C & F)');

% Specify analyser type
obj = set(obj, 'type', 'Psychoacoustic');

% end LoudnessCF constructor
