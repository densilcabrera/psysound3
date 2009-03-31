function out = getDataRate(obj, index)
% GETDATARATE  This is an overloaded method used to handle the case
%              of the varying data rate between loudness and fluctuation

if index < 4
  % 2ms
  rate = 1/2e-3;
else
  % This rounding helps keep the resampling integers down which
  % help tremendously with computation but will introduce some inaccuracy
  rate = round(getWindowRate(obj) * 10)/10;
end

% Assign output
out = rate;

% EOF
