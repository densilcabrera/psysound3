function display(d)
% MIRDATA/DISPLAY display of a MIR data

ST = dbstack;
if strcmp(ST(end).file,'arrayviewfunc.m')
    mirdisplay(d,inputname(1),'nofigure');
else
    mirdisplay(d,inputname(1));
end