function val = get(a, propName)
% GET Get properties from the MIRcepstrum object
% and return the value

switch propName
    case 'Magnitude'
        val = get(mirdata(a),'Data');
    case 'Phase'
        val = a.phase;
    case 'Quefrency'
        val = get(mirdata(a),'Pos');
    case 'FreqDomain'
        val = a.freq;
    otherwise
        val = get(mirdata(a),propName);
end