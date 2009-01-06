function  ui(obj, parent)
% Generic UI method
% usage: ui(obj, parent)
% 
% We rely on picking up the Tag of the uicontrol objects later, so we only
% set them up, we don't return handles to each of them. We can get the handles 
% again in the settings method with handle = findobj('Tag','YourTagHere');
% 
% Make sure the tags you use are unique. The easiest way to do this is to
% use the name of the analyser in the tag at the start, as is done below. 

% Character width and heights
handles = guidata(parent);
cw = handles.CharWide;
ch = handles.CharHi;

% Basic text
  textString = textwrap({['There are no user settings for the ', ...
                      obj.Name, ' analyser.']}, 40);
  
  uicontrol('Style',               'text', ...
            'FontSize',            9, ...
            'String',              textString,...
            'Parent',              parent, ...
            'Units',               'Characters', ...
            'Position',            [1*cw 16*ch 46*cw 3*ch],...
            'HorizontalAlignment', 'left', ...
            'BackgroundColor',     [0.9 0.9 0.9]);
  

