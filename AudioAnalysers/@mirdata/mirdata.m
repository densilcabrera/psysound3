function obj = mirdata(orig,varargin)
%   d = mirdata(x) creates a MIR object.
% mirdata Constructor
%for the Psysound-style classes (adapted from MirToolbox)


obj = struct;

 switch nargin
   
 case 1
     
     arg1 = orig;
     if isstruct(arg1) 
  % Copy Constructor
  % This should be a file handle
     base = Analyser(arg1);
     initObj(nargin,0);
     obj = class(obj, 'mirdata', base);
%      
     elseif isempty(orig)
   base = Analyser();
   initObj(nargin,0); 
   obj = class(obj, 'mirdata', base);
   
   
     elseif isa(orig,'mirdata')
         
         % necessary to do such a twisted 'cache', because of purgedata.m 
%          to avoid the "invalid wav file" error
  obj2.Name         = get(arg1,'Name');
  obj2.filename     = get(arg1,'filename');
  obj2.fs           = get(arg1,'fs');
  obj2.bits         = get(arg1,'bits');
  obj2.samples      = get(arg1,'samples');
  obj2.channels     = get(arg1,'channels');
  obj2.windowLength = get(arg1,'windowLength');
  obj2.windowFunc   = get(arg1,'windowFunc');
  obj2.overlap      = get(arg1,'overlap');
  obj2.output       = get(arg1,'output'); 
  obj2.type = get(arg1,'type'); 
  obj2.windowOffset = get(arg1,'windowOffset');    
  obj2.outputDataRate = get(arg1,'outputDataRate');        
  obj2.outputSamples = get(arg1,'outputSamples');        
  obj2.synch = get(arg1,'synch'); 
  obj2.multiChannelSupport = get(arg1,'multiChannelSupport');
  obj2.SummaryOutput = get(arg1,'SummaryOutput');
  obj2.OptionStr = get(arg1,'OptionStr');
  
  initObj(nargin,orig); 
  base=Analyser();
  obj = class(obj, 'mirdata', base);
   
  obj=set(obj,'Name',obj2.Name);
  obj=set(obj,'filename',obj2.filename);
  obj=set(obj,'fs',obj2.fs);
  obj=set(obj,'bits',obj2.bits);
  obj=set(obj,'samples',obj2.samples);
  obj=set(obj,'channels',obj2.channels);
  obj=set(obj,'windowLength',obj2.windowLength);
  obj=set(obj,'windowFunc',obj2.windowFunc);  
  obj=set(obj,'overlap',obj2.overlap); 
  obj=set(obj,'output',obj2.output);
  obj=set(obj,'type',obj2.type);
  obj=set(obj,'windowOffset',obj2.windowOffset);
  obj=set(obj,'outputDataRate',obj2.outputDataRate);
  obj=set(obj,'outputSamples',obj2.outputSamples);
  obj=set(obj,'synch',obj2.synch);
  obj=set(obj,'multiChannelSupport',obj2.multiChannelSupport); 
  obj=set(obj,'SummaryOutput',obj2.SummaryOutput); 
  obj=set(obj,'OptionStr',obj2.OptionStr);
     else
         display('check if error?')
          base = Analyser();
   initObj(nargin,orig); 
   obj = class(obj, 'mirdata', base);
     end
    
     case 0
         % Default Constructor
         % Inherit from the Analyser base class
         
   base = Analyser();
   initObj(nargin,0); 
   obj = class(obj, 'mirdata', base);
otherwise
errror('mirdata takes 2 arguments')

  end

  
% Specify analyser type (mirdata is a base class)
% ????
obj = set(obj, 'type', 'Raw');

% Set default windowlength
numSamples = get(obj,'samples') + mod(get(obj,'samples'),2);
obj = set(obj, 'windowLength', numSamples);

% set output rate to 100 - if synchronise is used this will be changed
% This considerably decreases storage space necessary.
% obj = set(obj, 'outputDataRate', 100);
% 

% Set name
obj = set(obj, 'Name', 'MirToolbox (mirdata)');
obj = setMir(obj,varargin{:}); 

function initObj(n,varargin)
  

if n > 0 && isa(orig,'mirdata')
orig=varargin{1};
    obj.pos = orig.pos;
    obj.data = orig.data;
    obj.unit = orig.unit;
    obj.framepos = orig.framepos;
    obj.framed = orig.framed;
    obj.sr = orig.sr;
    obj.length = orig.length;
    obj.nbits = orig.nbits;
    obj.name = orig.name;
    obj.name2 = orig.name2;
    obj.label = orig.label;
    obj.channels = orig.channels;
    obj.clusters = orig.clusters;
    obj.multidata = orig.multidata;
    obj.peak = orig.peak;
    obj.attack = orig.attack;
    obj.release = orig.release;
    obj.track = orig.track;
    obj.title = orig.title;
    obj.abs = orig.abs;
    obj.ord = orig.ord;
    obj.interchunk = orig.interchunk;
    obj.tmpidx = orig.tmpidx;
    obj.acrosschunks = orig.acrosschunks;
    obj.interpolable = orig.interpolable;
    obj.tmpfile = orig.tmpfile;
    obj.index = orig.index;
    
else
    obj.pos = {};
    obj.data = {};
    obj.unit = '';
    obj.framepos = {};
    obj.framed = 0;
    obj.sr = {};
    obj.length = {};
    obj.nbits = {};
    obj.name = {};
    obj.name2 = {};
    obj.label = {};
    obj.channels = [];
    obj.clusters = {};
    obj.multidata = [];
    obj.peak.pos = {};
    obj.peak.val = {};
    obj.peak.precisepos = {};
    obj.peak.preciseval = {};
    obj.peak.mode = {};
    obj.attack = {};
    obj.release = {};
    obj.track = {};
    obj.title = 'Unspecified data';
    obj.abs = 'Unspecified abscissa';
    obj.ord = 'Unspecified ordinate';
    obj.interchunk = [];
    obj.tmpidx = 0;
    obj.acrosschunks = [];
    obj.interpolable = 1;  % If the abscissae axis is non-numeric (0), 
                         % then peak picking has to be done without interpolation.
    obj.tmpfile = [];
    obj.index = NaN;
   
end


  end % initObj
end % mirdata