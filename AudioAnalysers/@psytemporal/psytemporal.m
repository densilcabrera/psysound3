function t = psytemporal(orig,varargin)
%   t = psytemporal(x) creates a temporal object from signal x.
%   Optional arguments:
%       psytemporal(...,'Center') centers the signal x.

if nargin > 0 && isa(orig,'psytemporal')
    t.centered = orig.centered;
    t.nbits = orig.nbits;
else
    t.centered = 0;
    t.nbits = {};
end

%Adapted for Psysound3
if nargin==0 


base=psydata();
t = class(t,'psytemporal',base);


else

base=psydata(orig);
t = class(t,'psytemporal',base);

end



t=set(t,'Name','MirToolbox (psytemporal)');
%

if nargin == 0 || not(isa(orig,'psytemporal'))
    t = set(t,'Title','Temporal signal','Abs','time (s)','Ord','amplitude');
end
if nargin>1
    for i = 1:nargin-1
        if strcmp(varargin{i},'Center')
            d = get(t,'Data');
            for h = 1:length(d)
                for k = 1:length(d{h})
                    d{h}{k} = center(d{k});
                end
            end
            t = set(t,'Data',d);
        end
    end
    t = setMir(t,varargin{:});
end
t=set(t,'Name','MirToolbox (psytemporal)');