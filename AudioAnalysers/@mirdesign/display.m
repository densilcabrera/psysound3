function display(d)
% MIRDESIGN/DISPLAY display of a MIR design

disp(' ');
va = inputname(1);
if isempty(va)
    va = 'ans';
end
disp([va,' is the following non-evaluated MIRtoolbox command:']);
method = d.method
option = d.option;
if not(isempty(option))
    option
end
postoption = d.postoption;
if not(isempty(postoption))
    postoption
end
argument = d.argin;
if not(ischar(d.argin))
    disp('***Argument:')
    argument
end
disp(' ');