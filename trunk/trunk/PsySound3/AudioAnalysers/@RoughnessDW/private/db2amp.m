function y=db2amp(x)
% This file belongs to the roughness algorithm
% contact for the original source code :
% http://home.tm.tue.nl/dhermes/

% Included into psysound by Matt Flax <flatmax @
% http://www.flatmax.org> : Matt Flax is flatmax
% March 2007 : For the psySoundPro project

y = 10 .^ (0.05*x);
end