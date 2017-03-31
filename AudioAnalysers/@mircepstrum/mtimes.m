function c = mtimes(a,b)

a = mircepstrum(a,'Freq');
if isa(b,'mirautocor')
    if not(get(b,'OfSpectrum'))
        b = mirautocor(b,'Freq');
    end
elseif isa(b,'mircepstrum')
    b = mircepstrum(b,'Freq');
end
c = mirtimes(a,b);