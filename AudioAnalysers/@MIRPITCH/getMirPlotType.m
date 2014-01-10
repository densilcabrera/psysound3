function [ Frame,Name  ] = getMirPlotType( obj )
%getMirPlotType : returns the value (0 or 1) of the 'Frame' tickbox in the GUI and the
%type name of the plot chosen by the user in the GUI

%   It was necessary to call such a function from the runanalysis function
%   BEFORE entering any parfor loop (so especially not to call it in any child function
%   of process.m) ,because it is impossible, within a parfor loop, to use
%   the findobj(...) function. (it always returns an empty handle)


h=findobj('Tag',[class(obj), 'Frame1']);
Frame=get(h,'Value');

h1=findobj('Tag',[class(obj), 'Spectrum']);
val1=get(h1,'Value');
h2=findobj('Tag',[class(obj), 'AutocorSpectrum']);
val2=get(h2,'Value');
h3=findobj('Tag',[class(obj), 'Cepstrum']);
val3=get(h3,'Value');
h4=findobj('Tag',[class(obj), 'Tolonen']);
val4=get(h4,'Value');

    if val1==1
    Name  = 'FFT Spectrum (no "Frame" only)';
    
    elseif val2==1
    Name  = 'Spectrum Autocor (no "Frame" only)';
    
    elseif val3==1
    Name  = 'Cepstrum (no "Frame" only)';
    
    elseif val4==1
    Name  = 'Tolonen Autocor (no "Frame" only)';
    
    else
    Name  = 'MirAutocor (no "Frame" only)';
    
    end

end

