function val = getMir(a, propName)
% GET Get properties from the MIRautocor object
% and return the value

switch propName
    case 'Coeff'
        val = get(psydata(a),'Data');
    case 'Delay'
        val = get(psydata(a),'Pos');
    case 'Lag'
        val = get(psydata(a),'Pos');
    case 'FreqDomain'
        val = a.freq;
    case 'OfSpectrum'
        val = a.ofspectrum;
    case 'Window'
        val = a.window;
    otherwise
        val = get(psydata(a),propName);
end