function val = getMir(a, propName)
% GET Get properties from the MIRtemporal object
% and return the value

switch propName
    case 'Time'
        val = get(a,'Pos');
    case 'Centered'
        val = a.centered;
    case 'NBits'
        val = a.nbits;
    otherwise
        val = get(mirdata(a),propName);
end