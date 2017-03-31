function varargout = mirstd(f,varargin)
% m = mirstd(f) returns the standard deviation along frames of the feature f
%
%   f can be a structure array composed of features. In this case,
%       m will be structured the same way.

if isa(f,'mirstruct')
    data = get(f,'Data');
    for fi = 1:length(data)
        data{fi} = mirstd(data{fi});
    end
    varargout = {set(f,'Data',data)};
elseif isstruct(f)
    fields = fieldnames(f);
    for i = 1:length(fields)
        field = fields{i};
        stat.(field) = mirstd(f.(field));
    end
    varargout = {stat};
else
    
        normdiff.key = 'NormDiff';
        normdiff.type = 'Boolean';
        normdiff.default = 0;
    specif.option.normdiff = normdiff;

    specif.nochunk = 1;
    
    varargout = mirfunction(@mirstd,f,varargin,nargout,specif,@init,@main);
end


function [x type] = init(x,option)
type = '';


function m = main(f,option,postoption)
if iscell(f)
    f = f{1};
end
if isa(f,'mirhisto')
    warning('WARNING IN MIRSTD: histograms are not taken into consideration yet.')
    m = struct;
    return
end
fp = get(f,'FramePos');
ti = get(f,'Title');
d = get(f,'Data');
l = length(d);
for i = 1:l
    if iscell(d{i})
        if length(d{i}) > 1
            error('ERROR IN MIRSTD: segmented data not accepted yet.');
        else
            dd = d{i}{1};
        end
    else
        dd = d{i};
    end
    if iscell(dd)
        m{i} = {zeros(1,length(dd))};
        for j = 1:length(dd)
            m{i}{1}(j) = std(dd{j});
        end
    elseif size(dd,2) < 2
        nonan = find(not(isnan(dd)));
        dn = dd(nonan);
        if option.normdiff
            m{i}{1} = norm(diff(dn,2));
        else
            m{i}{1} = std(dn,0,2);
        end
    else
        dd = mean(dd,4);
        m{i} = {NaN(size(dd,1),1,size(dd,3))};
        for k = 1:size(dd,1)
            for l = 1:size(dd,3)
                dk = dd(k,:,l);
                nonan = find(not(isnan(dk)));
                if not(isempty(nonan))
                    dn = dk(nonan);
                    if option.normdiff
                        m{i}{1}(k,1,l) = norm(diff(dn,2));
                    else
                        m{i}{1}(k,1,l) = std(dn,0,2);
                    end
                end
            end
        end
    end
end
m = mirscalar(f,'Data',m,'Title',['Standard deviation of ',ti]);