function c = combine(varargin)

c = varargin{1};
l = length(varargin);
p = cell(1,l);
ch = cell(1,l);
d = cell(1,l);
fp = cell(1,l);
sr = cell(1,l);
n = cell(1,l);
la = cell(1,l);
cl = cell(1,l);
pp = cell(1,l);
pm = cell(1,l);
pv = cell(1,l);
ppp = cell(1,l);
ppv = cell(1,l);
tp = cell(1,l);
tv = cell(1,l);
tpp = cell(1,l);
tpv = cell(1,l);
ap = cell(1,l);
rp = cell(1,l);
if isa(c,'temporal')
    nb = cell(1,l);
end
if isa(c,'mirscalar')
    m = cell(1,l);
end
if isa(c,'miremotion')
    dd = cell(1,l);
    cd = cell(1,l);
end
for i = 1:l
    argin = varargin{i};
    p{i} = getargin(argin,'Pos');
    ch{i} = getargin(argin,'Channels');
    d{i} = getargin(argin,'Data');
    fp{i} = getargin(argin,'FramePos');
    sr{i} = getargin(argin,'Sampling');
    nb{i} = getargin(argin,'NBits');
    n{i} = getargin(argin,'Name');
    la{i} = getargin(argin,'Label');
    cl{i} = getargin(argin,'Clusters');
    pp{i} = getargin(argin,'PeakPos');
    pm{i} = getargin(argin,'PeakMode');
    pv{i} = getargin(argin,'PeakVal');
    ppp{i} = getargin(argin,'PeakPrecisePos');
    ppv{i} = getargin(argin,'PeakPreciseVal');
    tp{i} = getargin(argin,'TrackPos');
    tv{i} = getargin(argin,'TrackVal');
    tpp{i} = getargin(argin,'TrackPrecisePos');
    tpv{i} = getargin(argin,'TrackPreciseVal');
    ap{i} = getargin(argin,'AttackPos');
    rp{i} = getargin(argin,'ReleasePos');
    if isa(c,'temporal')
        ct = getargin(argin,'Centered');
        nb{i} = getargin(argin,'NBits');
    end
    if isa(c,'mirscalar')
        m{i} = getargin(argin,'Mode');
    end
    if isa(c,'miremotion')
        dd{i} = getargin(argin,'DimData');
        cd{i} = getargin(argin,'ClassData');
    end
end
c = setMir(c,'Pos',p,'Data',d,'FramePos',fp,'Channels',ch,...
          'Sampling',sr,'NBits',nb,'Name',n,'Label',la,...
          'Clusters',cl,'PeakPos',pp,'PeakMode',pm,'PeakVal',pv,...
          'PeakPrecisePos',ppp,'PeakPreciseVal',ppv,...
          'TrackPos',tp,'TrackVal',tv,...
          'TrackPrecisePos',tpp,'TrackPreciseVal',tpv,...
          'AttackPos',ap,'ReleasePos',rp);
if isa(c,'temporal')
    c = setMir(c,'Centered',ct,'NBits',nb);
end
if isa(c,'mirscalar')
    c = setMir(c,'Mode',m);
end
if isa(c,'miremotion')
    c = setMir(c,'DimData',dd,'ClassData',cd);
end
      
      
function y = getargin(argin,field)
yi = get(argin,field);
if isempty(yi) || ischar(yi)
    y = yi;
else
    y = yi{1};
end