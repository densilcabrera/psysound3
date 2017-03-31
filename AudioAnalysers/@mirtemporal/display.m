function display(d)
% MIRDATA/DISPLAY display of a MIRtemporal

if d.centered
    d = set(d,'Title',[get(d,'Title'),' (centered)']);
end
mirdisplay(psydata(d),inputname(1));