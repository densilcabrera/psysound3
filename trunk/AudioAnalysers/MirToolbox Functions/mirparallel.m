function p = mirparallel(s)
% mirparallel(1) toggles on parallel processing: (BETA)
%   When ?Folder? or ?Folders? is used, several audio files can be analysed
%   in parallel using several  parallel Matlab sessions running on the 
%   different processors and/or  processor cores of your computer.
%   (Requires MathWorks? Parallel Computing Toolbox.)
% mirparallel(0) toggles back off parallel processing.

persistent mir_parallel

if nargin
    warning('MIRtoolbox Parallel computing is currently in Beta Version.');
    if s
        try
            matlabpool size;
        catch
            mirerror('mirparallel','Are you sure Parallel Processing Toolbox is installed?');
        end
    end
    mir_parallel = s;
else
    if isempty(mir_parallel)
        mir_parallel = 0;
    end
end

p = mir_parallel;