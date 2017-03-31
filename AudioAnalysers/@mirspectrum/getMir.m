function val = get(a, propName)
% GET Get properties from the MIRspectrum object
% and return the value

switch propName
    case 'Magnitude'
        val = get(mirdata(a),'Data');
    case 'Frequency'
        val = get(mirdata(a),'Pos');
    case 'Phase'
        val = a.phase;
    case 'log'
        val = a.log;
    case 'XScale'
        val = a.xscale;
    case 'Power'
        val = a.pow;
    otherwise
        val = get(mirdata(a),propName);
end