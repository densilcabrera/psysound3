function obj = constructDataObjects(obj, dataBuffer, timePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% Analogous to assignoutputs
%
% Get the pitch and autocorrelation data
ac = dataBuffer{1};

p = dataBuffer{2};

% Get the frame position data
fp = dataBuffer{3};

% Get the frequency data
frequencies = dataBuffer{4};

% Get the value of the inharmonicity
inh = dataBuffer{5};

% Get the value of the roughness
rough = dataBuffer{5};

output = {};
SummOut = {};



Frame=get(obj,'Frame');

% Draw tSpectrum only if 'Frame' is selected by user with the tickbox
if Frame==1
ac1{1}=ac;
freq1{1}=frequencies;
fp1{1}=fp;

% In order to have exactly the same abscissae and ordintates as in the
% Mirtoolbox (weird, but seems necessary after verification)
[freq,TimePoints,PowSpec]=displot2(freq1,ac1,fp1); 


% % To get the PsysoundStats and data export features to work
% (even weirder, but also necessary after (a lot) of verifications)
a2=PowSpec(:,end);
PowSpec=horzcat(PowSpec,a2);
a1=PowSpec(end,:);
PowSpec=vertcat(PowSpec,a1);
% % 


tSpec   = createDataObject('tSpectrum', freq', PowSpec', TimePoints');
tSpec = set(tSpec, 'DataUnit', 'Coefficient');
tSpec.Name = 'Spectrogram ( "Frame" only)';

output{1} = tSpec;


else % Create a Spectrum
    Spec    = createDataObject('Spectrum', frequencies, ac);
    Spec = set(Spec, 'DataUnit', 'Coefficient');
    
    name=get(obj,'SpectrumType');
    Spec.Name=name;
    
    output{1} = Spec;    
end


%Assign Summary outputs to the obect

inharm.Data = inh;
inharm.Name = 'Inharmonicity';
inharm.Unit = '';
SummOut{end+1} = inharm;

roughness.Data = rough;
roughness.Name = 'Roughness';
roughness.Unit = '';
SummOut{end+1} = roughness;

obj = set(obj,'SummaryOutput',SummOut);
obj = set(obj, 'output', output);

% end constructDataObjects

end
    
    
    
  



    function [xxx,ttt,yy] = displot2(x,y,fp)
% Excerpt form displot.m 
% (MIRToolbox adapted for the use of MIRPITCH in Psysound3)

y1 = y{1};
if length(y) == 1 
    y = y{1};
    if length(x) == 1
        x = x{1};
    end
end


% figure

% Number of channels
l = size(y1,3); 


% 2-dimensional image

        
       
      for i = 1:l

            xx = zeros(size(x,1)*size(y,4),1); %,size(x,2));
            yy = zeros(size(y,1)*size(y,4),size(y,2));
            for k = 1:size(y,4)
                xx((k-1)*size(x,1)+1:k*size(x,1),1) = x(:,1);
                yy((k-1)*size(y,1)+1:k*size(y,1),:) = y(:,:,i,k);
            end
            if iscell(fp)
                fp = uncell(fp);
            end
          
                ttt = [fp(1,:) 2*fp(1,end)-fp(1,end-1)];
                if size(y,4) == 1
                    xxx = [1.5*xx(1)-0.5*xx(2);...
                           (xx(1:end-1)+xx(2:end))/2;...
                           1.5*xx(end)-0.5*xx(end-1)];
                else
                    xxx = (0:size(yy,1))';
                end
              
                
             
      end
%              surfplot(ttt,xxx,yy); Just for testing
    end
 
function h = surfplot(varargin)
%SURFPLOT Pseudocolor (checkerboard) plot.
%   SURFPLOT(C) is a pseudocolor or "checkerboard" plot of matrix C.
%   The values of the elements of C specify the color in each
%   cell of the plot. In the default shading mode, 'faceted',
%   each cell has a constant color and the last row and column of
%   C are not used. With shading('interp'), each cell has color
%   resulting from bilinear interpolation of the color at its 
%   four vertices and all elements of C are used. 
%   The smallest and largest elements of C are assigned the first and
%   last colors given in the color table; colors for the remainder of the 
%   elements in C are determined by table-lookup within the remainder of 
%   the color table.
%
%   SURFPLOT(X,Y,C), where X and Y are vectors or matrices, makes a
%   pseudocolor plot on the grid defined by X and Y.  X and Y could 
%   define the grid for a "disk", for example.
%
%   SURFPLOT(AX,..) plots into AX instead of GCA.
%
%   H = SURFPLOT(...) returns a handle to a SURFACE object.
%
%   SURFPLOT is really a SURF with its view set to directly above.

% SURFPLOT is equivalent to PCOLOR, but slighted corrected for MIRToolbox

%-------------------------------
%   Additional details:
%
%
%   PCOLOR sets the View property of the SURFACE object to directly 
%   overhead.
%
%   If the NextPlot axis property is REPLACE (HOLD is off), PCOLOR resets 
%   all axis properties, except Position, to their default values
%   and deletes all axis children (line, patch, surf, image, and 
%   text objects).  View is set to [0 90].

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9.4.1 $  $Date: 2002/10/24 02:14:11 $

%   Slightly corrected for MIRToolbox

%   J.N. Little 1-5-92

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});
error(nargchk(1,4,nargs))

cax = newplot(cax);
hold_state = ishold(cax);

if nargs == 1
    x = args{1};
    hh = surface(zeros(size(x)),x,'parent',cax);
    [m,n] = size(x);
    lims = [ 1 n 1 m];
elseif nargs == 3
    [x,y,c] = deal(args{1:3});
    %cc = zeros(size(y,1),size(x,2));
    %cc(1:size(c,1),1:size(c,2)) = c;
    hh = surface(x,y,zeros(size(y,1),size(x,2)),c,'parent',cax,'EdgeColor','none');  % Here are the modification
    lims = [min(min(x)) max(max(x)) min(min(y)) max(max(y))];
else
    error('Must have one or three input data arguments.')
end
if ~hold_state
    set(cax,'View',[0 90]);
    set(cax,'Box','on');
    axis(cax,lims);
end
if nargout == 1
    h = hh;
end
end