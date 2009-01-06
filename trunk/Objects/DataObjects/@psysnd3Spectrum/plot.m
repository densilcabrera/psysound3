function varargout = plot(obj, option, varargin)
% PLOT  Plot function for Spectrum
%

out    = [];
doPlot = true;

if nargin < 2
  option = 'line';
end


pTitle = '';
if nargin == 3
  pTitle = varargin{1};
end

objName = get(obj, 'Name');

% format frequency data correctly for different options
if ~isnumeric(obj.Freq)
  switch (option)
    case {'line'}
      for i = 1:length(obj.Freq)
        freq(i) = str2num(obj.Freq{i});
      end
      obj = set(obj,'Freq',freq');
    otherwise
  end
end

  
% Switch on option
switch(option)
 case 'GetList'
  out    = {'line', 'bar','stem'};
  doPlot = false;
  % Assign output, if needed
  if nargout
    varargout{1} = out;
  end
  return;
 case 'line'
  if strcmp(get(obj, 'FreqScale'), 'log');
    h = semilogx(obj.Freq, obj.Data);
  else
    h = plot(obj.Freq, obj.Data);
  end
  
  
 case 'bar'
   if isnumeric(obj.Freq)
     h = bar(obj.Freq, obj.Data);
   else
     h = bar(obj.Data);
   end  

 case 'stem'
   if isnumeric(obj.Freq)
     h = stem(obj.Freq, obj.Data);
   else
     h = stem(obj.Data);
   end


  otherwise
  error(['Unknown option : ', option, ' given']);
end

% Check the XAxis 
switch option
  case {'bar','stem'}
  try
    if findstr(objName, 'Octave')
      data = get(obj, 'Data');
      freq = get(obj, 'Freq');
      if length(obj.Data) == 11
        set(gca, 'XTick', 1:11);
        set(gca, 'XTickLabel', freq);
      else
        set(gca, 'XTick', [2:3:length(freq)]);
        set(gca, 'XTickLabel', freq([2:3:length(freq)]));
      end
      limits = axis;
  %    set(gca,'Clipping','on');
      axis([limits(1) limits(2) 0 limits(4)]);
    end
  catch
    
  end
end

% Modify graph, if plotting
if doPlot
  title(pTitle);
  fName = get(obj, 'FreqName');
  fUnit = get(obj, 'FreqUnit');
	if ~isempty(fUnit)
		fUnit = [' (' fUnit ')'];
	end
  dName = get(obj, 'DataName');
  dUnit = get(obj, 'DataUnit');
  if ~isempty(dUnit)
		dUnit = [' (' dUnit ')'];
	end
  
  xlabel([fName fUnit]);
  ylabel([dName dUnit ]);
  
  % Assign plot handle
  out = h;
end

% Assign output, if needed
if nargout
  varargout{1} = out;
end

% [EOF]
