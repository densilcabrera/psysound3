function [f,p,m,fe] = mirsegment(x,varargin)
%   f = mirsegment(a) segments an audio signal. It can also be the name of an
%       audio file or 'Folder', for the analysis of the audio files in the
%       current folder. The segmentation of audio signal already decomposed
%       into frames is not available for the moment.
%   f = mirsegment(...,'Novelty') segments using a self-similarity matrix
%           (Foote & Cooper, 2003)     (by default)
%       f = mirsegment(...,feature) bases the segmentation strategy on a
%           specific feature.
%           'Spectrum': from FFT spectrum (by default)
%           'MFCC': from MFCCs
%           'Keystrength': from the key strength profile
%           'AutocorPitch': from the autocorrelation function computed as
%               for pitch extraction.
%           The option related to this feature extraction can be specified.
%           Example: mirsegment(...,'Spectrum','Window','bartlett')
%                    mirsegment(...,'MFCC','Rank',1:10)
%                    mirsegment(...,'Keystrength','Weight',.5)
%       These feature need to be frame-based, in order to appreciate their
%           temporal evolution. Therefore, the audio signal x is first
%           decomposed into frames. This decomposition can be controled
%           using the 'Frame' keyword.  
%       The options available for the chosen strategies can be specified
%           directly as options of the segment function.
%           Example: mirsegment(a,'Novelty','KernelSize',10)
%   f = mirsegment(...,'HCDF') segments using the Harmonic Change Detection  
%           Function (Harte & Sandler, 2006)
%   f = mirsegment(...,'RMS') segments at positions of long silences. A
%       frame decomposed RMS is computed using mirrms (with default
%       options), and segments are selected from temporal positions
%       where the RMS rises to a given 'On' threshold, until temporal
%       positions where the RMS drops back to a given 'Off' threshold.
%       f = mirsegment(...,'Off',t1) specifies the RMS 'Off' threshold.
%           Default value: t1 = .01
%       f = mirsegment(...,'On',t2) specifies the RMS 'On' threshold.
%           Default value: t2 = .02
%
%   f = mirsegment(a,s) segments a using the results of a segmentation
%       analysis s. s can be the peaks detected on an analysis of the
%       audio for instance.
%
%   f = mirsegment(a,v) where v is an array of numbers, segments a using
%       the temporal positions specified in v (in s.)
%
%   Foote, J. & Cooper, M. (2003). Media Segmentation using Self-Similarity
%       Decomposition,. In Proc. SPIE Storage and Retrieval for Multimedia
%       Databases, Vol. 5021, pp. 167-75.
%   Harte, C. A. & Sandler, M. B. (2006). Detecting harmonic change in
%       musical audio, in Proceedings of Audio and Music Computing for 
%       Multimedia Workshop, Santa Barbara, CA.


%   [f,p] = mirsegment(...) also displays the analysis produced by the chosen
%       strategy.
%           For 'Novelty', p is the novelty curve.
%           For 'HCDF', p is the Harmonic Change Detection Function.
%   [f,p,m] = mirsegment(...) also displays the preliminary analysis
%       undertaken in the chosen strategy.
%           For 'Novelty', m is the similarity matrix.
%           For 'HCDF', m is the tonal centroid.
%   [f,p,m,fe] = mirsegment(...) also displays the temporal evolution of the
%       feature used for the analysis.
 
%   f = mirsegment(...,'Novelty')

        mfc.key = {'Rank','MFCC'};
        mfc.type = 'Integers';
        mfc.default = 0;
        mfc.keydefault = 1:13;
    option.mfc = mfc;

        K.key = 'KernelSize';
        K.type = 'Integer';
        K.default = 128;
    option.K = K;
    
        distance.key = 'Distance';
        distance.type = 'String';
        distance.default = 'cosine';
    option.distance = distance;

        measure.key = {'Measure','Similarity'};
        measure.type = 'String';
        measure.default = 'exponential';
    option.measure = measure;

        tot.key = 'Total';
        tot.type = 'Integer';
        tot.default = Inf;
    option.tot = tot;

        cthr.key = 'Contrast';
        cthr.type = 'Integer';
        cthr.default = .1;
    option.cthr = cthr;

        frame.key = 'Frame';
        frame.type = 'Integer';
        frame.number = 2;
        frame.default = [0 0];
        frame.keydefault = [3 .1];
    option.frame = frame;

        ana.type = 'String';
        ana.choice = {'Spectrum','Keystrength','AutocorPitch','Pitch'};
        ana.default = 0;
    option.ana = ana;
    
