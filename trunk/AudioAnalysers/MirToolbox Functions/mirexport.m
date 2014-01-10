function m = mirexport(f,varargin)
%   mirexport(filename,...) exports statistical information related to 
%       diverse data into a text file called filename.
%   mirexport('Workspace',...) instead directly output the statistical 
%       information in a structure array saved in the Matlab workspace.
%       This structure contains three fields:
%           filenames: the name of the original audio files, 
%           types: the name of the features,
%           data: the data.
%   The exported data should be related to the same initial audio file
%       or the same ordered set of audio files.
%   The data listed after the first arguments can be:
%       - any feature computed in MIRtoolbox.
%           What will be exported is the statistical description of the 
%           feature (using the mirstat function)
%       - any structure array of such features.
%           Such as the ouput of the mirstat function.
%       - any cell array of such features.
%       - the name of a text file.
%           The text file is imported with the Matlab importdata command.
%           Each line of the file should contains a fixed number of data
%           delimited by tabulations. The first line, or 'header',
%           indicates the name of each of these columns.
%   The file format of the output can be either:
%       - a text file.
%           It follows the same text file representation as for the input
%           text files. The first column of the matrix indicates the name 
%           of the audio files. The text file can be opened in Matlab,
%           or in a spreadsheet program, such as Microsoft Excel, where the
%           data matrix can be automatically reconstructed.
%       - an attribute-relation file.
%           It follows the ARFF standard, used in particular in the WEKA
%           data mining environment.

stored.data = {};
stored.textdata = {};
stored.name = {};
narg = nargin;
if strcmpi(f,'Workspace')
    format = 'Workspace';
elseif length(f)>4 && strcmpi(f(end-4:end),'.arff')
    format = 'ARFF';
else
    format = 'Matrix';
end
v = ver('MIRtoolbox');
title = ['MIRtoolbox' v.Version];
class = {};
if not(isempty(varargin)) && ischar(varargin{end}) && strcmp(varargin{end},'#add')
    add = 1;
    varargin(end) = [];
    narg = narg-1;
else
    add = 0;
end
for v = 2:narg
    argv = varargin{v-1};
    if isa(argv,'mirdesign')
        mirerror('MIREXPORT','You can only export features that have been already evaluated (using mireval).');
    end
    if ischar(argv)
        if strcmpi(argv,'Matrix')
            format = 'Matrix';
        elseif strcmpi(argv,'ARFF')
            format = 'ARFF';
        else
            imported = importdata(argv,'\t',1);
            imported.name = {};
            [stored class] = integrate(stored,imported);
        end
    elseif isstruct(argv) && isfield(argv,'data')
        new.data = argv.data;
        new.textdata = argv.fields;
        new.name = {};
        [stored class] = integrate(stored,new);
    else
        new.data = argv;
        new.textdata = '';
        new.name = {};
        [stored class] = integrate(stored,new);
    end
end
switch format
    case 'Matrix'
        matrixformat(stored,f,title,add);
        m = 1;
    case 'ARFF'
        classes = {};
        for i = 1:length(class)
            if isempty(strcmp(class{i},classes)) || not(max(strcmp(class{i},classes)))
                classes{end+1} = class{i};
            end
        end
        ARFFformat(stored,f,title,class,classes,add);
        m = 1;
    case 'Workspace'
        m = variableformat(stored,f,title);
end



function [stored class] = integrate(stored,new,class)

if nargin<3
    class = {};
end
    
% Input information
data = new.data;
textdata = new.textdata;
if isfield(new,'name')
    name = new.name;
else
    name = {};
end

% Input information after processing
newdata = {};
newtextdata = {};
newname = {};

if isstruct(data)
    if isfield(data,'Class')
        class = data.Class;
        data = rmfield(data,'Class');
    end
        
    if isfield(data,'FileNames')
        name = data.FileNames;
        data = rmfield(data,'FileNames');
    end
    
    fields = fieldnames(data);
    nfields = length(fields);

    for w = 1:nfields
        % Field information
        field = fields{w};
        newfield.data = data.(field);
        if 1 %not(isnumeric(newfield.data) && all(all(isnan(newfield.data))))
            if isempty(textdata)
                newfield.textdata = field;
            else
                newfield.textdata = strcat(textdata,'_',field);
            end

            % Processing of the field
            [n class] = integrate({},newfield,class);

            % Concatenation of the results
            newdata = {newdata{:} n.data{:}};
            newtextdata = {newtextdata{:} n.textdata{:}};
            newname = checkname(newname,name);
        end
    end
elseif isa(data,'mirdata')
    newinput.data = mirstat(data);
    if isfield(newinput.data,'FileNames')
        newinput.data = rmfield(newinput.data,'FileNames');
    end
    title = get(data,'Title');
    newinput.textdata = [textdata '_' title(find(not(isspace(title))))];
    [n class] = integrate({},newinput,class);
    newdata = n.data;
    newtextdata = n.textdata;
    newname = get(data,'Name');
elseif iscell(textdata)
    % Input comes from importdata
    nvar = size(data,2);
    newdata = cell(1,nvar);
    newtextdata = cell(1,nvar);
    for i = 1:nvar
        newdata{i} = data(:,i);
        newtextdata{i} = textdata{i};
    end
    newname = {};
elseif iscell(data)
    for i = 1:length(data)
        if not(isempty(data{i}))
            % Element information
            newelement.data = data{i};
            newelement.textdata = [textdata num2str(i)];

            % Processing of the element
            [n class] = integrate({},newelement,class);

            % Concatenation of the results
            newdata = {newdata{:} n.data{:}};
            newtextdata = {newtextdata{:} n.textdata{:}};
            newname = checkname(newname,n.name);
        end
    end
