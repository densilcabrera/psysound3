function display(obj)
% DISPLAY method

s = struct(obj);
f = fieldnames(s);

for i=1:length(f)
  val = s.(f{i});

  if isobject(val)
    display(val);
    s = rmfield(s, f{i});
  end
end

disp([class(obj), ':']);
disp(s);

% end
