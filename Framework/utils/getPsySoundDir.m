function p = getPsySoundDir
% GETPSYSOUNDDIR  Gets the directory of the PsySound installation
%

w = which('psysound3');
p = fileparts(w);

