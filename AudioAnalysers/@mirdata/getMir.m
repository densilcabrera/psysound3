function val = getMir(a, propName)
% GET Get properties from the MIRdata object
% and return the value

if strcmp(class(a),'mirdata')
switch propName
    case 'Pos'
        val = a.pos;
    case 'Data'
        val = a.data;
    case 'Unit'
        val = a.unit;
    case 'FramePos'
        val = a.framepos;
    case 'Framed'
        val = a.framed;
    case 'Sampling'
        val = a.sr;
    case 'Length'
        val = a.length;
    case 'NBits'
        val = a.nbits;
    case 'Name'
        val = a.name;
    case 'Name2'
        val = a.name2;
    case 'Label'
        val = a.label;
    case 'Channels'
        val = a.channels;
    case 'Clusters'
        val = a.clusters;
    case 'MultiData'
        val = a.multidata;
    case 'PeakPos'
        val = a.peak.pos;
    case {'PeakPosUnit','AttackPosUnit','ReleasePosUnit'}
        switch propName
            case 'PeakPosUnit'
                pp = a.peak.pos;
            case 'AttackPosUnit'
                pp = a.attack.pos;
            case 'ReleasePosUnit'
                pp = a.release.pos;
        end
        po = a.pos;
        d = a.data;
        val = cell(1,length(pp));
        if isempty(d)
            return
        end
        for k = 1:length(pp)
            val{k} = cell(1,length(pp{k}));
            if isempty(pp{k})
                nseg = 0;
            elseif iscell(pp{k}{1})
                nseg = length(pp{k});
            else
                nseg = 1;
            end
            for i = 1:nseg
                ppi = pp{k}{i};
                if isempty(po)
                    poi = (1:size(d{k}{i},2))';
                elseif iscell(po{k})
                    if isempty(po{k})
                        poi = mean(a.framepos{k}{1})';
                    elseif isempty(a.pos)
                        poi = po{k}{i}';
                    elseif ischar(po{k}{1})
                        poi = (1:length(po{k}))';
                    else
                        poi = po{k}{i};
                    end
                else
                    for j = 1:size(po,3)
                        poi(:,:,j) = po{k}(:,:,j)';
                    end
                end
                val{k}{i} = cell(size(ppi));
                for h = 1:size(ppi,3)
                    for j = 1:size(ppi,2)
                        if size(poi,3) > 1 && size(poi,1) == 1
                            val{k}{i}{1,j,h} = ppi{1,j,h};
                        else
                            val{k}{i}{1,j,h} = poi(ppi{1,j,h},1);
                        end
                    end
                end
            end
        end
    case 'PeakPrecisePos'
        val = a.peak.precisepos;
    case 'PeakVal'
        val = a.peak.val;
    case 'PeakPreciseVal'
        val = a.peak.preciseval;
    case 'PeakMaxVal'
        pv = a.peak.val;
        val = cell(1,length(pv));
        for h = 1:length(pv)
            val{h} = cell(1,length(pv{h}));
            for i = 1:length(pv{h})
                pvi = pv{h}{i};
                %if iscell(pvi)
                %    pvi = pvi{1}; % Segmented data not taken into consideration yet.
                %end
                val{h}{i} = zeros(1,length(pvi));
                for j = 1:length(pvi)
                    if isempty(pvi{j})
                        val{h}{i}(1,j) = NaN;
                    else
                        val{h}{i}(1,j) = max(pvi{j});
                    end
                end
            end
        end
    case 'PeakMode'
        val = a.peak.mode;
    case 'AttackPos'
        if isempty(a.attack)
            val = [];
        else
            val = a.attack.pos;
        end
    case 'ReleasePos'
        if isempty(a.release)
            val = [];
        else
            val = a.release.pos;
        end
    case 'TrackPos'
        if isempty(a.track)
            val = [];
        else
            val = a.track.pos;
        end
    case 'TrackPosUnit'
        if isempty(a.track)
            val = [];
        else
            pp = a.track.pos;
            po = a.pos;
            d = a.data;
            val = cell(1,length(pp));
            for k = 1:length(pp)
                val{k} = cell(1,length(pp{k}));
                if isempty(pp{k})
                    nseg = 0;
                elseif iscell(pp{k}{1})
                    nseg = length(pp{k});
                else
                    nseg = 1;
                end
                for i = 1:nseg
                    ppi = pp{k}{i}{1};
                    if isempty(po)
                        poi = (1:size(d{k}{i},2))';
                    elseif iscell(po{k})
                        if isempty(po{k})
                            poi = mean(a.framepos{k}{1})';
                        elseif isempty(a.pos)
                            poi = po{k}{i}';
                        elseif ischar(po{k}{1})
                            poi = (1:length(po{k}))';
                        else
                            poi = po{k}{i};
                        end
                    else
                        for j = 1:size(po,3)
                            poi(:,:,j) = po{k}(:,:,j)';
                        end
                    end
                    val{k}{i}{1} = zeros(size(ppi));
                    if size(poi,3) > 1 && size(poi,1) == 1
                        val{k}{i}{1} = ppi;
                    else
                        for h = 1:size(ppi,2)
                            for j = 1:size(ppi,1)
                                if ppi(j,h)
                                    val{k}{i}{1}(j,h) = poi(ppi(j,h),1);
                                else
                                    val{k}{i}{1}(j,h) = 0;
                                end
                            end
                        end
                    end
                end
            end
        end
    case 'TrackVal'
        if isempty(a.track)
            val = [];
        else
            val = a.track.val;
        end
    case 'TrackPrecisePos'
        if isempty(a.track)
            val = [];
        else
            val = a.track.precisepos;
        end
    case 'TrackPreciseVal'
        if isempty(a.track)
            val = [];
        else
            val = a.track.preciseval;
        end
    case 'Title'
        val = a.title;
    case 'Abs'
        val = a.abs;
    case 'Ord'
        val = a.ord;
    case 'InterChunk'
        val = a.interchunk;
    case 'TmpIdx'
        val = a.tmpidx;       
    case 'AcrossChunks'
        val = a.acrosschunks;
    case 'Interpolable'
        val = a.interpolable;
    case 'TmpFile'
        val = a.tmpfile;
    case 'Index'
        val = a.index;


 otherwise
  % See if a specialised get method for the property value exists
error('getMir : specialized methods?')

%  
%  try % ismethod is not going to work in a class hierarchy
%         m = ['get', propName]; % put sp meths in mirdata folder?
%     val = eval([m, '(obj)']);
%     catch
%     error(['Put sp meths in mirdata folder? Analyser: get: ', propName, ' is not a field of the Analyser', ...
%            ' class.  Could not resolve ', m, ' for class ', class(a)]);
%   end
end


    elseif strcmp(class(a),'mirscalar')

switch propName
    case 'Mode'
        val = a.mode;
    case 'Legend'
        val = a.legend;
    case 'Parameter'
        val = a.parameter;
    otherwise
        val = get(mirdata(a),propName);
end

   else
    error('unavailable data type')
end