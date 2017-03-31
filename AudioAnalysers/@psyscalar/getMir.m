function val = getMir(a, propName)

switch propName
    case 'Mode'
        val = a.mode;
    case 'Legend'
        val = a.legend;
    case 'Parameter'
        val = a.parameter;
    otherwise
        val = getMir(psydata(a),propName);
end

end