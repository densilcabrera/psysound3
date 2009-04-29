function obj = VirtualPitch(varargin)
% VIRTUALPITCH Constructor
%
obj = struct;

switch nargin
 case 0
  % Default Constructor
  % Inherit from the Analyser base class
  base = Analyser();

  obj = class(obj, 'VirtualPitch', base);

 case 1
  % Copy Constructor
  % if single argument of class VirtualPitch, return it
  arg1 = varargin{1};
  if isa(arg1, 'VirtualPitch')
    obj = arg1;
  elseif isstruct(arg1)
    % This should be a file handle
    base = Analyser(arg1);
    
    obj = class(obj, 'VirtualPitch', base);
  
    % Set required WindowLength
    wl = terhardtVPitch(get(obj, 'fs'), 1, 1);
    % Make sure this is an even number
    if mod(wl, 2), 
      wl = wl + 1; 
    end
    % Set
    obj = set(obj, 'windowLength', wl);
		ov.type = 'percent';
    ov.size =75;
		obj = set(obj, 'overlap' , ov);	
  else
    error('VirtualPitch: Invalid Argument type');
  end
  
 otherwise
  error('VirtualPitch: Invalid number of input arguments')
end

% Set name
obj = set(obj, 'Name', 'Pitch (Terhardt)');

% Set Hanning as the windowing function
obj = set(obj, 'windowFunc', 'Hanning');

% Specify analyser type
obj = set(obj, 'type', 'Psychoacoustic');

% end VirtualPitch constructor
