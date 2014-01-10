function h = haspeaks(d)

if isa(d,'mirdesign')
    h = strcmp(func2str(get(d,'Method')),'mirpeaks');
else
    if iscell(d)
        d = d{1};
    end
    p = get(d,'PeakVal');
    h = not(isempty(p) || isempty(p{1}) || isempty(p{1}{1}));
end