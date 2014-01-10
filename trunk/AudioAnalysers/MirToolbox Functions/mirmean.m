function varargout = mirmean(f,varargin)
% m = mirmean(f) returns the mean along frames of the feature f
%
%   f can be a structure array composed of features. In this case,
%       m will be structured the same way.

if isa(f,'mirstruct')
    data = get(f,'Data');
    for fi = 1:length(data)
        data{fi} = mirmean(data{fi});
    end
    varargout = {set(f,'Data',data)};
elseif isstruct(f)
    fields = fieldnames(f);
    for i = 1:length(fields)
        field = fields{i};
        stat.(field) = mirmean(f.(field));
    end
    varargout = {stat};
else
    specif.nochunk = 1;
    varargout = mirfunction(@mirmean,f,varargin,nargout,specif,@init,@main);
end


function [x type] = init(x,option)
type = '';


function m = main(f,option,postoption)
if iscell(f)
    f = f{1};
end
if isa(f,'mirhisto')
    warning('WARNING IN MIRMEAN: histograms are not taken into consideration yet.')
    m = struct;
    return
end
fp = get(f,'FramePos');
ti = get(f,'Title');
if 0 %get(f,'Peaks')
    if not(isempty(get(f,'PeakPrecisePos')))
        stat = addstat(struct,get(f,'PeakPrecisePos'),fp,'PeakPos');
        stat = addstat(stat,get(f,'PeakPreciseVal'),fp,'PeakMag');
    else
        stat = addstat(struct,get(f,'PeakPosUnit'),fp,'PeakPos');
        stat = addstat(stat,get(f,'PeakVal'),fp,'PeakMag');
    end
else
    d = get(f,'Data');
end
l = length(d);
for i = 1:l
    if iscell(d{i})
        if length(d{i}) > 1
            error('ERROR IN MIRMEAN: segmented data not accepted yet.');
        else
            dd = d{i}{1};
        end
    else
        dd = d{i};
    end
    %dd = uncell(dd);
    if 0 %iscell(dd)
        j = 0;
        singul = 1;
        ddd = [];
        while j<length(dd) && singul
            j = j+1;
            if length(dd{j}) > 1
                singul = 0;
            elseif length(dd{j}) == 1
                ddd(end+1) = dd{j};
            end
        end
        if singul
            dd = ddd;
        end
    end
    if iscell(dd)
        m{i} = {zeros(1,length(dd))};
        for j = 1:length(dd)
            m{i}{1}(j) = mean(dd{j});
        end
    elseif size(dd,2) < 2
        nonan = find(not(isnan(dd)));
        dn = dd(nonan);
        m{i}{1} = mean(dn,2);
    else
        %diffp = fp{i}{1}(1,2:end) - fp{i}{1}(1,1:end-1);
        %if round((diffp(2:end)-diffp(1:end-1))*1000)
            % Not regular sampling (in mirattacktime for instance)
        %    framesampling = NaN;
        %else
        %    framesampling = fp{i}{1}(1,2)-fp{i}{1}(1,1);
        %end
        dd = mean(dd,4);
        m{i} = {NaN(size(dd,1),1,size(dd,3))};
        for k = 1:size(dd,1)
            for l = 1:size(dd,3)
                dk = dd(k,:,l);
                nonan = find(not(isnan(dk)));
                if not(isempty(nonan))
                    dn = dk(nonan);
                    m{i}{1}(k,1,l) = mean(dn,2);
                end
            end
        end
    end
end
m = mirscalar(f,'Data',m,'Title',['Average of ',ti]);