function c = mtimes(a,b)

if not(get(a,'OfSpectrum'))
    a = psyautocor(a,'Freq');
end
if isa(b,'psyautocor')
    if not(get(b,'OfSpectrum'))
        b = psyautocor(b,'Freq');
    end
elseif isa(b,'psycepstrum')
    b = psycepstrum(b,'Freq');
end
c = mirtimes(a,b);