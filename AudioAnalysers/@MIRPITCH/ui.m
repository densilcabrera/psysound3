function ui(obj, parent)
% Sets up the ui for the FFT Analyser. 
% usage: ui(FFT, parent)
% 
% We rely on picking up the Tag of the uicontrol objects later, so we only
% set them up, we don't return handles to each of them. We can get the handles 
% again in the settings method with handle = findobj('Tag','YourTagHere');
% 
% Make sure the tags you use are unique. The easiest way to do this is to
% use the name of the analyser in the tag at the start, as is done below. 

objName = get(obj, 'Name');
handles = guidata(parent);
cw = handles.CharWide;
ch = handles.CharHi;

% Min

uicontrol('Style', 'edit', ...
          'String', '75',...
          'FontSize', 9, ...
          'Parent', parent, ...
          'Tag', [class(obj), 'Min'], ...
          'Units', 'Characters',...
          'Position', [6*cw 22.5*ch 9*cw 1.5*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);

uicontrol('Style', 'text', ...
          'String', 'Min',...
          'Parent', parent, ...
          'Units', 'Characters',...
          'Position', [1*cw 22*ch 3*cw 2*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);

%       Max
      
uicontrol('Style', 'edit', ...
          'String', '2400',...
          'FontSize', 9, ...
          'Parent', parent, ...
          'Tag', [class(obj), 'Max'], ...
          'Units', 'Characters',...
          'Position', [6*cw 20.5*ch 9*cw 1.5*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);

      
uicontrol('Style', 'text', ...
          'String', 'Max',...
          'Parent', parent, ...
          'Units', 'Characters',...
          'Position', [1*cw 20*ch 4*cw 2*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);
      
% Compress
      
uicontrol('Style', 'checkbox', ...
          'String', 'Compress',...        
          'Parent', parent, ...
          'Tag', [class(obj), 'Compress1'], ...
          'Units', 'Characters', ...
          'Position', [19*cw 22.5*ch 20*cw 1.5*ch], ...
          'UserData', 'Z', ...
          'BackgroundColor', [0.9 0.9 0.9]);
      
    
uicontrol('Style', 'edit', ...
          'String', '0.5',...
          'FontSize', 9, ...
          'Parent', parent, ...
          'Tag', [class(obj), 'Compress2'], ...
          'Units', 'Characters',...
          'Position', [33*cw 22.5*ch 8*cw 1.5*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);
     
%       Contrast

uicontrol('Style', 'checkbox', ...
          'String', 'Contrast',...        
          'Parent', parent, ...
          'Tag', [class(obj), 'Contrast1'], ...
          'Units', 'Characters', ...
          'Position', [19*cw 20.5*ch 20*cw 1.5*ch], ...
          'UserData', 'Cont', ...
          'BackgroundColor', [0.9 0.9 0.9]);
      
    
uicontrol('Style', 'edit', ...
          'String', '0.1',...
          'FontSize', 9, ...
          'Parent', parent, ...
          'Tag', [class(obj), 'Contrast2'], ...
          'Units', 'Characters',...
          'Position', [33*cw 20.5*ch 8*cw 1.5*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);
      
%       Total
      
uicontrol('Style', 'edit', ...
          'String', 'inf',...
          'FontSize', 9, ...
          'Parent', parent, ...
          'Tag', [class(obj), 'Total'], ...
          'Units', 'Characters',...
          'Position', [6*cw 18.5*ch 9*cw 1.7*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);

uicontrol('Style', 'text', ...
          'String', 'Total',...
          'Parent', parent, ...
          'Units', 'Characters',...
          'Position', [0.8*cw 17.8*ch 5*cw 2*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);


% Frame      
      
uicontrol('Style', 'checkbox', ...
          'String', 'Frame:',...        
          'Parent', parent, ...
          'Tag', [class(obj), 'Frame1'], ...
          'Units', 'Characters', ...
          'Position', [1*cw 16.5*ch 11*cw 1.5*ch], ...
          'UserData', 'Cont', ...
          'BackgroundColor', [0.9 0.9 0.9]);
      
    
uicontrol('Style', 'text', ...
          'String', 'length (ms)',...
          'Parent', parent, ...
          'Units', 'Characters',...
          'Position', [11*cw 16*ch 10*cw 2*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);
      
uicontrol('Style', 'edit', ...
          'String', '46.4',...
          'FontSize', 9, ...
          'Parent', parent, ...
          'Tag', [class(obj), 'Frame2'], ...
          'Units', 'Characters',...
          'Position', [21*cw 16.5*ch 6*cw 1.5*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);
      
      
uicontrol('Style', 'text', ...
          'String', 'Hop length (ms)',...
          'Parent', parent, ...
          'Units', 'Characters',...
          'Position', [30*cw 15*ch 12*cw 3*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);
     
   
uicontrol('Style', 'edit', ...
          'String', '10',...
          'FontSize', 9, ...
          'Parent', parent, ...
          'Tag', [class(obj), 'Frame3'], ...
          'Units', 'Characters',...
          'Position', [41*cw 16.5*ch 6*cw 1.5*ch], ...
          'BackgroundColor',[0.9 0.9 0.9],...
          'Callback', @getSync );
      
      
    
      
%       PostProcessing options

uicontrol('Style', 'text', ...
          'String', 'PostProcessing options',...
          'FontSize', 9, ...
          'Parent', parent, ...
          'Units', 'Characters',...
          'Position', [5*cw 14.5*ch 25*cw 1.5*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);
      
uicontrol('Style', 'checkbox', ...
          'String', 'Median:',...        
          'Parent', parent, ...
          'Tag', [class(obj), 'Median1'], ...
          'Units', 'Characters', ...
          'Position', [1*cw 13*ch 11*cw 1.5*ch], ...
          'UserData', 'Cont', ...
          'BackgroundColor', [0.9 0.9 0.9]);
      
    
uicontrol('Style', 'text', ...
          'String', 'length (s)',...
          'Parent', parent, ...
          'Units', 'Characters',...
          'Position', [11*cw 12.3*ch 10*cw 2*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);      
      
uicontrol('Style', 'edit', ...
          'String', '1',...
          'FontSize', 9, ...
          'Parent', parent, ...
          'Tag', [class(obj), 'Median2'], ...
          'Units', 'Characters',...
          'Position', [21*cw 13*ch 6*cw 1.5*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);      
      
      
uicontrol('Style', 'checkbox', ...
          'String', 'Stable:',...        
          'Parent', parent, ...
          'Tag', [class(obj), 'Stable1'], ...
          'Units', 'Characters', ...
          'Position', [1*cw 11*ch 11*cw 1.5*ch], ...
          'UserData', 'Cont', ...
          'BackgroundColor', [0.9 0.9 0.9]);
      
    
uicontrol('Style', 'text', ...
          'String', 'Thresh. ',...
          'Parent', parent, ...
          'Units', 'Characters',...
          'Position', [11*cw 10.5*ch 10*cw 2*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);
      
uicontrol('Style', 'edit', ...
          'String', '0.1',...
          'FontSize', 9, ...
          'Parent', parent, ...
          'Tag', [class(obj), 'Stable2'], ...
          'Units', 'Characters',...
          'Position', [21*cw 11*ch 6*cw 1.5*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);
      
      
uicontrol('Style', 'text', ...
          'String', 'Prec. frames',...
          'Parent', parent, ...
          'Units', 'Characters',...
          'Position', [29*cw 11*ch 12*cw 2*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);
      
uicontrol('Style', 'edit', ...
          'String', '3',...
          'FontSize', 9, ...
          'Parent', parent, ...
          'Tag', [class(obj), 'Stable3'], ...
          'Units', 'Characters',...
          'Position', [41*cw 11 6*cw 1.5], ...
          'BackgroundColor',[0.9 0.9 0.9]);      
      
uicontrol('Style', 'checkbox', ...
          'String', 'Reso:',...        
          'Parent', parent, ...
          'Tag', [class(obj), 'Reso1'], ...
          'Units', 'Characters', ...
          'Position', [1*cw 9*ch 10*cw 1.5*ch], ...
          'UserData', 'Cont', ...
          'BackgroundColor', [0.9 0.9 0.9]);
      
     
uicontrol('Style', 'edit', ...
          'String', 'SemiTone',...
          'FontSize', 9, ...
          'Parent', parent, ...
          'Tag', [class(obj), 'Reso2'], ...
          'Units', 'Characters',...
          'Position', [11*cw 9*ch 13*cw 1.7*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);
      
      
%       Other options

uicontrol('Style', 'text', ...
          'String', 'Other options and preset models',...
          'FontSize', 9, ...
          'Parent', parent, ...
          'Units', 'Characters',...
          'Position', [5*cw 7.3*ch 25*cw 1.5*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);


uicontrol('Style', 'checkbox', ...
          'String', 'Spectrum',...        
          'Parent', parent, ...
          'Tag', [class(obj), 'Spectrum'], ...
          'Units', 'Characters', ...
          'Position', [1*cw 3*ch 15*cw 1.5*ch], ...
          'UserData', 's', ...
          'BackgroundColor',[0.9 0.9 0.9]);


uicontrol('Style', 'checkbox', ...
          'String', 'AutocorSpectrum',...        
          'Parent', parent, ...
          'Tag', [class(obj), 'AutocorSpectrum'], ...
          'Units', 'Characters', ...
          'Position', [1*cw 4.5*ch 20*cw 1.5*ch], ...
          'UserData', 'i', ...
          'BackgroundColor',[0.9 0.9 0.9]);

uicontrol('Style', 'checkbox', ...
          'String', 'Cepstrum',...
          'Parent', parent, ...
          'Tag', [class(obj), 'Cepstrum'], ...
          'Units', 'Characters', ...
          'Position', [1*cw 6*ch 15*cw 1.5*ch], ...
          'UserData', 'p', ...          
          'BackgroundColor',[0.9 0.9 0.9]);  
    

uicontrol('Style', 'checkbox', ...
          'String', 'Tolonen',...        
          'Parent', parent, ...
          'Tag', [class(obj), 'Tolonen'], ...
          'Units', 'Characters', ...
          'Position', [20*cw 6*ch 15*cw 1.5*ch], ...
          'UserData', 'r0.125', ...
          'BackgroundColor',[0.9 0.9 0.9]);
      
      
uicontrol('Style', 'text', ...
          'String', 'FilterBank options',...
          'FontSize', 9, ...
          'Parent', parent, ...
          'Units', 'Characters',...
          'Position', [20*cw 4*ch 15*cw 1.5*ch], ...
          'BackgroundColor',[0.9 0.9 0.9]);

uicontrol('Style', 'checkbox', ...
          'String', 'NoFilterbank',...        
          'Parent', parent, ...
          'Tag', [class(obj), 'NoFilterbank'], ...
          'Units', 'Characters', ...
          'Position', [20*cw 3*ch 15*cw 1.5*ch], ...
          'UserData', 'r1', ...
          'BackgroundColor',[0.9 0.9 0.9]);

uicontrol('Style', 'checkbox', ...
          'String', 'Gammatone',...        
          'Parent', parent, ...
          'Tag', [class(obj), 'Gammatone'], ...
          'Units', 'Characters', ...
          'Position', [20*cw 1.5*ch 15*cw 1.5*ch], ...
          'UserData', 'r1', ...
          'BackgroundColor',[0.9 0.9 0.9]);
   
uicontrol('Style', 'checkbox', ...
          'String', '2 Channels',...        
          'Parent', parent, ...
          'Tag', [class(obj), '2Channels'], ...
          'Units', 'Characters', ...
          'Position', [20*cw 0.2*ch 15*cw 1.5*ch], ...
          'UserData', 'r1', ...
          'BackgroundColor',[0.9 0.9 0.9]);
end
      
      
      
function getSync(hobj, eventdata, arg1)
enabled=findobj('Tag','SynchronisationTickbox');
enabled=get(enabled,'Value');
t=[];
    if enabled==1
h=findobj('Tag','SynchronisationPopup');
s=get(h,'Value');
h=findobj('-regexp','Tag','Frame2');
l=str2double(get(h,'String'));
        switch s
    case 1
        t=1;
    case 2
        t=2;
    case 3
        t=5;
    case 4
        t=10;
    case 5
        t=20;
    case 6 
        t=25;
    case 7
        t=50;
    case 8
        t=100;
    case 9
        t=200;
    case 10
        t=250;
    case 11
        t=500;
    case 12
        t=1000;
        end
        
    if  t>l
        error('Frame Length < Overlap')
    end
    
    k=findobj('-regexp','Tag','Frame3');
    set(k,'String',num2str(t));
        
    end
end

      
      
      

