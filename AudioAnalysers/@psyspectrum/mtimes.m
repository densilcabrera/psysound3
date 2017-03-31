function c = mtimes(a,b)

if isa(b,'mirautocor')
    if not(get(b,'OfSpectrum'))
        b = mirautocor(b,'Freq');
    end
elseif isa(b,'mircepstrum')
    b = mircepstrum(b,'Freq');
end
c = mirtimes(a,b);