function [d,d2] = mirgetdata(x,varargin)
%   d = mirgetdata(x) return the data contained in the object x in a
%       structure that can be used for further computation outside MIRtoolbox.
%       If x corresponds to one non-segmented audio sequence, the result is 
%           returned as a matrix. The columns of the matrix usually 
%           correspond to the successive frames of the audio signal. The 
%           third dimension of the matrix corresponds to the different
%           channels of a filterbank.
%       If x is a keystrength curve, the fourth dimension distinguishes
%           between major and minor keys. i.e. d(:,:,:,1) is the
%           keystrength for the major keys, and d(:,:,:,2) is the
%           keystrength for the minor keys.
%       If x is a key estimation, two output are returned: the first one
%           gives the keys (from 1 to 12) and the second one indicates the
%           modes (1 for major, 2 for minor).
%
%       If x corresponds to a set of audio sequences, and if each sequence
%           has same number of frames, the corresponding resulting matrices 
%           are concatenated columnwise one after the other. If the number
%           of raws of the elementary matrices varies, the missing values
%           are replaced by NaN in the final matrix. On the contrary, if 
%           the number of columns (i.e., frames) differs, then the result
%           remains a cell array of matrices.
%       Idem if x corresponds to one or several segmented audio
%           sequence(s).
%
%   If x is the result of a peak detection,
%       [px,py] = getdata(x) return the position of the peaks (px) and the
%           value corresponding to these peaks (py), in the units
%           predefined for this data.

if isempty(x)
    d = {};
    d2 = {};
    return
end

if isstruct(x)
    fields = fieldnames(x);
    for f = 1:length(fields)
        d.(fields{f}) = mirgetdata(x.(fields{f}));
    end
    d2 = {};
    return
end

if iscell(x)
    x = x{1};
end
v = get(x,'Data');
if isa(x,'mirscalar')
    m = get(x,'Mode');
end
d2 = {};

if isa(x,'mirclassify')
    d = get(x,'Data');
    return
end

if isa(x,'mirsimatrix')
    pt = [];
else
    pt = get(x,'PeakPrecisePos');
end
pv = get(x,'PeakPreciseVal');
if not(isempty(pt)) && not(isempty(pt{1})) && not(isempty(pt{1}{1}))
    d = uncell(pt);
    d2 = uncell(pv);
    if not(isempty(d))
        return
    end
end

if isa(x,'mirsimatrix')
    pt = [];
else
    pt = get(x,'PeakPosUnit');
end
pv = get(x,'PeakVal');
if not(isempty(pt)) && not(isempty(pt{1})) && not(isempty(pt{1}{1}))
    d = uncell(pt);
    d2 = uncell(pv);
    if not(isempty(d))
        return
    end
end

d = uncell(v,isa(x,'mirscalar'));
if iscell(d) && not(isempty(d)) && nargin == 1
    disp('The result is an array of cell.')
    disp(['If d is the name of the output variable, ',...
        'the successive cells can be accessed by typing d{1}, d{2}, etc.']);
end
if exist('m')==1 && not(isempty(m)) && not(isempty(m{1}))
    d2 = uncell(m);
end