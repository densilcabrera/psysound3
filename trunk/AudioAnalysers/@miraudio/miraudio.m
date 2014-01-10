function varargout = miraudio(orig,varargin)
%   a = miraudio('filename') loads the sound file 'filename' (in WAV or AU
%       format) into a miraudio object.
%   a = miraudio('Folder') loads all the sound files in the CURRENT folder
%       into a miraudio object.
%   a = miraudio(v,sr), where v is a column vector, translates the vector v
%       into a miraudio object. The sampling frequency is set to sr Hertz.
%           Default value for sr: 44100 Hz.
%   a = miraudio(b, ...), where b is already a miraudio object, performs 
%       operations on b specified by the optional arguments (see below).
%
%   Transformation options:
%       miraudio(...,'Mono',0) does not perform the default summing of
%           channels into one single mono track, but instead stores each 
%           channel of the initial soundfile separately.       
%       miraudio(...,'Center') centers the signals.
%       miraudio(...,'Sampling',r) resamples at sampling rate r (in Hz).
%           (Requires the Signal Processing Toolbox.)
%       miraudio(...,'Normal') normalizes with respect to RMS energy.
%   Extraction options:
%       miraudio(...,'Extract',t1,t2,u,f) extracts the signal between dates
%           t1 and t2, expressed in the unit u.
%           Possible values for u:
%               's' (seconds, by default),
%               'sp' (sample index, starting from 1).
%           The additional optional argument f indicates the referential
%               origin of the temporal positions. Possible values for f:
%               'Start' (by default)
%               'Middle' (of the sequence)
%               'End' of the sequence
%               When using 'Middle' or 'End', negative values for t1 or t2
%               indicate values before the middle or the end of the audio
%               sequence.
%       miraudio(...,'Trim') trims the pseudo-silence beginning and end off
%           the audio file. Silent frames are frames with RMS below t times
%           the medium RMS of the whole audio file.
%               Default value: t = 0.06
%           instead of 'Trim':
%              'TrimStart' only trims the beginning of the audio file,
%              'TrimEnd' only trims the end.
%           miraudio(...,'TrimThreshold',t) specifies the trimming threshold t.
%       miraudio(...,'Channel',c) or miraudio(...,'Channels',c) selects the
%           channels indicated by the (array of) integer(s) c.
%   Labeling option:
%       miraudio(...,'Label',l) labels the audio signal(s) following the 
%           label(s) l.
%           If l is a (series of) number(s), the audio signal(s) are
%           labelled using the substring of their respective file name of 
%           index l. If l=0, the audio signal(s) are labelled using the
%           whole file name.



if nargin==0 % In order for Psysound to get the Name field with PossAnalyser
    
cl=struct;
cl.fresh=[];
cl.extracted=[];
base=mirtemporal();
cl=class(cl,'miraudio',base);
cl=set(cl,'Name','Mirtoolbox (miraudio)');
varargout={cl};

else


if isnumeric(orig)
    if size(orig,2) > 1 || size(orig,3) > 1
        mirerror('MIRAUDIO','Only column vectors can be imported into mirtoolbox.');
    end
    if nargin == 1
        f = 44100;
    else
        f = varargin{1};
    end
    b = 32;
    if size(orig,1) == 1
        orig = orig';
    end
    tp = (0:size(orig,1)-1)'/f;
    l = (size(orig,1)-1)/f;
    t = mirtemporal([],'Time',{{tp}},'Data',{{orig}},'Length',{{l}},...
                    'FramePos',{{tp([1 end])}},'Sampling',{f},...
                    'Name',{inputname(1)},'Label',{{}},'Clusters',{{}},...
                    'Channels',[],'Centered',0,'NBits',{b},...
                    'Title','Audio signal',...
                    'PeakPos',{{{}}},'PeakVal',{{{}}},'PeakMode',{{{}}});
    aa.fresh = 1;
    aa.extracted = 0;
cl=class(aa,'miraudio',t);
% Adapted for Psysound3
cl=set(cl,'Name','Mirtoolbox (miraudio)'); 
    varargout = {cl};

    return

end

            if isstruct(orig) && nargin==1
