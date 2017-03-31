function c = plus(a,b)

sa = get(a,'Sampling');
if iscell(sa)
    sa = sa{1};
end
sb = get(b,'Sampling');
if iscell(sb)
    sb = sb{1};
end
if sa>sb
    b = miraudio(b,'Sampling',sa);
elseif sb>sa
    a = miraudio(a,'Sampling',sb);
end
c = plus(mirtemporal(a),mirtemporal(b));
c = miraudio(c);