function [f x] = mirframe(x,varargin)
%   f = mirframe(x) creates the frame decomposition of the audio signal x.
%       (x can be a file name as well.)
%   Optional arguments:
%       mirframe(x,'Length',w,wu):
%           w is the length of the window in seconds (default: .05 seconds)
%           u is the unit, either 
%               's' (seconds, default unit) 
%            or 'sp' (number of samples)
%       mirframe(x,'Hop',h,hu):
%           h is the hop factor, or distance between successive frames
%               (default: half overlapping: each frame begins at the middle
%                   of the previous frame)
%           u is the unit, either 
%               '/1' (ratio with respect to the frame length, default unit)
%               '%' (ratio as percentage)
%               's' (seconds)
%               'sp' (number of samples)
%            or 'Hz' (hertz), i.e., number of frames per second: the
%                   exactness of the frame rate is ensured and may cause a
%                   slight fluctuation of the elementary hop distances.
%       These arguments can also be written as follows:
%           mirframe(x,w,wu,h,hu)
%               (where some of these parameters can be omitted).

if isempty(x)
    f = {};
    return
end
if iscell(x)
    x = x{1};
end
if nargin == 0
    f = miraudio;
elseif isa(x,'mirdesign')
    if not(get(x,'Eval'))
        % During bottom-up construction of the general design
        
        para = scanargin(varargin);
        type = get(x,'Type');
        f = mirdesign(@mirframe,x,para,{},struct,type);
        
        fl = get(x,'FrameLength');
        fh = get(x,'FrameHop');
        flu = get(x,'FrameLengthUnit');
        fhu = get(x,'FrameHopUnit');
        if fl
            f = set(f,'FrameLength',fl,'FrameLengthUnit',flu,...
                      'FrameHop',fh,'FrameHopUnit',fhu);
        else
            f = set(f,'FrameLength',para.wlength.val,...
                      'FrameLengthUnit',para.wlength.unit,...
                      'FrameHop',para.hop.val,...
                      'FrameHopUnit',para.hop.unit);
        end
        f = set(f,'FrameEval',1,...
                  'SeparateChannels',get(x,'SeparateChannels'));
        if not(isamir(x,'miraudio'))
            f = set(f,'NoChunk',1);
        end
    else
        % During top-down evaluation initiation
        
        if isstruct(varargin{1}) && isfield(varargin{1},'struct')
            tmp = varargin{1}.struct;
            x = set(x,'Struct',tmp);
            varargin{1} = rmfield(varargin{1},'struct');
        end
        e = evaleach(x);
        if iscell(e)
            e = e{1};
        end
        if isempty(mirgetdata(e))
            f = e;
        else
            sc = get(x,'Scale');
            if ~isempty(sc)
                varargin{1}.wlength.val = varargin{1}.wlength.val(sc);
                if length(varargin{1}.hop.val)>1
                    varargin{1}.hop.val = varargin{1}.hop.val(sc);
                end
            end
            f = mirframe(e,varargin{:});
        end
    end
