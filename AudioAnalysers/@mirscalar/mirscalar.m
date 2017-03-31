function s = mirscalar(orig,varargin)
%   s = mirscalar(x,n) creates a scalar object

if nargin == 0
    orig = [];
end
if iscell(orig)
    orig = orig{1};
end
if isa(orig,'mirscalar')
    s.mode = orig.mode;
    s.legend = orig.legend;
    s.parameter = orig.parameter;
else
    s.mode = [];
    s.legend = '';
    s.parameter = struct;
end

base=mirdata(orig);
s = class(s,'mirscalar',base);



s = purgedata(s);
s = setMir(s,'Pos',{},'Abs','Temporal position of frames','Ord','Value',varargin{:});

% Adapted for psysound3
s = set(s, 'Name', 'MirToolbox (mirscalar)');