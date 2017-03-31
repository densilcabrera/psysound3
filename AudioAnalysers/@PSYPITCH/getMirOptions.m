function OptionStr=getMirOptions(obj)
%getMirOptions : Returns a string containing the list of options chosen by
%the user in the GUI, in order to use it as an argument of the mirpitch
%function.
%


h=findobj('Tag',[class(obj), 'Min']);
val=str2double(get(h,'String'));
OptionStr={'Min',val};

h=findobj('Tag',[class(obj), 'Max']);
val=str2double(get(h,'String'));
OptionStr=[OptionStr,{'Max'},{val}];

h=findobj('Tag',[class(obj), 'Compress1']);
valnum=get(h,'Value');
if valnum==1
    h=findobj('Tag',[class(obj), 'Compress2']);
    val=str2double(get(h,'String'));
    OptionStr=[OptionStr,{'Compress'},{val}];
end

h=findobj('Tag',[class(obj), 'Contrast1']);
valnum=get(h,'Value');
if valnum==1
    h=findobj('Tag',[class(obj), 'Contrast2']);
    val=str2double(get(h,'String'));
    OptionStr=[OptionStr,{'Contrast'},{val},];
end


h=findobj('Tag',[class(obj), 'Total']);
val=str2double(get(h,'String'));
OptionStr=[OptionStr,{'Total'},{val}];

h=findobj('Tag',[class(obj), 'Frame1']);
valnum=get(h,'Value');
if valnum==1
    h=findobj('Tag',[class(obj), 'Frame2']);
    val1=str2double(get(h,'String'));
    hh=findobj('Tag',[class(obj), 'Frame3']);
    val2=str2double(get(hh,'String'));
    OptionStr=[OptionStr,{'Frame'},{val1*10^-3},{val2/val1}];
   
end

% PostProcessing options

h=findobj('Tag',[class(obj), 'Median1']);
valnum=get(h,'Value');
if valnum==1
    h=findobj('Tag',[class(obj), 'Median2']);
    val=str2double(get(h,'String'));
    OptionStr=[OptionStr,{'Median'},{val}];
end

h=findobj('Tag',[class(obj), 'Stable1']);
valnum=get(h,'Value');
if valnum==1
    h=findobj('Tag',[class(obj), 'Stable2']);
    val1=str2double(get(h,'String'));
    hh=findobj('Tag',[class(obj), 'Stable3']);
    val2=str2double(get(hh,'String'));
    OptionStr=[OptionStr,{'Stable'},{val1},{val2}];
end 

h=findobj('Tag',[class(obj), 'Reso1']);
valnum=get(h,'Value');
if valnum==1
    h=findobj('Tag',[class(obj), 'Reso2']);
    val=get(h,'String');
    OptionStr=[OptionStr,{'Reso'},{val}];
end

% Other options and preset models

h=findobj('Tag',[class(obj), 'Spectrum']);
valnum=get(h,'Value');
if valnum==1
    OptionStr=[OptionStr,{'Spectrum'}];
end

h=findobj('Tag',[class(obj), 'AutocorSpectrum']);
valnum=get(h,'Value');
if valnum==1
    OptionStr=[OptionStr,{'AutocorSpectrum'}];
end

h=findobj('Tag',[class(obj), 'Cepstrum']);
valnum=get(h,'Value');
if valnum==1
    OptionStr=[OptionStr,{'Cepstrum'}];
end

h=findobj('Tag',[class(obj), 'Tolonen']);
valnum=get(h,'Value');
if valnum==1
    OptionStr=[OptionStr,{'Enhanced'},{2:10},{'Generalized'},{.67},{'2Channels'}];
end

h=findobj('Tag',[class(obj), 'NoFilterbank']);
valnum=get(h,'Value');
if valnum==1
    OptionStr=[OptionStr,{'NoFilterbank'}];
end

h=findobj('Tag',[class(obj), 'Gammatone']);
valnum=get(h,'Value');
if valnum==1
    OptionStr=[OptionStr,{'Gammatone'}];
end

h=findobj('Tag',[class(obj), '2Channels']);
valnum=get(h,'Value');
if valnum==1
    OptionStr=[OptionStr,{'2Channels'}];
end


end