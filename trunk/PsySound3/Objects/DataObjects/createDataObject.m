function obj = createDataObject(objType, varargin)
% CREATEDATAOBJECT  Wrapper function for creating PsySound3
%                   dataObjects that simply appends the 'psysnd3'
%                   suffix

if ~nargin
  error('Invalid number of inputs');
end

% Keep it simple
switch(objType)
 case 'tSeries'
  obj = psysnd3tSeries(varargin{:});

 case 'AudioTSeries'
  obj = psysnd3AudioTSeries(varargin{:});

 case 'tSpectrum'
  obj = psysnd3tSpectrum(varargin{:});
    
 case 'Spectrum'
  obj = psysnd3Spectrum(varargin{:});
  
 case 'Stats'
  obj = psysnd3Stats(varargin{:});
  
 otherwise
  error(['Unknown object type requested : ', objType]);
  
end

% [EOF]
