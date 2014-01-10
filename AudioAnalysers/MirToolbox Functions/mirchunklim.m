function cl = mirchunklim(lim)
% c = mirchunklim returns the maximal chunk size.
%   If the size of a long audio files exceeds that size, it will be
%   decomposed into chunks of that size, before being analyzed in the 
%   different functions on the toolbox.
% mirchunklim(c) specifies a new maximal chunk size.
%   If MIRtoolbox tends to use more memory than what is available in the
%   RAM of your computer, you should decrease the maximal chunk size.
% mirchunklim(Inf) toggles off the automated chunk decomposition.

persistent chunklim

if nargin
    if not(isnumeric(lim))
        error('ERROR IN MIRCHUNKLIM: The argument should be a number.')
    end
    chunklim = lim;
else
    if isempty(chunklim)
        chunklim = 5e5;
    end
end

cl = chunklim;