function c = mtimes(a,b)

a = psycepstrum(a,'Freq');
if isa(b,'psyautocor')
    if not(get(b,'OfSpectrum'))
        b = psyautocor(b,'Freq');
    end
elseif isa(b,'psycepstrum')
    b = psycepstrum(b,'Freq');
end
c = mirtimes(a,b);