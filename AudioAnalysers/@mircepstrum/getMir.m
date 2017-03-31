function val = get(a, propName)
% GET Get properties from the MIRcepstrum object
% and return the value

switch propName
    case 'Magnitude'
        val = get(psydata(a),'Data');
    case 'Phase'
        val = a.phase;
    case 'Quefrency'
        val = get(psydata(a),'Pos');
    case 'FreqDomain'
        val = a.freq;
    otherwise
        val = get(psydata(a),propName);
end