function [y d2] = evaleach(d,single,name)
% Top-down traversal of the design flowchart, at the beginning of the
% evaluation phase.
% Called by mirfunction, mireval, mirframe and mirsegment.
% This is during that traversal that we check whether a chunk decomposition
% needs to be performed or not, and carry out that chunk decomposition.

if nargin<3 || isempty(name)
    if not(ischar(d.method))
        name = func2str(d.method);
    end
end
if nargin<2
    single = 0;
end

CHUNKLIM = mirchunklim;
f = d.file;
fr = d.frame;
if ~isempty(fr) && length(fr.length.val)>1
    fr.length.val = fr.length.val(d.scale);
    if length(fr.hop.val)>1
        fr.hop.val = fr.hop.val(d.scale);
    end
end
frnochunk = isfield(d.frame,'dontchunk');
frchunkbefore = isfield(d.frame,'chunkbefore');
sg = d.segment;
sr = d.sampling;
sr2 = d.resampling;
w = d.size;
lsz = w(2)-w(1)+1;    
len = lsz/sr;
if ischar(sg)
    error('ERROR in MIREVAL: mirsegment of design object accepts only array of numbers as second argument.');
end
if not(isempty(sg))
    if ~isnumeric(sg)
        sg = sort(mirgetdata(sg));
        sg = [0 sg';sg' len];
    end
    over = find(sg(2,:) > len);
    if not(isempty(over))
        sg = sg(:,1:over-1);
    end
end
a = d.argin;
ch = d.chunk;
chan = d.channel;
specif = d.specif;
if isaverage(specif)
    specif.eachchunk = 'Normal';
end

