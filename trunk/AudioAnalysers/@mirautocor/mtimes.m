function c = mtimes(a,b)

if not(get(a,'OfSpectrum'))
    a = mirautocor(a,'Freq');
end
if isa(b,'mirautocor')
    if not(get(b,'OfSpectrum'))
        b = mirautocor(b,'Freq');
    end
elseif isa(b,'mircepstrum')
    b = mircepstrum(b,'Freq');
end
c = mirtimes(a,b);