elseif size(data,4)>1
    % Input is vector
    for w = 1:size(data,4)
        % Bin information
        bin.data = data(:,:,:,w);
        if isempty(textdata)
            bin.textdata = num2str(w);
        else
            bin.textdata = strcat(textdata,'_',num2str(w));
        end
        
        % Processing of the bin
        [n class] = integrate({},bin,class);
        
        % Concatenation of the results
        newdata = {newdata{:} n.data{:}};
        newtextdata = {newtextdata{:} n.textdata{:}};
    end
elseif size(data,3)>1
    % Input is vector
    for w = 1:size(data,3)
        % Bin information
        bin.data = data(:,:,w,:);
        if isempty(textdata)
            bin.textdata = num2str(w);
        else
            bin.textdata = strcat(textdata,'_',num2str(w));
        end
        
        % Processing of the bin
        [n class] = integrate({},bin,class);
        
        % Concatenation of the results
        newdata = {newdata{:} n.data{:}};
        newtextdata = {newtextdata{:} n.textdata{:}};
    end
elseif size(data,1)>1 && size(data,1)<=50
    % Input is vector
    for w = 1:size(data,1)
        % Bin information
        bin.data = data(w,:,:,:);
        if isempty(textdata)
            bin.textdata = num2str(w);
        else
            bin.textdata = strcat(textdata,'_',num2str(w));
        end
        
        % Processing of the bin
        [n class] = integrate({},bin,class);
        
        % Concatenation of the results
        newdata = {newdata{:} n.data{:}};
        newtextdata = {newtextdata{:} n.textdata{:}};
    end
else 
    if size(data,1)>1
        data = mean(data);
    end
    newdata = {data};
    newtextdata = {textdata};
    newname = {};
end
if isempty(stored)
    stored.data = newdata;
    stored.textdata = newtextdata;
    stored.name = newname;
else
    stored.data = {stored.data{:} newdata{:}};
    stored.textdata = {stored.textdata{:} newtextdata{:}};
    if isempty(stored.name)
        stored.name = newname;
    else
        stored.name = checkname(newname,stored.name);
    end
end


function m = matrixformat(data,filename,title,add)
named = ~isempty(data.name);
if named
    if not(add)
        m(1,:) = {title,data.textdata{:}};
    end
    for i = 1:length(data.name)
        m{i+~add,1} = data.name{i};
    end
elseif not(add)
    m(1,:) = {data.textdata{:}};
end
for i = 1:length(data.data)
    m((1:length(data.data{i}))+~add,i+named) = num2cell(data.data{i});
end
if add
    fid = fopen(filename,'at');
else
    fid = fopen(filename,'wt');
end
for i = 1:size(m,1)
    for j = 1:size(m,2)
        if ischar(m{i,j})
            fprintf(fid,'%s\t', m{i,j}(find(not(m{i,j} == ' '))));
        else
            if iscell(m{i,j}) % Problem with key strength pos to be solved
                fprintf(fid,'%f\t', m{i,j}{1});
            else
                fprintf(fid,'%f\t', m{i,j});
            end
        end
    end
    %if i < size(m,1)
        fprintf(fid,'\n');
    %end
end
fclose(fid);
disp(['Data exported to file ',filename,'.']);


function ARFFformat(data,filename,title,class,classes,add)
if add
    fid = fopen(filename,'at');
else
    fid = fopen(filename,'wt');
    fprintf(fid,['%% Attribution-Relation File automatically generated using ',title,'\n\n']);
    fprintf(fid,'@RELATION %s\n\n',title);
    for i = 1:length(data.textdata)
        fprintf(fid,'@ATTRIBUTE %s NUMERIC\n',data.textdata{i});
    end
    if not(isempty(class))
        fprintf(fid,'@ATTRIBUTE class {');
        for i = 1:length(classes)
            if i>1
                fprintf(fid,',');
            end
            fprintf(fid,'%s',classes{i});
        end
        fprintf(fid,'}\n');
    end
    fprintf(fid,'\n@DATA\n');
    fid2 = fopen([filename(1:end-5) '.filenames.txt'],'wt');    
    for i = 1:length(data.name)
        fprintf(fid2,'%s\n',data.name{i});
    end
    fclose(fid2);
end

try
    data = cell2mat(data.data(:))';
catch
    error('ERROR IN MIREXPORT: Are you sure all the data to be exported relate to the same ordered list of audio files?');
end
for i = 1:size(data,1)
    fprintf(fid,'%d ',data(i,:));
    if not(isempty(class))
        fprintf(fid,'%s',class{i});
    end
    fprintf(fid,'\n');
end
fclose(fid);
disp(['Data exported to file ',filename,'.']);


function m = variableformat(data,filename,title)
m.types = data.textdata;
m.filenames = data.name;
for i = 1:length(data.data)
    m.data{i} = data.data{i};
end


function name = checkname(newname,name)
if not(isempty(newname)) && not(isempty(name))
    if length(newname) == length(name)
        for i = 1:length(name)
            if not(strcmp(name{i},newname{i}))
                error('ERROR IN MIREXPORT: All the input are not associated to the same audio files (or the same ordering of these files.');
            end
        end
    else
        error('ERROR IN MIREXPORT: All the input are not associated to the same audio files.');
    end
elseif isempty(name)
    name = newname;
end