if ischar(a)
    % The top-down traversal of the design flowchart now reaches the lowest
    % layer, i.e., audio file loading.
    % Now the actual evaluation will be carried out bottom-up.
    
    if isempty(ch)
        % No chunk decomposition
        y = miraudio(f,'Now',[w(:)' chan]);
    else
        % Chunk decomposition
        y = miraudio(f,'Now',[ch(1),ch(2) chan]);
    end
    if not(isempty(d.postoption)) && d.postoption.mono
        y = miraudio(y,'Mono',1);
    end
    y = set(y,'AcrossChunks',get(d,'AcrossChunks'));
    y = set(y,'Extracted',1);
    d2 = d;
    
elseif d.chunkdecomposed && isempty(d.tmpfile)
    % Already in a chunk decomposition process
    
    [y d2] = evalnow(d);  
    
elseif isempty(fr) || frnochunk || not(isempty(sg)) %% WHAT ABOUT CHANNELS?
    % No frame or segment decomposition in the design to evaluate
    % (Or particular frame decomposition, where chunks are not distributed to children (frnochunk).)
    if not(isempty(sg))
        meth = 'Segment ';
        if size(sg,1) == 1
            chunks = floor(sg(1:end-1)*sr)+1;
            chunks(2,:) = min( floor(sg(2:end)*sr)-1,lsz-1)+1;
        else
            chunks = floor(sg*sr);
            chunks(1,:) = chunks(1,:)+1;
        end
    elseif not(isfield(specif,'eachchunk')) ...
            || d.nochunk ...
            || (not(isempty(single)) && isnumeric(single) && single > 1 ...
                && isfield(specif,'combinechunk') ...
                && iscell(specif.combinechunk))
        chunks = [];
    else
        meth = 'Chunk ';
        if isempty(fr)
            if lsz > CHUNKLIM
            % The required memory exceed the max memory threshold.
                nch = ceil(lsz/CHUNKLIM); 
            %%% TAKE INTO CONSIDERATION NUMBER OF CHANNELS; ETC... 
                chunks = max(0,lsz-CHUNKLIM*(nch:-1:1))+w(1);
                chunks(2,:) = lsz-CHUNKLIM*(nch-1:-1:0)+w(1)-1;
            else
                chunks = [];
            end
        else
            chunks = compute_frames(fr,sr,sr2,w,lsz,CHUNKLIM,d.overlap);
        end
    end
    
    if not(isempty(chunks))
        % The chunk decomposition is performed.
        nch = size(chunks,2);
        d = callbeforechunk(d,d,w,lsz); % Some optional initialisation
        tmp = [];
        if mirwaitbar
            h = waitbar(0,['Computing ' name]);
        else
            h = 0;
        end
        if not(isempty(d.tmpfile)) && d.tmpfile.fid == 0
            % When applicable, a new temporary file is created.
            d.tmpfile.fid = fopen('tmpfile.mirtoolbox','w');
        end
        tmpfile = [];
        if not(d.ascending)
            chunks = fliplr(chunks);
        end

        afterpostoption = d.postoption; % Used only when:
                        % - eachchunk is set to 'Normal',
                        % - combinechunk is not set to 'Average', and
                        % - no afterchunk field has been specified.
                        % afterpostoption will be used for the final call
                        % to the method after the chunk decomposition.
        method = d.method;
        if ~isfield(specif,'eachchunk')
            specif.eachchunk = 'Normal';
        end
        if ischar(specif.eachchunk) && strcmpi(specif.eachchunk,'Normal')
            if not(isempty(d.postoption))
                pof = fieldnames(d.postoption);
                for o = 1:length(pof)
                    if isfield(specif.option.(pof{o}),'chunkcombine')
                        afterpostoption = rmfield(afterpostoption,pof{o});
                    else
                        d.postoption = rmfield(d.postoption,pof{o});
                    end
                end
            end
        else
            method = specif.eachchunk;
        end

        d2 = d;
        d2.method = method;
        y = {};
        for i = 1:size(chunks,2)
            disp([meth,num2str(i),'/',num2str(nch),'...'])
            d2 = set(d2,'Chunk',[chunks(1,i) chunks(2,i) (i == size(chunks,2))]);
            
            if not(ischar(specif.eachchunk) && ...
                   strcmpi(specif.eachchunk,'Normal'))
               if frnochunk
                   d2.postoption = 0;
               else
                    diffchunks = diff(chunks); % Usual chunk size
                    d2.postoption = max(diffchunks) -  diffchunks(i);
                        % Reduction of the current chunk size to be taken into
                        % consideration in mirspectrum, for instance, using
                        % zeropadding
               end
            end
            
            d2 = set(d2,'InterChunk',tmp);
            d2.chunkdecomposed = 1;

            [ss d3] = evalnow(d2);
            
            if iscell(ss) && not(isempty(ss))
                tmp = get(ss{1},'InterChunk');
            elseif isstruct(ss)
                tmp = [];
            else
                tmp = get(ss,'InterChunk');
            end
            
            % d2 is like d3 except that its argument is now evaluated.
            d3.postoption = d.postoption; % Pas joli joli
            d3.method = method;
            d2 = d3; % This new argument is transfered to d

            y = combinechunk_noframe(y,ss,sg,i,d2,chunks,single);

            clear ss
            if h
                if not(d.ascending)
                    close(h)
                    h = waitbar((chunks(1,i)-chunks(1,end))/chunks(2,1),...
                        ['Computing ' func2str(d.method) ' (backward)']);
                else
                    waitbar((chunks(2,i)-chunks(1))/chunks(end),h)
                end
            end
        end
        
        y = afterchunk_noframe(y,lsz,d,afterpostoption,d2);
        % Final operations to be executed after the chunk decomposition
                
        if isa(d,'mirstruct') && ...
                (isempty(d.frame) || isfield(d.frame,'dontchunk'))
            y = evalbranches(d,y);
        end
        if h
            close(h)
        end
        drawnow

    else 
        % No chunk decomposition
        [y d2] = evalnow(d);
        if isa(d,'mirstruct') && isfield(d.frame,'dontchunk')
            y = evalbranches(d,y);
        end
    end    
elseif d.nochunk
    [y d2] = evalnow(d);
else
    % Frame decomposition in the design to be evaluated.
    chunks = compute_frames(fr,sr,sr2,w,lsz,CHUNKLIM,d.overlap);
    if size(chunks,2)>1
        % The chunk decomposition is performed.
        if mirwaitbar
            h = waitbar(0,['Computing ' name]);
        else
            h = 0;
        end
        inter = [];
        d = set(d,'FrameDecomposition',1);
        d2 = d;
        nch = size(chunks,2);
        y = {};
        
        if frchunkbefore
            d2after = d2;
            d2.method = d2.argin.method;
            d2.option = d2.argin.option;
            d2.postoption = d2.argin.postoption;
            d2.argin = d2.argin.argin;
        end
        
        for fri = 1:nch     % For each chunk...
            disp(['Chunk ',num2str(fri),'/',num2str(nch),'...'])
            d2 = set(d2,'Chunk',chunks(:,fri)');
            d2 = set(d2,'InterChunk',inter);
            %d2.postoption = [];
            [res d2] = evalnow(d2);
            if not(isempty(res))
                if iscell(res)
                    inter = get(res{1},'InterChunk');
                elseif not(isstruct(res))
                    inter = get(res,'InterChunk');
                    res = {res};
                end
            end
            
            y = combinechunk_frame(y,res,d2,fri);
            if h
                waitbar(chunks(2,fri)/chunks(end),h);
            end
        end
        
        if frchunkbefore
            y = d2after.method(y,d2after.option,d2after.postoption);
        end
        
        if isa(d,'mirstruct') && get(d,'Stat') 
            y = mirstat(y);
        end
        if h
            close(h)
        end
    else
        % No chunk decomposition
        [y d2] = evalnow(d);
    end
end

 
if iscell(y)
    for i = 1:length(y)
        if not(isempty(y{i}) || isstruct(y{i}))
            if iscell(y{i})
                for j = 1:length(y{i})
                    y{i}{j} = set(y{i}{j},'InterChunk',[]);
                end
            else
                y{i} = set(y{i},'InterChunk',[]);
            end
        end
    end
end


function chunks = compute_frames(fr,sr,sr2,w,lsz,CHUNKLIM,frov)
if strcmpi(fr.length.unit,'s')
    fl = fr.length.val*sr;
    fl2 = fr.length.val*sr2;
elseif strcmpi(fr.length.unit,'sp')
    fl = fr.length.val;
    fl2 = fl;
end
if strcmpi(fr.hop.unit,'/1')
    h = fr.hop.val*fl;
    h2 = fr.hop.val*fl2;
elseif strcmpi(fr.hop.unit,'%')
    h = fr.hop.val*fl*.01;
    h2 = fr.hop.val*fl2*.01;
elseif strcmpi(fr.hop.unit,'s')
    h = fr.hop.val*sr;
    h2 = fr.hop.val*sr2;
elseif strcmpi(fr.hop.unit,'sp')
    h = fr.hop.val;
    h2 = fr.hop.val;
elseif strcmpi(fr.hop.unit,'Hz')
    h = sr/fr.hop.val;
    h2 = sr2/fr.hop.val;
end
n = floor((lsz-fl)/h)+1;   % Number of frames
if n < 1
    %warning('WARNING IN MIRFRAME: Frame length longer than total sequence size. No frame decomposition.');
    fp = w;
    fp2 = (w-1)/sr*sr2+1;
else
    st = floor(((1:n)-1)*h)+w(1);
    st2 = floor(((1:n)-1)*h2)+w(1);
    fp = [st; floor(st+fl-1)];
    fp(:,fp(2,:)>w(2)) = [];
    fp2 = [st2; floor(st2+fl2-1)];
    fp2(:,fp2(2,:)>(w(2)-w(1))/sr*sr2+w(2)) = [];
end
fpe = (fp2-1)/sr2-(fp-1)/sr; %Rounding error if resampling
fpsz = (fp(2,1)-fp(1,1)) * n;      % Total number of samples
fpsz2 = (fp2(2,1)-fp2(1,1)) * n;      % Total number of samples
if max(fpsz,fpsz2) > CHUNKLIM
    % The required memory exceed the max memory threshold.
    nfr = size(fp,2);                     % Total number of frames
    frch = max(ceil(CHUNKLIM/(fp(2,1)-fp(1,1))),2); % Number of frames per chunk
    frch = max(frch,frov*2);
    nch = ceil((nfr-frch)/(frch-frov))+1; % Number of chunks
    chbeg = (frch-frov)*(0:nch-1)+1;    % First frame in the chunk
    chend = (frch-frov)*(0:nch-1)+frch; % Last frame in the chunk
    chend = min(chend,nfr);
    if chend(end) == chbeg(end)
        lszend = fp(2,end)-fp(1,end)+1;  % Size of last chunk
        nend = floor((lszend-fl)/h)+1;   % Number of frames in the last chunk
        if nend < 2 % Last chunk is too short (only one frame),
            chend(end-1) = chend(end); % concatenated to previous one.
            chbeg(end) = [];
            chend(end) = [];
        end
    end
    if frov > 1 % If case of overlap
        chbeg = chend-frch+1;
    end
    chunks = [fp(1,chbeg) ; fp(2,chend)+1]; % After resampling, one sample may be missing, leading to a complete frame drop.
    chunks(end) = min(chunks(end),fp(end)); % Last chunk should not extend beyond audio size.
else
    chunks = [];
end


function res = combinechunk_frame(old,new,d2,fri)
if isempty(mirgetdata(new))
    res = old;
    return
end
if isstruct(old)
    f = fields(old);
    for i = 1:length(f)
        res.(f{i}) = combinechunk_frame(old.(f{i}),new.(f{i}),d2,fri);
    end
    return
end
if fri == 1
    res = new;
else
    res = combineframes(old,new);
end


function res = combinechunk_noframe(old,new,sg,i,d2,chunks,single)
if isempty(new)
    res = {};
    return
end
if isempty(mirgetdata(new))
    res = old;
    return
end
if not(iscell(new))
    new = {new};
end
if not(iscell(old))
    old = {old};
end
if not(isempty(old)) && isstruct(old{1})
    f = fields(old{1});
    for j = 1:length(f)
        index.type = '.';
        index.subs = f{j};
        res.(f{j}) = combinechunk_noframe(old{1}.(f{j}),new{1}.(f{j}),...
                                    sg,i,subsref(d2,index),chunks,single);
    end
    return
end
if ischar(single) && not(isempty(old))
    old = {old{1}};
end
if isempty(sg)
    if isaverage(d2.specif)
        % Measure total size for later averaging
        if iscell(new)
            new1 = new{1};
        else
            new1 = new;
        end
        dnew = get(new1,'Data');
        dnew = mircompute(@multweight,dnew,chunks(2,i)-chunks(1,i)+1);
        if iscell(new)
            new{1} = set(new1,'Data',dnew);
        else
            new = set(new1,'Data',dnew);
        end
    end
    %tmp = get(new{1},'InterChunk');
    if not(isempty(d2.tmpfile)) && d2.tmpfile.fid > 0
        % If temporary file is used, chunk results are written
        % in the file
        if i < size(chunks,2)
            ds = get(new{1},'Data');
            ps = get(new{1},'Pos');
           % ftell(d2.tmpfile.fid)
            count = fwrite(d2.tmpfile.fid,ds{1}{1},'double');
            count = fwrite(d2.tmpfile.fid,ps{1}{1},'double');
           % ftell(d2.tmpfile.fid)
            clear ds ps
        end
        res = new;
    else
        % Else, chunk results are directly combined in active
        % memory
        if i == 1
            res = new;
        else
            if isfield(d2.specif,'combinechunk')
                if not(iscell(d2.specif.combinechunk))
                    method = {d2.specif.combinechunk};
                else
                    method = d2.specif.combinechunk;
                end
                for z = 1:length(old)
                    if isframed(old{z})
                        res(z) = combineframes(old{z},new{z});
                    elseif ischar(method{z})
                        if strcmpi(method{z},'Concat')
                            res{z} = concatchunk(old{z},new{z},d2.ascending);
                        elseif strcmpi(method{z},'Average')
                            res{z} = sumchunk(old{z},new{z});
                        else
                            error(['SYNTAX ERROR: ',...
                                method{z},...
                        ' is not a known keyword for combinechunk.']);
                        end
                    else
                        res{z} = method{z}(old{z},new{z});
                    end
                end
            else
                for z = 1:length(old)
                    if isframed(old{z})
                        res(z) = combineframes(old{z},new{z});
                    else
                        mirerror('MIREVAL','Chunk recombination in non-framed mode is not available for all features yet. Please turn off the chunk decomposition.');
                    end
                end
            end
        end
    end
else
    if i == 1
        res = new;
    else
        for z = 1:length(old)
            res{z} = combinesegment(old{z},new{z});
        end
    end
end


function data = afterchunk_noframe(data,lsz,d,afterpostoption,d2)
if isstruct(data)
    return
end
if isfield(d2.specif,'afterchunk')
    data{1} = d2.specif.afterchunk(data{1},lsz,d.postoption);
elseif isaverage(d2.specif)
    data{1} = divideweightchunk(data{1},lsz);
elseif not(isempty(afterpostoption)) && isempty(d2.tmpfile)
    data{1} = d.method(data{1},[],afterpostoption);
end
if not(isempty(d2.tmpfile))
    adr = ftell(d2.tmpfile.fid);
    fclose(d2.tmpfile.fid);
    ytmpfile.fid = fopen('tmpfile.mirtoolbox');
    fseek(ytmpfile.fid,adr,'bof');
    ytmpfile.data = data{1};
    ytmpfile.layer = 0;
    data{1} = set(data{1},'TmpFile',ytmpfile);
end
            

function old = combineframes(old,new)
if not(iscell(old))
    old = {old};
end
if not(iscell(new))
    new = {new};
end
for var = 1:length(new)
    ov = old{var};
    nv = new{var};
    if isa(ov,'mirscalar')
        ov = combinedata(ov,nv,'Data');
        ov = combinedata(ov,nv,'Mode');
        if isa(ov,'MIRPITCH')
            ov = combinedata(ov,nv,'Amplitude');
        end
    else
        if isa(ov,'mirtemporal')
            [ov omatch nmatch] = combinedata(ov,nv,'Time',[],[],@modiftime);
        else
            [ov omatch nmatch] = combinedata(ov,nv,'Pos',[],[]);
            if isa(ov,'mirspectrum')
                [ov omatch nmatch] = combinedata(ov,nv,'Phase',[],[]);
            end
        end
        ov = combinedata(ov,nv,'Data',omatch,nmatch);
    end
    ov = combinedata(ov,nv,'FramePos');
    ov = combinedata(ov,nv,'PeakPos');
    ov = combinedata(ov,nv,'PeakVal');
    ov = combinedata(ov,nv,'PeakMode');
    old{var} = ov;
end


function [ov omatch nmatch] = combinedata(ov,nv,key,omatch,nmatch,modifdata)
if isstruct(ov)
    omatch = [];
    nmatch = [];
    f = fields(ov);
    for i = 1:length(f)
        ov.(f{i}) = combinedata(ov.(f{i}),nv.(f{i}),key);
    end
    return
end
odata = get(ov,key);
if isempty(odata) || isempty(odata{1})
    return
end
odata = odata{1};
if iscell(odata)
    if ischar(odata{1})
        return
    else
        odata = odata{1};
    end
end
ndata = get(nv,key);
ndata = ndata{1};
if iscell(ndata)
    ndata = ndata{1};
end
if nargin>3 
    if isempty(omatch)
        ol = size(odata,1);
        nl = size(ndata,1);
        unmatch = ol-nl;
        if unmatch>0
            [unused idx] = min(odata(1:1+unmatch,1,1)-ndata(1));
            omatch = idx:idx+nl-1;
            nmatch = 1:nl;
        elseif unmatch<0
            [unused idx] = min(ndata(1:1-unmatch,1,1)-odata(1));
            nmatch = idx:idx+ol-1;
            omatch = 1:ol;
        else
            nmatch = 1:nl;
            omatch = 1:ol;
        end       
    end
    odata(omatch,end+1:end+size(ndata,2),:,:) = ndata(nmatch,:,:,:); %4.D for keysom
else
    odata(:,end+1:end+size(ndata,2),:,:) = ndata;
end
ov = set(ov,key,{{odata}});  %{odata} for warped chromagram for instance....


function d = modiftime(d,p)
d = d + p;


function [y d] = evalnow(d)
% Go one step further in the top-down evaluation initialisation
argin = d.argin;
if not(iscell(argin))
    argin = {argin};
end
for i = 1:length(argin)
    a = argin{i};
    if not(d.ascending)
        a.ascending = 0;
    end
    if isa(a,'mirdata')
        % Input already computed
        tmpfile = get(a,'TmpFile');
        if not(isempty(tmpfile)) && tmpfile.fid > 0
            % The input can be read from the temporary file
            ch = get(d,'Chunk');
            a = tmpfile.data;
            a = set(a,'InterChunk',get(d,'InterChunk'),'TmpFile',tmpfile);
            channels = get(a,'Channels');
            channels = length(channels{1});
            if not(channels)
                channels = 1;
            end
            size = (ch(2)-ch(1)+1);
            current = ftell(tmpfile.fid);
            fseek(tmpfile.fid,current-size*(channels+1)*8,'bof');
            %ftell(tmpfile.fid)
            [data count] = fread(tmpfile.fid,[size,channels],'double');
            %count
            data = reshape(data,[size,1,channels]);
            [pos count] = fread(tmpfile.fid,size,'double');
            %count
           % ftell(tmpfile.fid)
            fseek(tmpfile.fid,current-size*(channels+1)*8,'bof');
            a = set(a,'Data',{{data}},'Pos',{{pos}});
            if ch(3)
                fclose(tmpfile.fid);
                delete('tmpfile.mirtoolbox');
            end
            argin{i} = a;
        end
    elseif isa(a,'mirdesign')
        if isempty(a.stored)
            % The design parameters are transfered to the previous component
            % in the design process
            a.size = d.size;
            a.chunk = d.chunk;
            a.file = d.file;
            a.channel = d.channel;
            a.scale = d.scale;
            a.eval = 1;
            a.interchunk = d.interchunk;
            a.sampling = d.sampling;
            if isstruct(d.frame) && isfield(d.frame,'decomposition') ...
                                 && not(isempty(d.frame.decomposition))
                a.chunkdecomposed = 1;
            else
                a.chunkdecomposed = d.chunkdecomposed;
            end
            if not(isempty(d.frame)) && ...
               not(strcmp(func2str(d.method),'mirframe'))
                a.frame = d.frame;
            end
            a.ready = 1;
            a.acrosschunks = d.acrosschunks;
            a.index = d.index;
            argin{i} = a;
        else
            % Variable already calculated
            tmp = get(d,'Struct');
            if not(isempty(tmp))
                for j = 1:length(a.stored) % (if modified, modify also mirframe)
                    stored = a.stored{j};
                    if iscell(stored)
                        if length(stored)>1
                            tmp = tmp{stored{1},stored{2}};
                        else
                            tmp = tmp{stored{1}};
                        end
                    else
                        tmp = getfield(tmp,stored);
                    end
                end
                if iscell(tmp)
                    tmp = tmp{1};
                end
            else
                mirerror('evaleach','THERE is a problem..');
            end
            argin{i} = tmp;
        end
    end
end
if not(iscell(d.argin))
    argin = argin{1};
end
d.option.struct = get(d,'Struct');
if iscell(d.postoption)
    [y argin] = d.method(argin,d.option,d.postoption{:});
else
    [y argin] = d.method(argin,d.option,d.postoption);
end
d = set(d,'Argin',argin);
if isa(d,'mirstruct') && not(isfield(d.frame,'dontchunk')) && isempty(get(d,'Chunk'))
    y = evalbranches(d,y);
end


function z = evalbranches(d,y)
% For complex flowcharts, now that the first temporary variable (y) has been
% computed, the dependent features (d) should be evaluated as well.
branch = get(d,'Data');

for i = 1:length(branch)
    if isa(branch{i},'mirdesign') && get(branch{i},'NoChunk') == 1 
                                        % if the value is 2, it is OK.
        %mirerror('mireval','Flowchart badly designed: mirstruct should not be used if one or several final variables do not accept chunk decomposition.');
    end
end

fields = get(d,'Fields');
z = struct;
tmp = get(d,'Tmp');
for i = 1:length(branch)
    z.(fields{i}) = evalbranch(branch{i},tmp,y);
end
if get(d,'Stat') && isempty(get(d,'Chunk'))
    z = mirstat(z,'FileNames',0);
end


function b = evalbranch(b,d,y)
% We need to evaluate the branch reaching the current node (b) from the parent 
% corresponding to the temporary variable (d),

if iscell(b)
    mirerror('MIREVAL','Sorry, forked branching of temporary variable cannnot be evaluated in current version of MIRtoolbox.');
end
if isstruct(b)
    % Subtrees are evaluated branch after branch.
    f = fields(b);
    for i = 1:length(f)
        b.(f{i}) = evalbranch(b.(f{i}),d,y);
    end
    return
end
if isequal(b,d)
    %% Does it happen ever??
    b = y;
    return
end
if not(isa(b,'mirdesign'))
    mirerror('MIRSTRUCT','In the mirstruct object you defined, the final output should only depend on ''tmp'' variables, and should not therefore reuse the ''Design'' keyword.');
end
v = get(b,'Stored');
if length(v)>1 && ischar(v{2})
    % 
    f = fields(d);
    for i = 1:length(f)
        if strcmpi(v{2},f)
            b = y; % OK, now the temporary variable has been found.
                   % End of recursion.
            return
        end
    end
end

argin = evalbranch(get(b,'Argin'),d,y); % Recursion one parent up

% The operation corresponding to the branch from the parent to the node
% is finally evaluated.
if iscell(b.postoption)
    b = b.method(argin,b.option,b.postoption{:});
else
    b = b.method(argin,b.option,b.postoption);
end


function res = isaverage(specif)
res = isfield(specif,'combinechunk') && ...
        ((ischar(specif.combinechunk) && ...
          strcmpi(specif.combinechunk,'Average')) || ...
         (iscell(specif.combinechunk) && ...
          ischar(specif.combinechunk{1}) && ...
          strcmpi(specif.combinechunk{1},'Average')));
      

function d0 = callbeforechunk(d0,d,w,lsz)
% If necessary, the chunk decomposition is performed a first time for
% initialisation purposes.
% Currently used only for miraudio(...,'Normal')
if not(ischar(d)) && not(iscell(d))
    specif = d.specif;
    CHUNKLIM = mirchunklim;
    nch = ceil(lsz/CHUNKLIM); 
    if isfield(specif,'beforechunk') ...
            && ((isfield(d.option,specif.beforechunk{2}) ...
                    && d.option.(specif.beforechunk{2})) ...
             || (isfield(d.postoption,specif.beforechunk{2}) ...
                    && d.postoption.(specif.beforechunk{2})) )
        if mirwaitbar
            h = waitbar(0,['Preparing ' func2str(d.method)]);
        else
            h = 0;
        end
        for i = 1:nch
            disp(['Chunk ',num2str(i),'/',num2str(nch),'...'])
            chbeg = CHUNKLIM*(i-1);
            chend = CHUNKLIM*i-1;
            d2 = set(d,'Size',d0.size,'File',d0.file,...
                       'Chunk',[chbeg+w(1) min(chend,lsz-1)+w(1)]);
            d2.method = specif.beforechunk{1};
            d2.postoption = {chend-lsz};
            d2.chunkdecomposed = 1;
            [tmp d] = evalnow(d2);
            d0 = set(d0,'AcrossChunks',tmp);
            if h
                waitbar(chend/lsz,h)
            end
        end
        if h
            close(h);
        end
        drawnow
    else
        d0 = callbeforechunk(d0,d.argin,w,lsz);
    end
end


function y = concatchunk(old,new,ascending)
do = get(old,'Data');
dn = get(new,'Data');
fpo = get(old,'FramePos');
fpn = get(new,'FramePos');
if isa(old,'mirscalar')
    y = set(old,'Data',{{[do{1}{1},dn{1}{1}]}},...
                'FramePos',{{[fpo{1}{1},fpn{1}{1}]}});
else
    to = get(old,'Pos');
    tn = get(new,'Pos');
    if ascending
        y = set(old,'Data',{{[do{1}{1};dn{1}{1}]}},...
                    'Pos',{{[to{1}{1};tn{1}{1}]}},...
                    'FramePos',{{[fpo{1}{1},fpn{1}{1}]}});
    else
        y = set(old,'Data',{{[dn{1}{1};do{1}{1}]}},...
                    'Pos',{{[tn{1}{1};to{1}{1}]}},...
                    'FramePos',{{[fpo{1}{1},fpn{1}{1}]}});
    end
end


function y = combinesegment(old,new)
do = get(old,'Data');
to = get(old,'Pos');
fpo = get(old,'FramePos');
ppo = get(old,'PeakPos');
pppo = get(old,'PeakPrecisePos');
pvo = get(old,'PeakVal');
ppvo = get(old,'PeakPreciseVal');
pmo = get(old,'PeakMode');
apo = get(old,'AttackPos');
rpo = get(old,'ReleasePos');
tpo = get(old,'TrackPos');
tvo = get(old,'TrackVal');

dn = get(new,'Data');
tn = get(new,'Pos');
fpn = get(new,'FramePos');
ppn = get(new,'PeakPos');
pppn = get(new,'PeakPrecisePos');
pvn = get(new,'PeakVal');
ppvn = get(new,'PeakPreciseVal');
pmn = get(new,'PeakMode');
apn = get(new,'AttackPos');
rpn = get(new,'ReleasePos');
tpn = get(new,'TrackPos');
tvn = get(new,'TrackVal');

y = old;

if not(isempty(do))
    y = set(y,'Data',{{do{1}{:},dn{1}{:}}});
end

y = set(y,'FramePos',{{fpo{1}{:},fpn{1}{:}}}); 
        
if not(isempty(to)) && size(do{1},2) == size(to{1},2)
    y = set(y,'Pos',{{to{1}{:},tn{1}{:}}}); 
end

if not(isempty(ppo))
    y = set(y,'PeakPos',{{ppo{1}{:},ppn{1}{:}}},...
                'PeakVal',{{pvo{1}{:},pvn{1}{:}}},...
                'PeakMode',{{pmo{1}{:},pmn{1}{:}}});
end

if not(isempty(pppn))
    y = set(y,'PeakPrecisePos',{[pppo{1},pppn{1}{1}]},...
                'PeakPreciseVal',{[ppvo{1},ppvn{1}{1}]});
end

if not(isempty(apn))
    y = set(y,'AttackPos',{[apo{1},apn{1}{1}]});
end

if not(isempty(rpn))
    y = set(y,'ReleasePos',{[rpo{1},rpn{1}{1}]});
end

if not(isempty(tpn))
    y = set(y,'TrackPos',{[tpo{1},tpn{1}{1}]});
end

if not(isempty(tvn))
    y = set(y,'TrackVal',{[tvo{1},tvn{1}{1}]});
end

if isa(old,'miremotion')
    deo = get(old,'DimData');
    ceo = get(old,'ClassData');
    den = get(new,'DimData');
    cen = get(new,'ClassData');
    afo = get(old,'ActivityFactors');
    vfo = get(old,'ValenceFactors');
    tfo = get(old,'TensionFactors');
    hfo = get(old,'HappyFactors');
    sfo = get(old,'SadFactors');
    tdo = get(old,'TenderFactors');
    ago = get(old,'AngerFactors');
    ffo = get(old,'FearFactors');
    afn = get(new,'ActivityFactors');
    vfn = get(new,'ValenceFactors');
    tfn = get(new,'TensionFactors');
    hfn = get(new,'HappyFactors');
    sfn = get(new,'SadFactors');
    tdn = get(new,'TenderFactors');
    agn = get(new,'AngerFactors');
    ffn = get(new,'FearFactors');
    y = set(y,'DimData',{[deo{1},den{1}{1}]},...
            'ClassData',{[ceo{1},cen{1}{1}]},...
            'ActivityFactors',{[afo{1},afn{1}{1}]},...
            'ValenceFactors',{[vfo{1},vfn{1}{1}]},...
            'TensionFactors',{[tfo{1},tfn{1}{1}]},...
            'HappyFactors',{[hfo{1},hfn{1}{1}]},...
            'SadFactors',{[sfo{1},sfn{1}{1}]},...
            'TenderFactors',{[tdo{1},tdn{1}{1}]},...
            'AngerFactors',{[ago{1},agn{1}{1}]},...
            'FearFactors',{[ffo{1},ffn{1}{1}]}...
        );
end
 

function y = sumchunk(old,new,order)
%do = mirgetdata(old);
%dn = mirgetdata(new);
do = get(old,'Data');
do = do{1}{1};
dn = get(new,'Data');
dn = dn{1}{1};
y = set(old,'ChunkData',do+dn);
        

function y = divideweightchunk(orig,length)
d = get(orig,'Data');
if isempty(d)
    y = orig;
else
    v = mircompute(@divideweight,d,length);
    y = set(orig,'Data',v);
end

function e = multweight(d,length)
e = d*length;

function e = divideweight(d,length)
e = d/length;