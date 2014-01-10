function [orig during after] = miroptions(method,orig,specif,varg)

DEFAULTFRAMELENGTH = .05;
DEFAULTFRAMEHOP = .5;

% The options are determined during the bottom-up process design (see below). 

% During the following top-down evaluation initiation, the options being
% therefore already computed have simply been passed as fourth and fifth
% arguments of miroptions.
if not(isempty(varg)) && (isstruct(varg{1}) || isempty(varg{1}))
    during = varg{1};
    if isstruct(varg{1})
        if isfield(during,'struct')
            if isa(orig,'mirdesign') 
                orig = set(orig,'Struct',during.struct);
            elseif iscell(orig)
                for i = 1:length(orig)
                    if isa(orig{i},'mirdesign')
                        orig{i} = set(orig{i},'Struct',during.struct);
                    end
                end
            end
            during = rmfield(during,'struct');
        end
    end
    if length(varg) > 1
        after = varg{2};
    else
        after = [];
    end
    return
end


during = struct;
if isfield(specif,'option')
    option = specif.option;
else
    option = struct;
end
frame = [];
after = [];
fields = fieldnames(option);
persoframe = '';
for i = 1:length(fields)
    field = fields{i};
    if isfield(option.(field),'key') && ischar(option.(field).key) ...
            && strcmpi(option.(field).key,'Frame')
        persoframe = field;
        during.(field).auto = 0;
    end
    if isfield(option.(field),'when') && ...
            (strcmpi(option.(field).when,'After') || ...
             strcmpi(option.(field).when,'Both'))
        if isamir(orig,func2str(method)) ...
                && not(strcmp(func2str(method),'miraudio'))
            after.(field) = 0;
        elseif strcmp(field,'detect')
           %if haspeaks(orig)
           %    after.(field) = 0;
           %else
               after.(field) = 'Peaks';
           %end
        elseif isfield(specif,'title')
            if isa(orig,'mirdata')
                title = get(orig,'Title');
                sameclass = (length(title) > length(specif.title) && ...
                    strcmp(title(1:length(specif.title)),specif.title));
            else
                sameclass = strcmp(func2str(get(orig,'Method')),'mironsets');
            end
            if sameclass
                after.(field) = 0;
            else
                after.(field) = option.(field).default;
            end
        elseif isfield(option.(field),'default')
            after.(field) = option.(field).default;
        else
            after.(field) = 0;
        end
    end
    if not(isfield(option.(field),'when')) || strcmpi(option.(field).when,'Both')
        if isfield(option.(field),'default')
            if strcmpi(persoframe,field)
                during.(field).length.val = option.(field).default(1);
                during.(field).length.unit = 's';
                during.(field).hop.val = option.(field).default(2);
                during.(field).hop.unit = '/1';
            else
                during.(field) = option.(field).default;
            end
        end
    end
