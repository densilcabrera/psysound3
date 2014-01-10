function varargout = plot(obj, varargin)
% PLOT  Plot function for tSpectrum

out    = [];
doPlot = true;

time = get(obj, 'Time');
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
  out    = {'image', 'surf'};
  doPlot = false;
  
 case 'image'

   if isnumeric(freq)
       
Name = get(obj,'Name');
str = 'Spectrogram ( "Frame" only)';

if strcmp(Name,str)
    
   h=surface(time,freq,zeros(size(freq,2),size(time,1)),data','EdgeColor','none'); %works for Mirpitch (see below)
     
else
     h = imagesc(time, freq, data'); % (Transpose data)
     
% Doesn't work for non linearly-scpaced abscissae!! (not working for
% MirPitch and maybe for other algorithms from MirToolbox (change line 34 or 36 if needed))
    
end
set(gca,'YDir','normal');
   else
     h = imagesc(data'); % Transpose data
     setFreqAxis(obj,freq,time,gca);
   end  

   cH = colorbar;
  
   dName = get(obj, 'DataName');
   dUnit = get(obj, 'DataUnit');
   ylabel(cH, [dName, ' (', dUnit, ')']);
  
   axis tight;
  
 case 'surf'
  h = surf(time, freq, data'); % Transpose data
  
 otherwise
  error(['Unknown option : ', option, ' given']);
end

% Modify graph, if plotting
if doPlot
  title(pTitle);
  tName = get(obj, 'TimeName');
  tUnit = get(obj, 'TimeUnit');

  fName = get(obj, 'FreqName');
  fUnit = get(obj, 'FreqUnit');
  
  xlabel([tName, ' (', tUnit, ')']);
  ylabel([fName, ' (', fUnit, ')']);

  % Assign plot handle
  out = h;
end

% Assign output, if needed
if nargout
  varargout{1} = out;
end


function setFreqAxis(obj,freq,time,gca)
     set(gca,'YDir','normal');
     if length(freq) > 28 && length(freq) < 36  % 1/3 OCTAVE
       %looking for 16 Hz or 31.5 Hz to start at
       ind16 = find(str2num(char(get(obj, 'Freq'))) == 16);
       ind31 = find(str2num(char(get(obj, 'Freq'))) == 31.5);
       if ind31 > 3
        set(gca,'YTick',ind16:3:length(freq))
       else
        set(gca,'YTick',ind31:3:length(freq))
       end
       elseif length(freq) < 16 % We can have a label every tick. 
       set(gca,'YTick',1:length(freq))
     else
       len     = length(freq); % We have too many ticks for the graph, decimate down to 10 or so.
       ticknum = 10;
       step   = floor(len/ticknum);
       set(gca,'YTick',1:step:length(freq))
     end
     ticks = get(gca,'YTick');
     set(gca,'YTickLabel',freq(ticks));
     
     xlen    = length(time);
     ticknum = 10;
     step    = ceil(xlen/ticknum);
     set(gca,'XTick',1:step:length(time));
     set(gca,'XTickLabel',num2str(time(1:step:length(time)),3));
     
% [EOF]
