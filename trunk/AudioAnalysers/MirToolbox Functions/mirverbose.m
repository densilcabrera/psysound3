function v = mirverbose(s)
% mirverbose(0) toggles off the display by MIRtoolbox of minor informations
% in the Matlab Command Window (such as "Computing mirfunction ...").
% mirverbose(1) toggles back on the display of such information.

persistent mir_verbose

if nargin
    mir_verbose = s;
else
    if isempty(mir_verbose)
        mir_verbose = 1;
    end
end

v = mir_verbose;