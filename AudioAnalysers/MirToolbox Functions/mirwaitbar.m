function pb = mirwaitbar(s)
% mirwaitbar(0) toggles off the display by MIRtoolbox of waitbar windows.
% mirverbose(1) toggles back on the display of these waitbar windows.

persistent mir_wait_bar

if nargin
    mir_wait_bar = s;
else
    if isempty(mir_wait_bar)
        mir_wait_bar = 1;
    end
end

pb = mir_wait_bar;