% Adapted for Psysound3 (does this situation actually exist for MirToolbox classes?)
cl=struct;
cl.fresh=[];
cl.extracted=[];
base=mirtemporal(orig);
cl=class(cl,'miraudio',base);
cl=set(cl,'Name','Mirtoolbox (miraudio)'); 
    varargout = {cl};

            else


        center.key = 'Center';
        center.type = 'Boolean';
        center.default = 0;
        center.when = 'After';
    option.center = center;
        
        normal.key = 'Normal';
        normal.type = 'Boolean';
        normal.default = 0;
        normal.when = 'After';
    option.normal = normal;
    
        extract.key = {'Extract','Excerpt'};
        extract.type = 'Integer';
        extract.number = 2;
        extract.default = [];
        extract.unit = {'s','sp'};
        extract.defaultunit = 's';
        extract.from = {'Start','Middle','End'};
        extract.defaultfrom = 'Start';
    option.extract = extract;
        
        trim.type = 'String';
        trim.choice = {'NoTrim','Trim','TrimBegin','TrimStart','TrimEnd'};
        trim.default = 'NoTrim';
        trim.when = 'After';
    option.trim = trim;
        
        trimthreshold.key = 'TrimThreshold';
        trimthreshold.type = 'Integer';
        trimthreshold.default = .06;
        trimthreshold.when = 'After';
    option.trimthreshold = trimthreshold;
        
        label.key = 'Label';
        label.default = '';
        label.when = 'After';
    option.label = label;
        
        sampling.key = 'Sampling';
        sampling.type = 'Integer';
        sampling.default = 0;
        sampling.when = 'Both';
    option.sampling = sampling;
        
   %     segment.key = 'Segment';
   %     segment.type = 'Integer';
   %     segment.default = [];
   %     segment.when = 'After';
   % option.segment = segment;

        reverse.key = 'Reverse';
        reverse.type = 'Boolean';
        reverse.default = 0;
        reverse.when = 'After';
    option.reverse = reverse;

        mono.key = 'Mono';
        mono.type = 'Boolean';
        mono.default = NaN;
        mono.when = 'After';
    option.mono = mono;    

        separate.key = 'SeparateChannels';
        separate.type = 'Boolean';
        separate.default = 0;
    option.separate = separate;    
    
        Ch.key = {'Channel','Channels'};
        Ch.type = 'Integer';
        Ch.default = [];
        Ch.when = 'After';
    option.Ch = Ch;
        
specif.option = option;

specif.beforechunk = {@beforechunk,'normal'};
specif.eachchunk = @eachchunk;
specif.combinechunk = @combinechunk;

if nargin > 1 && ischar(varargin{1}) && strcmp(varargin{1},'Now')
    if nargin > 2
        extract = varargin{2};
    else
        extract = [];
    end
    para = [];
    varargout = {main(orig,[],para,[],extract)};
else
    varargout = mirfunction(@miraudio,orig,varargin,nargout,specif,@init,@main);
end
if isempty(varargout)
    varargout = {{}};
end
            end
end


function [x type] = init(x,option)
if isa(x,'mirdesign')
    if option.sampling
        x = setresampling(x,option.sampling);
    end
end
type = 'miraudio';


function a = main(orig,option,after,index,extract)
if iscell(orig)
    orig = orig{1};
end
if ischar(orig)
    if nargin < 5
        extract = [];
    end
    [d{1},tp{1},fp{1},f{1},l{1},b{1},n{1},ch{1}] = mirread(extract,orig,1,0);
    t = mirtemporal([],'Time',tp,'Data',d,'FramePos',fp,'Sampling',f,...
                       'Name',n,'Label',cell(1,length(d)),...
                       'Clusters',cell(1,length(d)),'Length',l,...
                       'Channels',ch,'Centered',0,'NBits',b);
    t = set(t,'Title','Audio waveform');
    a.fresh = 1;
    a.extracted = 1;
    a = class(a,'miraudio',t);
% Adapted for Psysound3
    a=set(a,'Name','Mirtoolbox (miraudio)'); 
else
    if not(isempty(option)) && not(isempty(option.extract))
        if not(isstruct(after))
            after = struct;
        end
        after.extract = option.extract;
    end
    if isa(orig,'miraudio')
        a = orig;
    else
        a.fresh = 1;
        a.extracted = 0;
        a = class(a,'miraudio',orig);
        a=set(a,'Name','Mirtoolbox (miraudio)');
    end
end      
if not(isempty(after))
    a = post(a,after);
end    


function a = post(a,para)
if a.fresh && isfield(para,'mono')
    a.fresh = 0;
    if isnan(para.mono)
        para.mono = 1;
    end
end
if isfield(para,'mono') && para.mono == 1
    a = mirsum(a,'Mean');
