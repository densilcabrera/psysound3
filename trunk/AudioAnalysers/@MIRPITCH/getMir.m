function val = getMir(p, propName)
% GET Get properties from the MIRpitch object
% and return the value
% Modified for the needs of parallell computing features in Psysound3

switch propName
    case 'Amplitude'
        val = p.amplitude;
    case 'Frame'
        val = p.Frame;
    case 'SpectrumType'
        val = p.SpectrumType;
    otherwise
        val = getMir(mirscalar(p),propName);
end