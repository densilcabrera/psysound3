function y = power2dB(x)
% POWER2DB  This is called 'power' to emphasize that the input
%           argument should be power values.
%
%           It replaces all zero values with eps

x_eps = eps(class(x));
x     = abs(x);
x(find(x < x_eps)) = x_eps;

y = 10*log10(x);

% EOF