end
d = get(a,'Data');
t = get(a,'Time');
ac = get(a,'AcrossChunks');
f = get(a,'Sampling');
cl = get(a,'Clusters');
for h = 1:length(d)
    for k = 1:length(d{h})
        tk = t{h}{k};
        dk = d{h}{k};
        if isfield(para,'extract') && not(isempty(para.extract)) ...
                && ~a.extracted
            t1 = para.extract(1);
            t2 = para.extract(2);
            if para.extract(4)
                if para.extract(4) == 1
                    shift = round(size(tk,1)/2);
                elseif para.extract(4) == 2
                    shift = size(tk,1);
                end
                if para.extract(3)
                    shift = tk(shift,1,1);
                end
                t1 = t1+shift;
                t2 = t2+shift;
            end                
            if para.extract(3) % in seconds
                ft = find(tk>=t1 & tk<=t2);
            else               % in samples
                if not(t1)
                    warning('WARNING IN MIRAUDIO: Extract sample positions should be real positive integers.')
                    display('Positions incremented by one.');
                    t1 = t1+1;
                    t2 = t2+1;
                end
                ft = t1:t2;
            end
            tk = tk(ft,:,:);
            dk = dk(ft,:,:);
        end
        if isfield(para,'Ch') && not(isempty(para.Ch))
            dk = dk(:,:,para.Ch);
        end
        if isfield(para,'center') && para.center
            dk = center(dk);
            a = set(a,'Centered',1);
        end
        if isfield(para,'normal') && para.normal
            nl = size(dk,1);
            nc = size(dk,3);
            if isempty(ac)
                ee = 0;
                for j = 1:nc
                    ee = ee+sum(dk(:,:,j).^2);
                end
                ee = sqrt(ee/nl/nc);
            else
                ee = sqrt(sum(ac.sqrsum.^2)/ac.samples);
            end
            if ee
                dk = dk./repmat(ee,[nl,1,nc]);
            end
        end
        if isfield(para,'trim') && not(isequal(para.trim,0)) ...
                && not(strcmpi(para.trim,'NoTrim'))
            if not(para.trimthreshold)
                para.trimthreshold = 0.06;
            end
            trimframe = 100;
            trimhop = 10;
            nframes = floor((length(tk)-trimframe)/trimhop)+1;
            rms = zeros(1,nframes);
            for j = 1:nframes
                st = floor((j-1)*trimhop)+1;
                for z = 1:size(dk,3)
                    rms(1,j,z) = norm(dk(st:st+trimframe-1,1,z))/sqrt(trimframe);
                end
            end
            rms = (rms-repmat(min(rms),[1,size(rms,2),1]))...
                     ./repmat(max(rms)-min(rms),[1,size(rms,2),1]);
            nosil = find(rms>para.trimthreshold);
            if strcmpi(para.trim,'Trim') || strcmpi(para.trim,'TrimStart') ...
                                         || strcmpi(para.trim,'TrimBegin')
                nosil1 = min(nosil);
                if nosil1 > 1
                    nosil1 = nosil1-1;
                end
                n1 = floor((nosil1-1)*trimhop)+1;
            else
                n1 = 1;
            end
            if strcmpi(para.trim,'Trim') || strcmpi(para.trim,'TrimEnd')
                nosil2 = max(nosil);
                if nosil2 < length(rms)
                    nosil2 = nosil2+1;
                end
                n2 = floor((nosil2-1)*trimhop)+1;
            else
                n2 = length(tk);
            end
            tk = tk(n1:n2);
            dk = dk(n1:n2,1,:);
        end
        if isfield(para,'sampling') && para.sampling
            if and(f{k}, not(f{k} == para.sampling))
                for j = 1:size(dk,3)
                    rk(:,:,j) = resample(dk(:,:,j),para.sampling,f{k});
                end
                dk = rk;
                tk = repmat((0:size(dk,1)-1)',[1 1 size(tk,3)])...
                            /para.sampling + tk(1,:,:);
            end
            f{k} = para.sampling;
        end
        d{h}{k} = dk;
        t{h}{k} = tk;
        %if isfield(para,'reverse') && para.reverse
        %    d{h}{k} = flipdim(d{h}{k},1);
        %end
    end
end
a = set(a,'Data',d,'Time',t,'Sampling',f,'Clusters',cl);
a = set(a,'Extracted',0);
if isfield(para,'label') 
    if isnumeric(para.label)
        n = get(a,'Name');
        l = cell(1,length(d));
        for k = 1:length(d)
            if para.label
                l{k} = n{k}(para.label);
            else
                l{k} = n{k};
            end
        end
        a = set(a,'Label',l);
    elseif iscell(para.label)
        idx = mod(get(a,'Index'),length(para.label));
        if not(idx)
            idx = length(para.label);
        end
        a = set(a,'Label',para.label{idx});
    elseif ischar(para.label) && ~isempty(para.label)
        l = cell(1,length(d));
        for k = 1:length(d)
            l{k} = para.label;
        end
        a = set(a,'Label',l);
    end
end


function [new orig] = beforechunk(orig,option,missing)
option.normal = 0;
a = miraudio(orig,option);
d = get(a,'Data');
old = get(orig,'AcrossChunks');
if isempty(old)
    old.sqrsum = 0;
    old.samples = 0;
end
new = mircompute(@crossum,d);
new = new{1}{1};
new.sqrsum = old.sqrsum + new.sqrsum;
new.samples = old.samples + new.samples;


function s = crossum(d)
s.sqrsum = sum(d.^2);
s.samples = length(d);


function [y orig] = eachchunk(orig,option,missing)
y = miraudio(orig,option);


function y = combinechunk(old,new)
do = get(old,'Data');
to = get(old,'Time');
dn = get(new,'Data');
tn = get(new,'Time');
y = set(old,'Data',{{[do{1}{1};dn{1}{1}]}},...
            'Time',{{[to{1}{1};tn{1}{1}]}});