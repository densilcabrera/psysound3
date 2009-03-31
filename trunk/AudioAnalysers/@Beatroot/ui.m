function  ui(LoudnessCF,parent)
% Sets up the ui for the LoudnessCF Analyser. 
% usage: ui(LoudnessCF,parent)
% 
% We rely on picking up the Tag of the uicontrol objects later, so we only
% set them up, we don't return handles to each of them. We can get the handles 
% again in the settings method with handle = findobj('Tag','YourTagHere');
% 
% Make sure the tags you use are unique. The easiest way to do this is to
% use the name of the analyser in the tag at the start, as is done below. 

% Some explanatory text, unfortunately long strings have to be entered on
% one big line. 
% textString = textwrap({'Chalupper and Fastl Dynamic Loudness'},45);
% % Use a fontsize of 9 for consistency.
% uicontrol('Style','text','FontSize',9,'String',textString,...
%           'Parent',parent,'Units','Characters','Position',[1 24 46 10],...
%           'HorizontalAlignment','left','BackgroundColor',[0.9 0.9 0.9]);

% Overlap Info.      
textString = textwrap({'The algorithm takes approximately 50 ms size frames and uses a 2ms timestep to give 500 loudness outputs per second. This algorithm should be used with samples that are at 32kHz sample rate. There may be inaccuracies otherwise.'},40);
uicontrol('Style','text','FontSize',9,'String',textString,...
		  'Parent',parent,'Units','Characters','Position',[1 22 46 5],...
          'HorizontalAlignment','left','BackgroundColor',[0.9 0.9 0.9]);
%uicontrol('Style','popup','String','0|25|50|75|90|99',...
%          'Parent',parent,'Tag','LoudnessCFWindowLength','Units','Characters',...
 %         'Position',[1 15 20 2],'BackgroundColor',[0.9 0.9 0.9]);
% A Checkbox
%uicontrol('Style','checkbox','String','This is UIControl_2',...        
%          'Parent',parent,'Tag','LoudnessCFUIControl_2','Units','Characters',...
%          'Position',[1 8 20 1.5],'Value',1,'BackgroundColor',[0.9 0.9 0.9]);
% A Textfield
%uicontrol('Style','edit','String','This is UIControl_3',...
%          'Parent',parent,'Tag','LoudnessCFUIControl_3','Units','Characters',...
%          'Position',[1 6 20 1.5],'BackgroundColor',[0.9 0.9 0.9]);
      
      
% Position is [distanceFromLeft distanceFromBottom width height] 
% Units = Characters gives a certain amount of stability, although it may
% cause some problems on some platforms.