function varargout = mirstat(f,varargin)
% stat = mirstat(f) returns basic statistics of the feature f as a
%   structure array stat such that:
%       stat.Mean is the mean of the feature;
%       stat.Std is the standard deviation;
%       stat.Slope is the linear slope of the curve;
%       stat.PeriodFreq is the frequency (in Hz) of the main periodicity;
%       stat.PeriodAmp is the normalized amplitude of the main periodicity;
%       stat.PeriodEntropy is the entropy of the periodicity curve.
%   The main periodicity and periodicity curve are evaluated through the
%       computation of the autocorrelation sequence related to f.
%
%   f can be itself a structure array composed of features. In this case,
%       stat will be structured the same way.
%
% mirstat does not work for multi-channels objects.

if isa(f,'mirstruct')
    varargout = {set(f,'Stat',1)};
elseif isstruct(f)
    if isdesign(f)
        f.Stat = 1;
        varargout = {f};
    else
        fields = fieldnames(f);
        for i = 1:length(fields)
            field = fields{i};
            ff = f.(field);
            if iscell(ff) && isa(ff{1},'mirdata')
                ff = ff{1};
            end
            if isa(ff,'mirdata')
                if i == 1 
                    la = get(ff,'Label');
                    if not(isempty(la) || isempty(la{1}))
                        stat.Class = la;
                    end
                end
                ff = set(ff,'Label','');
            end
            stat.(field) = mirstat(ff,'FileNames',0);
        end
        if isempty(varargin)
            f0 = f;
            while isstruct(f0)
                fields = fieldnames(f0);
                f0 = f0.(fields{1});
            end
            if iscell(f0)
                f0 = f0{1};
            end
            stat.FileNames = get(f0,'Name');
        end
        varargout = {stat};
    end
elseif iscell(f)
    if 0 %ischar(f{1})
        varargout = {f};
    else
        res = zeros(length(f),1);
        for i = 1:length(f)
            res(i) = mirstat(f{i});
        end
        varargout = {res};
    end
elseif isnumeric(f)
    f(isnan(f)) = [];
    varargout = {mean(f)};
else
            alongfiles.key = 'AlongFiles';
            alongfiles.type = 'Boolean';
            alongfiles.default = 0;
        option.alongfiles = alongfiles;

            filenames.key = 'FileNames';
            filenames.type = 'Boolean';
            filenames.default = 1;
        option.filenames = filenames;
        
    specif.option = option;

    specif.nochunk = 1;
    varargout = mirfunction(@mirstat,f,varargin,nargout,specif,@init,@main);
end


function [x type] = init(x,option)
type = '';


function stat = main(f,option,postoption)
if iscell(f)
    f = f{1};
end
if isa(f,'mirhisto')
    warning('WARNING IN MIRSTAT: histograms are not taken into consideration yet.')
    stat = struct;
    return
end
fp = get(f,'FramePos');
if haspeaks(f)
    ppp = get(f,'PeakPrecisePos');
    if not(isempty(ppp)) && not(isempty(ppp{1}))
        stat = addstat(struct,ppp,fp,'PeakPos');
        stat = addstat(stat,get(f,'PeakPreciseVal'),fp,'PeakMag');
    else
        if isa(f,'mirkeystrength') || (isa(f,'mirchromagram') && get(f,'Wrap'))
            stat = struct; % This needs to be defined using some kind of circular statistics..
        else
            stat = addstat(struct,get(f,'PeakPosUnit'),fp,'PeakPos');
        end
        stat = addstat(stat,get(f,'PeakVal'),fp,'PeakMag');
    end
else
    stat = addstat(struct,get(f,'Data'),fp,'',option.alongfiles,...
                          get(f,'Name'),get(f,'Label'));
end
if option.filenames
    stat.FileNames = get(f,'Name');
end


function stat = addstat(stat,d,fp,field,alongfiles,filename,labels)
l = length(d);
if nargin<5
    alongfiles = 0;
end
if nargin<7
    labels = {};