elseif isa(x,'mirdata')
    if isframed(x)
        warning('WARNING IN MIRFRAME: The input data is already decomposed into frames. No more frame decomposition.');
        f = x;
    else
        x = purgedata(x);
        dx = get(x,'Data');
        if isa(x,'mirtemporal')
            dt = get(x,'Time');
        else
            dt = get(x,'FramePos');
        end
        sf = get(x,'Sampling');
        para = scanargin(varargin);
        dx2 = cell(1,length(dx));   % magnitude in framed structure 
        dt2 = cell(1,length(dx));   % time positions in framed structure
        fp = cell(1,length(dx));    % frame positions
        for k = 1:length(dx)    % For each audio file, ...
            dxk = dx{k};
            dtk = dt{k};
            if strcmpi(para.wlength.unit,'s')
                l = para.wlength.val*sf{k};
            elseif strcmpi(para.wlength.unit,'sp')
                l = para.wlength.val;
            end
            if strcmpi(para.hop.unit,'/1')
                h = para.hop.val*l;
            elseif strcmpi(para.hop.unit,'%')
                h = para.hop.val*l*.01;
            elseif strcmpi(para.hop.unit,'s')
                h = para.hop.val*sf{k};
            elseif strcmpi(para.hop.unit,'sp')
                h = para.hop.val;
            elseif strcmpi(para.hop.unit,'Hz')
                h = sf{k}/para.hop.val;
            end
            l = floor(l);
            dx2k = cell(1,length(dxk));
            dt2k = cell(1,length(dxk));
            fpk = cell(1,length(dxk));
            if size(l)==1
                for j = 1:length(dxk)   % For each segment, ...
                    dxj = dxk{j};
                    dtj = dtk{j};
                    if not(isa(x,'mirtemporal'))
                        dxj = dxj';
                        dtj = dtj(1,:)';
                    end

                    n = floor((size(dxj,1)-l)/h)+1; % Number of frames
                    dx2j = zeros(l,n,size(dxj,3));
                    dt2j = zeros(l,n);
                    fpj = zeros(2,n);
                    if n < 1
                        disp('Frame length longer than total sequence size. No frame decomposition.');
                        dx2j = dxj(:,1,:);
                        dt2j = dtj;
                        fpj = [dtj(1) ; dtj(end)];
                    else
                        for i = 1:n % For each frame, ...
                            st = floor((i-1)*h+1);
                            stend = st+l-1;
                            dx2j(:,i,:) = dxj(st:stend,1,:);
                            dt2j(:,i) = dtj(st:stend);
                            fpj(:,i) = [dtj(st) dtj(stend)];
                        end
                    end
                    dx2k{j} = dx2j;
                    dt2k{j} = dt2j;
                    fpk{j} = fpj;
                end
                dx2{k} = dx2k;
                dt2{k} = dt2k;
                fp{k} = fpk;
            else % Multi-scale version
                if size(h) == 1
                    h = repmat(h,size(l));
                end
                for j = 1:length(l)   % For each scale, ...
                    dxj = dxk{1};
                    dtj = dtk{1};
                    if not(isa(x,'mirtemporal'))
                        dxj = dxj';
                        dtj = dtj(1,:)';
                    end

                    n = floor((size(dxj,1)-l(j))/h(j))+1; % Number of frames
                    dx2j = zeros(l(j),n,size(dxj,3));
                    dt2j = zeros(l(j),n);
                    fpj = zeros(2,n);
                    if n < 1
                        disp('Frame length longer than total sequence size. No frame decomposition.');
                        dx2j = dxj(:,1,:);
                        dt2j = dtj;
                        fpj = [dtj(1) ; dtj(end)];
                    else
                        for i = 1:n % For each frame, ...
                            st = floor((i-1)*h(j)+1);
                            stend = st+l(j)-1;
                            dx2j(:,i,:) = dxj(st:stend,1,:);
                            dt2j(:,i) = dtj(st:stend);
                            fpj(:,i) = [dtj(st) dtj(stend)];
                        end
                    end
                    dx2k{j} = dx2j;
                    dt2k{j} = dt2j;
                    fpk{j} = fpj;
                end
                dx2{k} = dx2k;
                dt2{k} = dt2k;
                fp{k} = fpk;
            end
        end
        if isa(x,'mirtemporal')
            f = set(x,'Time',dt2,'Data',dx2,'FramePos',fp);
        else
            f = mirtemporal([],'Time',dt2,'Data',dx2,'FramePos',fp,...
                    'Sampling',get(x,'Sampling'),'Name',get(x,'Name'),...
                    'Label',get(x,'Label'),'Channels',get(x,'Channels'),...
                    'Centered',0,'Title',get(x,'Title'));
        end
    end
else
    f = mirframe(miraudio(x),varargin{:});
end


function para = scanargin(v)
if not(isempty(v)) && isstruct(v{1})
    if length(v) == 1
        para = v{1};
    else
        para.wlength = v{1};
        para.hop = v{2};
    end
    return
end
para.wlength.val = 0.05;
para.wlength.unit = 's';
para.hop.val = 0.5;
para.hop.unit = '/1';
nv = length(v);
i = 1;
j = 1;
while i <= nv
    arg = v{i};
    if strcmpi(arg,'WinLength') || strcmpi(arg,'Length')
        if i < nv && isnumeric(v{i+1})
            i = i+1;
            j = 0;
            para.wlength.val = v{i};
        else
            error('ERROR IN MIRFRAME: Incorrect use of Length option. See help mirframe.'); 
        end
        if i < nv && ischar(v{i+1}) && ...
                (strcmpi(v{i+1},'s') || strcmpi(v{i+1},'sp'))
            i = i+1;
            para.wlength.unit = v{i};
        end
    elseif strcmpi(arg,'Hop')
        if i < nv && isnumeric(v{i+1})
            i = i+1;
            j = 0;
            para.hop.val = v{i};
        else
            error('ERROR IN MIRFRAME: Incorrect use of Hop option. See help mirframe.'); 
        end
        if i < nv && ischar(v{i+1}) && ...
                (strcmpi(v{i+1},'%') || strcmpi(v{i+1},'/1') || ...
                 strcmpi(v{i+1},'s') || strcmpi(v{i+1},'sp') || ...
                 strcmpi(v{i+1},'Hz'))
            i = i+1;
            para.hop.unit = v{i};
        end
    elseif isnumeric(arg)
        switch j
            case 1
                j = 2;
                para.wlength.val = arg;
                if i < nv && ischar(v{i+1}) && ...
                        (strcmpi(v{i+1},'s') || strcmpi(v{i+1},'sp'))
                    i = i+1;
                    para.wlength.unit = v{i};
                end
            case 2
                j = 3;
                para.hop.val = arg;
                if i < nv && ischar(v{i+1}) && ...
                        (strcmpi(v{i+1},'%') || strcmpi(v{i+1},'/1') || ...
                         strcmpi(v{i+1},'s') || strcmpi(v{i+1},'sp') || ...
                         strcmpi(v{i+1},'Hz'))
                    i = i+1;
                    para.hop.unit = v{i};
                end
            otherwise
                error('ERROR IN MIRFRAME: Syntax error. See help mirframe.');
        end
    elseif not(isempty(arg))
        error('ERROR IN MIRFRAME: Syntax error. See help mirframe.');
    end
    i = i+1;
end