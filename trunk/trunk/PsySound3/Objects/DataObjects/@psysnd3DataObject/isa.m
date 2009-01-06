function result = isa(obj, str)
% ISA  Overloaded isa for PsySound3 Data objects that adds the
%      leading 'psysnd3' string

isPsySound3Obj = builtin('isa', obj, 'psysnd3DataObject');

if isPsySound3Obj
  % Add the suffix
  str = strcat('psysnd3', str);
end

% Call the builtin function
result = builtin('isa', obj, str);

% [EOF]