end
if not(alongfiles) || l == 1
    anyframe = 0;
    for i = 1:l
        if not(iscell(d{i}))
            d{i} = {d{i}};
        end
        for k = 1:length(d{i})
            dd = d{i}{k};
            if iscell(dd)
                if length(dd)>1
                    anyframe = 1;
                end
                dn = cell2array(dd);
                [m{i}{k},s{i}{k},sl{i}{k},pa{i}{k},pf{i}{k},pe{i}{k}] ...
                    = computestat(dn,fp{i}{k});
            elseif size(dd,2) < 2
                nonan = find(not(isnan(dd)));
                dn = dd(nonan);
                if isempty(dn)
                    m{i}{k} = NaN;
                else
                    m{i}{k} = mean(dn,2);
                end
                s{i}{k} = NaN;
                sl{i}{k} = NaN;
                pa{i}{k} = NaN;
                pf{i}{k} = NaN;
                pe{i}{k} = NaN;
            else
                anyframe = 1;
                s1 = size(dd,1);
                s3 = size(dd,3);
                dd = mean(dd,4); %mean(dd,3),4);
                m{i}{k} = NaN(s1,1,s3);
                s{i}{k} = NaN(s1,1,s3);
                sl{i}{k} = NaN(s1,1,s3);
                pa{i}{k} = NaN(s1,1,s3);
                pf{i}{k} = NaN(s1,1,s3);
                pe{i}{k} = NaN(s1,1,s3);
                for h = 1:s3
                    for j = 1:s1
                        [m{i}{k}(j,1,h),s{i}{k}(j,1,h),sl{i}{k}(j,1,h),...
                         pa{i}{k}(j,1,h),pf{i}{k}(j,1,h),pe{i}{k}(j,1,h)] = ...
                            computestat(dd(j,:,h),fp{i}{k});
                    end
                end
            end
        end
    end
    if anyframe
        fields = {'Mean','Std','Slope','PeriodFreq','PeriodAmp','PeriodEntropy'};
        stats = {m,s,sl,pf,pa,pe};   
    else
        fields = {'Mean'};
        stats = {m};   
    end
    for i = 1:length(stats)
        data = stats{i};
        data = uncell(data,NaN);
        stat.(strcat(field,fields{i})) = data;
    end
else
    if iscell(d{1}{1})
        slash = strfind(filename{1},'/');
        nbfolders = 1;
        infolder = 0;
        foldername{1} = filename{1}(1:slash(end)-1);
        for i = 1:length(d)
            slash = strfind(filename{i},'/');
            if not(strcmpi(filename{i}(1:slash(end)-1),foldername))
                nbfolders = nbfolders + 1;
                infolder = 0;
                foldername{nbfolders} = filename{i}(1:slash(end)-1);
            end
            infolder = infolder+1;
            dd{nbfolders}(infolder,:) = cell2array(d{i}{1});
        end
        for i = 1:length(dd)
            figure
            plot(dd{i}')
            stat.Mean{i} = mean(dd{i});
            stat.Std{i} = std(dd{i});
        end
    end
end
if not(isempty(labels) || isempty(labels{1}))
    stat.Class = labels;
end


function dn = cell2array(dd)
dn = zeros(1,length(dd));
for j = 1:length(dd)
    if isempty(dd{j})
        dn(j) = NaN;
    else
        dn(j) = dd{j}(1);
    end
end


function [m,s,sl,pa,pf,pe] = computestat(d,fp)
m = NaN;
s = NaN;
sl = NaN;
pa = NaN;
pf = NaN;
pe = NaN;
diffp = fp(1,2:end) - fp(1,1:end-1);
if isempty(diffp) || sum(round((diffp(2:end)-diffp(1:end-1))*1000))
    % Not regular sampling (in mirattacktime for instance)
    framesampling = NaN;
else
    framesampling = fp(1,2)-fp(1,1);
end
nonan = find(not(isnan(d)));
if not(isempty(nonan))
    dn = d(nonan);
    m = mean(dn,2);
    s = std(dn,0,2);
    if not(isnan(s))
        if s
            dk = (dn-m)/s;
            tk = linspace(0,1,size(d,2));
            sl = dk(:)'/tk(nonan);
        elseif size(s,2) == 1
            s = NaN;
        end
    end
    if length(dn)>1
        cor = xcorr(dn',dn','coeff');
        cor = cor(ceil(length(cor)/2):end);
        % let's zero the first descending slope of the
        % autocorrelation function
        firstmin = find(cor(2:end)>cor(1:end-1));
        if not(isempty(firstmin) || isnan(framesampling))
            cor2 = cor;
            cor2(1:firstmin(1)) = 0;
            [pa,pfk] = max(cor2);
            if pfk > 1
                pf = 1/(pfk-1)/framesampling;
            end
        end
        cor = abs(cor);
        cor = cor/sum(cor);
        pe = -sum(cor.*log(cor+1e-12))./log(length(cor));
    end
end


function b = isdesign(f)
if iscell(f)
    f = f{1};
end
if isa(f,'mirdesign') || isa(f,'mirstruct')
    b = 1;
elseif isa(f,'mirdata') || not(isstruct(f))
    b = 0;
else
    fields = fieldnames(f);
    b = isdesign(f.(fields{1}));
end