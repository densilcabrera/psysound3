function y=rms(x)
% rms value of array x

% This file belongs to the roughness algorithm
% contact for the original source code :
% http://home.tm.tue.nl/dhermes/

% Included into psysound by Matt Flax <flatmax @ http://www.flatmax.org> : Matt Flax is flatmax
% March 2007 : For the psySoundPro project

m=length(x);
y=0;

for k=1:1:m
   y=y+(x(k)^2);
end

y = sqrt(y/m);
end