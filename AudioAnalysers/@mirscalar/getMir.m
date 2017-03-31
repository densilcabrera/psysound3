function val = getMir(a, propName)

switch propName
    case 'Mode'
        val = a.mode;
    case 'Legend'
        val = a.legend;
    case 'Parameter'
        val = a.parameter;
    otherwise
        val = getMir(mirdata(a),propName);
end

end