%       f = mirsegment(...,'Spectrum')    
    
            band.choice = {'Mel','Bark','Freq'};
            band.type = 'String';
            band.default = 'Freq';
        option.band = band;

            mi.key = 'Min';
            mi.type = 'Integer';
            mi.default = 0;
        option.mi = mi;

            ma.key = 'Max';
            ma.type = 'Integer';
            ma.default = 0;
        option.ma = ma;

            norm.key = 'Normal';
            norm.type = 'Boolean';
            norm.default = 0;
        option.norm = norm;

            win.key = 'Window';
            win.type = 'String';
            win.default = 'hamming';
        option.win = win;
    
%       f = mirsegment(...,'Silence')    
    
            throff.key = 'Off';
            throff.type = 'Integer';
            throff.default = .01;
        option.throff = throff;

            thron.key = 'On';
            thron.type = 'Integer';
            thron.default = .02;
        option.thron = thron;

        strat.choice = {'Novelty','HCDF','RMS'}; % should remain as last field
        strat.default = 'Novelty';
        strat.position = 2;
    option.strat = strat;
   
specif.option = option;


p = {};
m = {};
fe = {};

if isa(x,'mirdesign')
    if not(get(x,'Eval'))
        % During bottom-up construction of the general design

        [unused option] = miroptions(@mirframe,x,specif,varargin);
        type = get(x,'Type');
        f = mirdesign(@mirsegment,x,option,{},struct,type);
        
        sg = get(x,'Segment');
        if not(isempty(sg))
            f = set(f,'Segment',sg);
        else
            f = set(f,'Segment',option.strat);
        end
        
    else
        % During top-down evaluation initiation
        
        f = evaleach(x);
        if iscell(f)
            f = f{1};
        end
        p = x;
    end
