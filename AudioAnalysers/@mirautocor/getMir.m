function val = getMir(a, propName)
% GET Get properties from the MIRautocor object
% and return the value

switch propName
    case 'Coeff'
        val = get(mirdata(a),'Data');
    case 'Delay'
        val = get(mirdata(a),'Pos');
    case 'Lag'
        val = get(mirdata(a),'Pos');
    case 'FreqDomain'
        val = a.freq;
    case 'OfSpectrum'
        val = a.ofspectrum;
    case 'Window'
        val = a.window;
    otherwise
        val = get(mirdata(a),propName);
end