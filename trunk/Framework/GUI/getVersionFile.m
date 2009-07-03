function handles = getVersionFile(mfile,handles,varargin)
global NewGUI;
version = ver;

for i = 1:length(version)
   if strcmp(version(i).Name,'MATLAB')
        break
   end
end
verDate = version(i).Date;
if ~isempty(NewGUI)
    verRelease = 'NewGUI';
elseif datenum(verDate) > datenum('01-Jan-2008')
    verRelease = '2008';
elseif datenum(verDate) > datenum('01-Jan-2007')
    verRelease = '2007';
elseif datenum(verDate) > datenum('01-Jan-2006')
    verRelease = '2006';
end
newmfile = [mfile '_' verRelease];


if nargin<3
    handles = eval([newmfile '(handles)']);
elseif isempty(varargin{1})
    handles = eval([newmfile '(handles)']);
else
   handles = eval([newmfile '(handles, varargin{:})']);
end