function c = mtimes(a,b)

if isa(b,'psyautocor')
    if not(get(b,'OfSpectrum'))
        b = psyautocor(b,'Freq');
    end
elseif isa(b,'psycepstrum')
    b = psycepstrum(b,'Freq');
end
c = mirtimes(a,b);