end
i = 1;
while i <= length(varg)
    arg = varg{i};
    if strcmpi(arg,'Frame')
        frame.auto = isempty(persoframe);
        frame.length.unit = 's';
        frame.hop.unit = '/1';
        if length(varg) > i && isnumeric(varg{i+1})
            i = i+1;
            frame.length.val = varg{i};
            if length(varg) > i && ischar(varg{i+1}) && ...
                    (strcmpi(varg{i+1},'s') || strcmpi(varg{i+1},'sp'))
                i = i+1;
                frame.length.unit = varg{i};
            end
            if length(varg) > i && isnumeric(varg{i+1})
                i = i+1;
                frame.hop.val = varg{i};
                if length(varg) > i && ischar(varg{i+1}) && ...
                        (strcmpi(varg{i+1},'%') || strcmpi(varg{i+1},'/1') || ...
                         strcmpi(varg{i+1},'s') || strcmpi(varg{i+1},'sp')|| ...
                         strcmpi(varg{i+1},'Hz'))
                    i = i+1;
                    frame.hop.unit = varg{i};
                end
                if not(frame.hop.val || strcmpi(frame.hop.unit,'Hz'))
                    mirerror(func2str(method),'The hop factor should be strictly positive.')
                end
            else
                if not(isempty(persoframe))
                    if isfield(option.(persoframe),'keydefault')
                        frame.hop.val = option.(persoframe).keydefault(2);
                    else
                        frame.hop.val = option.(persoframe).default(2);
                    end
                elseif isfield(specif,'defaultframehop')
                    frame.hop.val = specif.defaultframehop;
                else
                    frame.hop.val = DEFAULTFRAMEHOP;
                end
            end
        else
            if not(isempty(persoframe))
                if isfield(option.(persoframe),'keydefault')
                    frame.length.val = option.(persoframe).keydefault(1);
                else
                    frame.length.val = option.(persoframe).default(1);
                end
            elseif isfield(specif,'defaultframelength')
                frame.length.val = specif.defaultframelength;
            else
                frame.length.val = DEFAULTFRAMELENGTH;
            end
            if not(isempty(persoframe))
                if isfield(option.(persoframe),'keydefault')
                    frame.hop.val = option.(persoframe).keydefault(2);
                else
                    frame.hop.val = option.(persoframe).default(2);
                end
            elseif isfield(specif,'defaultframehop')
                frame.hop.val = specif.defaultframehop;
            else
                frame.hop.val = DEFAULTFRAMEHOP;
            end
        end
        frame.eval = 0;
        if not(isfield(option,'frame')) || ...
                not(isfield(option.frame,'when')) || ...
                strcmpi(option.frame.when,'Before') || ...
                strcmpi(option.frame.when,'Both')
            during.frame = frame;
        end
        if isfield(option,'frame') && ...
               isfield(option.frame,'when') && ...
               (strcmpi(option.frame.when,'After') || ...
               strcmpi(option.frame.when,'Both'))
            after.frame = frame;
        end
    else
        match = 0;
        k = 0;
        while not(match) && k<length(fields)
            k = k+1;
            field = fields{k};
            if isfield(option.(field),'key')
                key = option.(field).key;
                if not(iscell(key))
                    key = {key};
                end
                for j = 1:length(key)
                    if strcmpi(arg,key{j})
                        match = 1;
                    end
                end
                if match
                    if isfield(option.(field),'type')
                        type = option.(field).type;
                    else
                        type = [];
                    end
                    if isfield(option.(field),'unit')
                        unit = option.(field).unit;
                        defaultunit = option.(field).defaultunit;
                    else
                        unit = {};
                    end
                    if isfield(option.(field),'from')
                        from = option.(field).from;
                        defaultfrom = option.(field).defaultfrom;
                    else
                        from = {};
                    end
                    if strcmpi(type,'String')
                        if length(varg) > i && ...
                                (ischar(varg{i+1}) || varg{i+1} == 0)
                            if isfield(option.(field),'choice')
                                match2 = 0;
                                arg2 = varg{i+1};
                                for j = option.(field).choice
                                    if (ischar(j{1}) && strcmpi(arg2,j)) || ...
                                       (not(ischar(j{1})) && isequal(arg2,j{1}))
                                            match2 = 1;
                                            i = i+1;
                                            optionvalue = arg2;
                                    end
                                end
                                if not(match2)
                                    if isfield(option.(field),'keydefault')
                                        optionvalue = option.(field).keydefault;
                                    else
                                        error(['SYNTAX ERROR IN ',func2str(method),...
                                            ': Unexpected keyword after key ',arg'.']);
                                    end
                                end
                            else
                                i = i+1;
                                optionvalue = varg{i};
                            end
                        elseif isfield(option.(field),'keydefault')
                            optionvalue = option.(field).keydefault;
                        elseif isfield(option.(field),'default')
                            optionvalue = option.(field).default;
                        else
                            error(['SYNTAX ERROR IN ',func2str(method),...
                                ': A string should follow the key ',arg'.']);
                        end
                    elseif strcmpi(type,'Boolean')
                        if length(varg) > i && (isnumeric(varg{i+1}) || islogical(varg{i+1}))
                            i = i+1;
                            optionvalue = varg{i};
                        elseif length(varg) > i && ischar(varg{i+1}) ...
                                && (strcmpi(varg{i+1},'on') || ...
                                    strcmpi(varg{i+1},'yes'))
                            i = i+1;
                            optionvalue = 1;
                        elseif length(varg) > i && ischar(varg{i+1}) ...
                                && (strcmpi(varg{i+1},'off') || ...
                                    strcmpi(varg{i+1},'no'))
                            i = i+1;
                            optionvalue = 0;
                        else
                            optionvalue = 1;
                        end
                    elseif strcmpi(type,'Integer') || strcmpi(type,'Integers')
                        if length(varg) > i && isnumeric(varg{i+1})
                            i = i+1;
                            optionvalue = varg{i};
                        elseif isfield(option.(field),'keydefault')
                            if strcmpi(type,'Integers')
                                optionvalue = option.(field).keydefault;
                            else
                                optionvalue = option.(field).keydefault(1);
                            end
                        elseif isfield(option.(field),'default')
                            if strcmpi(type,'Integers')
                                optionvalue = option.(field).default;
                            else
                                optionvalue = option.(field).default(1);
                            end
                        else
                            error(['SYNTAX ERROR IN ',func2str(method),...
                                ': An integer should follow the key ',arg'.']);
                        end
                        if isfield(option.(field),'number')...
                                && option.(field).number == 2
                            if length(varg) > i && isnumeric(varg{i+1})
                                i = i+1;
                                optionvalue = [optionvalue varg{i}];
                            elseif isfield(option.(field),'keydefault')
                                optionvalue = [optionvalue option.(field).keydefault(2)];
                            elseif isfield(option.(field),'default')
                                optionvalue = [optionvalue option.(field).default(2)];
                            else
                                error(['SYNTAX ERROR IN ',func2str(method),...
                                ': Two integers should follow the key ',arg'.']);
                            end
                        end
                        if not(isempty(unit))
                            if (strcmpi(unit{1},'s') || ...
                                strcmpi(unit{2},'s')) && ...
                               (strcmpi(unit{1},'Hz') || ...
                                strcmpi(unit{2},'Hz'))
                                if length(varg) > i && ...
                                   ischar(varg{i+1}) && ...
                                   (strcmpi(varg{i+1},'s') || ...
                                    strcmpi(varg{i+1},'Hz'))
                                    i = i+1;
                                    if not(strcmpi(varg{i},defaultunit))
                                        if isfield(option.(field),'opposite')
                                            field = option.(field).opposite;
                                        end
                                        optionvalue = 1/optionvalue;
                                    end
                                end
                            end
                            if (strcmpi(unit{1},'s') || ...
                                strcmpi(unit{2},'s')) && ...
                               (strcmpi(unit{1},'sp') || ...
                                strcmpi(unit{2},'sp'))
                                if length(varg) > i && ...
                                   ischar(varg{i+1}) && ...
                                   (strcmpi(varg{i+1},'sp') || ...
                                    strcmpi(varg{i+1},'s'))
                                    i = i+1;
                                    if strcmpi(varg{i},'sp')
                                        optionvalue = [optionvalue 0];
                                    else
                                        optionvalue = [optionvalue 1];
                                    end
                                else
                                    optionvalue = [optionvalue 1];
                                end
                            end
                        end
                        if not(isempty(from))
                            if length(varg) > i && ...
                               ischar(varg{i+1}) && ...
                               (strcmpi(varg{i+1},'Start') || ...
                                strcmpi(varg{i+1},'Middle') || ...
                                strcmpi(varg{i+1},'End'))
                                i = i+1;
                                if strcmpi(varg{i},'Start')
                                    optionvalue = [optionvalue 0];
                                elseif strcmpi(varg{i},'Middle')
                                    optionvalue = [optionvalue 1];
                                elseif strcmpi(varg{i},'End')
                                    optionvalue = [optionvalue 2];           
                                end
                            else
                                optionvalue = [optionvalue 0];
                            end
                            if isa(orig,'mirdesign')
                                orig = set(orig,'Size',optionvalue);
                            end
                        end
                    else
                        if length(varg) > i
                            i = i+1;
                            optionvalue = varg{i};
                        elseif isfield(option.(field),'keydefault')
                            optionvalue = option.(field).keydefault(1);
                        else
                            error(['SYNTAX ERROR IN ',func2str(method),...
                                ': Data should follow the key ',arg'.']);
                        end
                    end
                end
            else
                if isfield(option.(field),'choice')
                    for j = option.(field).choice
                        if strcmpi(arg,j)
                            match = 1;
                            optionvalue = arg;
                        end
                    end
                end
            end
            if not(match)
                if isfield(option.(field),'position')
                    if i+1 == option.(field).position
                        match = 1;
                        optionvalue = arg;
                    end
                %else
                %    error(['SYNTAX ERROR IN ',func2str(method),...
                %            ': Badly specified key ',arg'.']);
                end
            end
            if match == 1
                match = 2;
                if isfield(option.(field),'when') ...
                        && (strcmpi(option.(field).when,'After') || ...
                            strcmpi(option.(field).when,'Both'))
                    after.(field) = optionvalue;
                end
                if not(isfield(option.(field),'when')) ...
                        || strcmpi(option.(field).when,'Both')
                    during.(field) = optionvalue;
                end
            end
        end
        if not(match)
            if isnumeric(arg) || islogical(arg)
                arg = num2str(arg);
            end
            error(['SYNTAX ERROR IN ',func2str(method),...
                ': Unknown parameter ',arg'.']);
        end
    end    
    i = i+1;
end