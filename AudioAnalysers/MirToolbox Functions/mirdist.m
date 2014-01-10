function d = mirdist(x,y,dist)
%   d = mirdist(x,y) evaluates the distance between x and y.
%   x is the feature values corresponding to one audio file, and y is the
%       values (for the same feature) corrdponding to one (or several)
%       audio files.
%   If x and y are not decomposed into frames,
%       d = mirdist(x,y,f) specifies distance function.
%           Default value: f = 'Cosine'
%   If x and y are composed of clustered frames (using mircluster), the
%       cluster signatures are compared using Earth Mover Distance.
%       (Logan, Salomon, 2001)
%   If x and y contains peaks, the vectors representing the peak
%       distributions are compared using Euclidean distance.
%       (used with mirnovelty in Jacobson, 2006)
%
% The Earth Mover Distance is based on the implementation by Yossi Rubner,
% wrapped for Matlab by Elias Pampalk.

if not(isa(x,'mirdata'))
    x = miraudio(x);
end
if not(isa(y,'mirdata'))
    y = miraudio(y);
end

clx = get(x,'Clusters');
if isempty(clx{1})
    px = get(x,'PeakPos');
    if not(iscell(px)) || isempty(px{1}) || ...
            not(iscell(px{1})) || isempty(px{1}{1}) || not(iscell(px{1}{1}))
        if nargin < 3
            dist = 'Cosine';
        end

        d = get(x,'Data');
        dd = d{1}{1};
        if iscell(dd)
            dd = dd{1};
        end
        if size(dd,2)>1
            if size(dd,1)>1
                error('ERROR IN MIRDIST: If the input is decomposed into frames, they should first be clustered.'); 
            else
                dd = dd';
            end
        end

        e = get(y,'Data');
        dt = cell(1,length(e));
        for h = 1:length(e)
            ee = e{h}{1};
            if iscell(ee)
                ee = ee{1};
            end
            if size(ee,2)>1
                if size(ee,1)>1
                    error('ERROR IN MIRDIST: If the input is decomposed into frames, they should first be clustered.'); 
                else
                    ee = ee';
                end
            end
            if isempty(ee)
                if isempty(dd)
                    dt{h}{1} = 0;
                else
                    dt{h}{1} = Inf;
                end
            else
                if length(dd)<length(ee)
                    dd(length(ee)) = 0;
                    %ee = ee(1:length(d));
                elseif length(ee)<length(dd)
                    ee(length(dd)) = 0;
                    %dd = dd(1:length(ee));
                end
                if length(dd) == 1
                    dt{h}{1} = abs(dd-ee);
                elseif norm(dd) && norm(ee)
                    dt{h}{1} = pdist([dd(:)';ee(:)'],dist);
                else
                    dt{h}{1} = NaN;
                end
            end
        end
    else
        % Euclidean distance between vectors to compare data with peaks
        % (used with mirnovelty in Jacobson, 2006).
        sig = pi/4;
        dx = get(x,'Data');
        nx = length(px{1}{1}{1});
        cx = mean(px{1}{1}{1}/length(dx{1}{1}));
        dy = get(y,'Data');
        py = get(y,'PeakPos');
        dt = cell(1,length(py));
        for h = 1:length(py)
            ny = length(py{h}{1}{1});
            cy = mean(py{h}{1}{1}/length(dy{h}{1}));
            dt{h}{1} = sqrt((nx*cos(sig*cx)-ny*cos(sig*cy))^2 ...
                           +(nx*sin(sig*cx)-ny*sin(sig*cy))^2);
        end
    end
else
    % Earth Mover's Distance to compare clustered data.
    cly = get(y,'Clusters');
    dt = cell(1,length(cly));
    for h = 1:length(cly)
        cost = zeros(length(clx{1}.weight),length(cly{h}.weight));
        for i = 1:length(clx{1}.weight)
            for j = 1:length(cly{h}.weight)
                covx = clx{1}.covar(:,i);
                covy = cly{h}.covar(:,j);
                mux = clx{1}.centr(:,i);
                muy = cly{h}.centr(:,j);
                cost(i,j) = sum(covx./covy + covy./covx + ...
                        (mux-muy).^2.*(1./covx + 1./covy) - 2);
            end
        end
        dt{h}{1} = emd_wrapper(cost,clx{1}.weight,cly{h}.weight);
    end
end
d = mirscalar(y,'Data',dt,'Title',[get(y,'Title'),' Distance'],...
                'Name',get(x,'Name'),'Name2',get(y,'Name'));