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
    b = psyaudio(b,'Sampling',sa);
elseif sb>sa
    a = psyaudio(a,'Sampling',sb);
end
c = plus(psytemporal(a),psytemporal(b));
c = psyaudio(c);