elseif isa(x,'mirdata')
    [unused option] = miroptions(@mirframe,x,specif,varargin);
    if ischar(option.strat)
        dx = get(x,'Data');
        if size(dx{1},2) > 1
            error('ERROR IN MIRSEGMENT: The segmentation of audio signal already decomposed into frames is not available for the moment.');
        end
        if strcmpi(option.strat,'Novelty')
            if not(option.frame.length.val)
                if strcmpi(option.ana,'Keystrength')
                    option.frame.length.val = .5;
                    option.frame.hop.val = .2;
                elseif strcmpi(option.ana,'AutocorPitch') ...
                        || strcmpi(option.ana,'Pitch')
                    option.frame.length.val = .05;
                    option.frame.hop.val = .01;
                else
                    option.frame.length.val = .05;
                    option.frame.hop.val = 1;
                end
            end
            fr = mirframenow(x,option);
            if 0 %not(isequal(option.mfc,0)) % not in Matlab Central version
                fe = mirmfcc(fr,'Rank',option.mfc);
            elseif strcmpi(option.ana,'Spectrum')
                fe = mirspectrum(fr,'Min',option.mi,'Max',option.ma,...
                                    'Normal',option.norm,option.band,...
                                    'Window',option.win);
            elseif strcmpi(option.ana,'Keystrength')
                    fe = mirkeystrength(fr);
            elseif strcmpi(option.ana,'AutocorPitch') ...
                    || strcmpi(option.ana,'Pitch')
                [unused,fe] = mirpitch(x,'Frame');
            else
                fe = fr;
            end
            [n m] = mirnovelty(fe,'Distance',option.distance,...
                                  'Measure',option.measure,...
                                  'KernelSize',option.K);
            p = mirpeaks(n,'Total',option.tot,...
                           'Contrast',option.cthr,...
                           'Chrono','NoBegin','NoEnd');
        elseif strcmpi(option.strat,'HCDF')
            if not(option.frame.length.val)
                option.frame.length.val = .743;
                option.frame.hop.val = 1/8;
            end
            fr = mirframenow(x,option);
            %[df m fe] = mirhcdf(fr);
            df = mirhcdf(fr);
            p = mirpeaks(df);
        elseif strcmpi(option.strat,'RMS')
            if not(option.frame.length.val)
                option.frame.length.val = .05;
                option.frame.hop.val = .5;
            end
            fr = mirframenow(x,option);
            %[df m fe] = mirhcdf(fr);
            df = mirrms(fr);
            fp = get(df,'FramePos');
            p = mircompute(@findsilence,df,fp,option.throff,option.thron);
        end
        f = mirsegment(x,p);
    else
        dx = get(x,'Data');
        dt = get(x,'Time');

        if isa(option.strat,'mirscalar')
            ds = get(option.strat,'PeakPos');
            fp = get(option.strat,'FramePos');
        elseif isa(option.strat,'mirdata')
            ds = get(option.strat,'AttackPos');
            if isempty(ds) || isempty(ds{1})
                ds = get(option.strat,'PeakPos');
            end
            xx = get(option.strat,'Pos');
        else
            ds = option.strat;
            fp = cell(1,length(dx));
        end
        st = cell(1,length(dx));
        sx = cell(1,length(dx));
        cl = cell(1,length(dx));
        for k = 1:length(dx)
            dxk = dx{k}{1}; % values in kth audio file
            dtk = dt{k}{1}; % time positions in kth audio file
            if isa(option.strat,'mirdata')
                dsk = ds{k}{1}; % segmentation times in kth audio file
            else
                dsk = {ds};
            end
            fsk = [];   % the structured array of segmentation times 
                         % needs to be flatten
            for j = 1:length(dsk)
                if isa(option.strat,'mirdata')
                    dsj = dsk{j}; % segmentation times in jth segment
                else
                    dsj = ds;
                end
                if not(iscell(dsj))
                    dsj = {dsj};
                end
                for m = 1:length(dsj)
                    % segmentation times in mth bank channel
                    if isa(option.strat,'mirscalar')
                        dsm = mean(fp{k}{m}(:,dsj{m}));
                    elseif isa(option.strat,'mirdata')
                        dsm = xx{k}{m}(dsj{m});
                    else
                        dsm = dsj{m};
                    end
                    if iscell(dsm)
                        dsm = dsm{1};
                    end
                    dsm(:,find(dsm(1,:) <= dtk(1))) = [];
                    dsm(:,find(dsm(end,:) >= dtk(end))) = [];
                    % It is presupposed here that the segmentations times
                    % for a given channel are not decomposed per frames,
                    % because the segmentation of the frame decomposition
                    % is something that does not seem very clear.
                    % Practically, the peak picking for instance is based 
                    % therefore on a frame analysis (such as novelty), and
                    % segmentation are inferred between these frames...
                    if size(dsm,2) == 1
                        dsm = dsm';
                    end
                    fsk = [fsk dsm];
                end
            end

            fsk = sort(fsk); % Here is the chronological ordering
            
            if isempty(fsk)
                ffsk = {[0;dtk(end)]};
                sxk = {dxk};
                stk = {dtk};
                n = 1;
            elseif size(fsk,1) == 1
                ffsk = cell(1,length(fsk)+1);
                ffsk{1} = [dtk(1);fsk(1)];
                for h = 1:length(fsk)-1
                    ffsk{h+1} = [fsk(h);fsk(h+1)];
                end
                ffsk{end} = [fsk(end);dtk(end)];
                
                n = length(ffsk);

                crd = zeros(1,n+1); % the sample positions of the
                                    % segmentations in the channel
                crd0 = 0;
                for i = 1:n
                    crd0 = crd0 + find(dtk(crd0+1:end)>=ffsk{i}(1),1);
                    crd(i) = crd0;
                end
                crd(n+1) = size(dxk,1)+1;

                sxk = cell(1,n); % each cell contains a segment
                stk = cell(1,n); % each cell contains
                                 % the corresponding time positions

                for i = 1:n
                    sxk{i} = dxk(crd(i):crd(i+1)-1,1,:);
                    stk{i} = dtk(crd(i):crd(i+1)-1);
                end

            elseif size(fsk,1) == 2
                ffsk = cell(1,size(fsk,2));
                for h = 1:length(fsk)
                    ffsk{h} = [fsk(1,h);fsk(2,h)];
                end
                n = length(ffsk);
                crd = zeros(2,n); % the sample positions of the
                                  % segmentations in the channel
                crd0 = 0;
                for i = 1:n
                    crd0 = crd0 + find(dtk(crd0+1:end)>=ffsk{i}(1),1);
                    crd(i,1) = crd0;
                    crd0 = crd0 + find(dtk(crd0+1:end)>=ffsk{i}(2),1);
                    crd(i,2) = crd0;                    
                end
                sxk = cell(1,n); % each cell contains a segment
                stk = cell(1,n); % each cell contains
                                 % the corresponding time positions
                for i = 1:n
                    sxk{i} = dxk(crd(i,1):crd(i,2),1,:);
                    stk{i} = dtk(crd(i,1):crd(i,2));
                end
            end
            sx{k} = sxk;
            st{k} = stk;
            fp{k} = ffsk;
            cl{k} = 1:n;
        end
        f = set(x,'Data',sx,'Time',st,'FramePos',fp,'Clusters',cl);
        p = strat;
        m = {};
        fe = {};
    end
else
    [f p] = mirsegment(miraudio(x),varargin{:});
end 


function p = findsilence(d,fp,throff,thron)
d = [0 d 0];
begseg = find(d(1:end-1)<thron & d(2:end)>=thron);
nseg = length(begseg);
endseg = zeros(1,nseg);
removed = [];
for i = 1:nseg
    endseg(i) = begseg(i) + find(d(begseg(i)+1:end)<=throff, 1)-1;
    if i>1 && endseg(i) == endseg(i-1)
        removed = [removed i];
    end
end
begseg(removed) = [];
%endseg(removed) = [];
%endseg(end) = min(endseg(end),length(d)+1);
p = fp(1,begseg); %; fp(2,endseg-1)];