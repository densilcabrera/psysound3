function varargout = mirpitch(orig,varargin)
%   p = mirpitch(x) evaluates the pitch frequencies (in Hz).
%   Specification of the method(s) for pitch estimation (these methods can
%       be combined):
%       mirpitch(...,'Autocor') computes an autocorrelation function
%           (Default method)
%           mirpitch(...'Enhanced',a) computes enhanced autocorrelation
%               (see help mirautocor)
%              toggled on by default
%           mirpitch(...,'Compress',k) performs magnitude compression
%               (see help mirautocor)
%           mirpitch(...,fb) specifies a type of filterbank.
%               Possible values:
%                   fb = 'NoFilterBank': no filterbank decomposition
%                   fb = '2Channels' (default value)
%                   fb = 'Gammatone' 
%       mirpitch(...,'AutocorSpectrum') computes the autocorrelation of
%           the FFT spectrum
%       mirpitch(...,'Cepstrum') computes the cepstrum
%       Alternatively, an autocorrelation or a cepstrum can be directly
%           given as first argument of the mirpitch function.
%   Peak picking options:
%       mirpitch(...,'Total',m) selects the m best pitches.
%           Default value: m = Inf, no limit is set concerning the number
%           of pitches to be detected.
%       mirpitch(...,'Mono') corresponds to morpitch(...,'Total',1)
%       mirpitch(...,'Min',mi) indicates the lowest frequency taken into
%           consideration.
%           Default value: 75 Hz. (Praat)
%       mirpitch(...,'Max',ma) indicates the highest frequency taken into
%           consideration. 
%           Default value: 2400 Hz. Because there seems to be some problems
%           with higher frequency, due probably to the absence of 
%           pre-whitening in our implementation of Tolonen and Karjalainen
%           approach (used by default, cf. below).
%       mirpitch(...,'Contrast',thr) specifies a threshold value.
%           (see help peaks)
%           Default value: thr = .1
%       mirpitch(...,'Order',o) specifies the ordering for the peak picking.
%           Default value: o = 'Amplitude'.
%       Alternatively, the result of a mirpeaks computation can be directly
%           given as first argument of the mirpitch function.
%   Post-processing options:
%       mirpitch(...,'Sum','no') does not sum back the channels at the end 
%           of the computation. The resulting pitch information remains
%           therefore decomposed into several channels.
%       mirpitch(...,'Median') performs a median filtering of the pitch
%           curve. When several pitches are extracted in each frame, the
%           pitch curve contains the best peak of each successive frame.
%       mirpitch(...,'Stable',th,n) remove pitch values when the difference 
%           (or more precisely absolute logarithmic quotient) with the
%           n precedent frames exceeds the threshold th. 
%           if th is not specified, the default value .1 is used
%           if n is not specified, the default value 3 is used
%       mirpitch(...'Reso',r) removes peaks whose distance to one or
%           several higher peaks is lower than a given threshold.
%           Possible value for the threshold r:
%               'SemiTone': ratio between the two peak positions equal to
%                   2^(1/12)
%       mirpitch(...,'Frame',l,h) orders a frame decomposition of window
%           length l (in seconds) and hop factor h, expressed relatively to
%           the window length. For instance h = 1 indicates no overlap.
%           Default values: l = 46.4 ms and h = 10 ms (Tolonen and
%           Karjalainen, 2000)
%   Preset model:
%       mirpitch(...,'Tolonen') implements (part of) the model proposed in
%           (Tolonen & Karjalainen, 2000). It is equivalent to
%           mirpitch(...,'Enhanced',2:10,'Generalized',.67,'2Channels')
%   [p,a] = mirpitch(...) also displays the result of the method chosen for
%       pitch estimation, and shows in particular the peaks corresponding
%       to the pitch values.
%   p = mirpitch(f,a,<r>) creates a mirpitch object based on the frequencies
%       specified in f and the related amplitudes specified in a, using a
%       frame sampling rate of r Hz (set by default to 100 Hz).
%
%   T. Tolonen, M. Karjalainen, "A Computationally Efficient Multipitch 
%       Analysis Model", IEEE TRANSACTIONS ON SPEECH AND AUDIO PROCESSING,
%       VOL. 8, NO. 6, NOVEMBER 2000



% The file has been modified for Psysound3 ,and for its parallell computing
% features. (3 properties added in the class : OptionStr, Frame and SpectrumType)
% Also the name of the class was changed (everywhere in Psysound3) into 'MIRPITCH' (instead of 'mirpitch')
% (This last modification is unuseful, but I had already written the class
% constructor for Psysound3 using 'MIRPITCH'when I realized errors occured because of that, so I renamed each
% 'mirpitch' into 'MIRPITCH') 
% Be aware of that if you want to add another algorithm from the MirToolbox
% into Psysound3


        ac.key = 'Autocor';
        ac.type = 'Boolean';
        ac.default = 0;
    option.ac = ac;
    
            enh.key = 'Enhanced';
            enh.type = 'Integer';
            enh.default = 2:10;
        option.enh = enh;

            filtertype.type = 'String';
            filtertype.choice = {'NoFilterBank','2Channels','Gammatone'};
            filtertype.default = '2Channels';
        option.filtertype = filtertype;

            gener.key = {'Generalized','Compress'};
            gener.type = 'Integer';
            gener.default = .5;
        option.gener = gener;

        as.key = 'AutocorSpectrum';
        as.type = 'Boolean';
        as.default = 0;
    option.as = as;
    
        s.key = 'Spectrum';
        s.type = 'Boolean';
        s.default = 0;
    option.s = s;
        
        ce.key = 'Cepstrum';
        ce.type = 'Boolean';
        ce.default = 0;
    option.ce = ce;
        
%% peak picking options

        m.key = 'Total';
        m.type = 'Integer';
        m.default = Inf;
    option.m = m;
    
        multi.key = 'Multi';
        multi.type = 'Boolean';
        multi.default = 0;
    option.multi = multi;

        mono.key = 'Mono';
        mono.type = 'Boolean';
        mono.default = 0;
    option.mono = mono;

        mi.key = 'Min';
        mi.type = 'Integer';
        mi.default = 75;
    option.mi = mi;
        
        ma.key = 'Max';
        ma.type = 'Integer';
        ma.default = 2400;
    option.ma = ma;
        
        thr.key = 'Contrast';
        thr.type = 'Integer';
        thr.default = .1;
    option.thr = thr;
    
        order.key = 'Order';
        order.type = 'String';
        order.choice = {'Amplitude','Abscissa'};
        order.default = 'Amplitude';
    option.order = order;    

        reso.key = 'Reso';
        reso.type = 'String';
        reso.choice = {0,'SemiTone'};
        reso.default = 0;
    option.reso = reso;
        
        track.key = 'Track';        % Not used yet
        track.type = 'Boolean';
        track.default = 0;
    option.track = track;

%% post-processing options
        
        stable.key = 'Stable';
        stable.type = 'Integer';
        stable.number = 2;
        stable.default = [Inf 0];
        stable.keydefault = [.1 3];
    option.stable = stable;
    
        median.key = 'Median';
        median.type = 'Integer';
        median.default = 0;
        median.keydefault = .1;
    option.median = median;
    
        frame.key = 'Frame';
        frame.type = 'Integer';
        frame.number = 2;
        frame.default = [0 0];
        frame.keydefault = [NaN NaN];
    option.frame = frame;

        sum.key = 'Sum';
        sum.type = 'Boolean';
        sum.default = 1;
    option.sum = sum;
    
%% preset model

        tolo.key = 'Tolonen';
        tolo.type = 'Boolean';
        tolo.default = 0;
    option.tolo = tolo;
    
specif.option = option;
specif.chunkframebefore = 1;

if isnumeric(orig)
    if nargin<3
        f = 100;
    else
        f = varargin{2};
    end
    fp = (0:size(orig,1)-1)/f;
    fp = [fp;fp+1/f];
    p.amplitude = {{varargin{1}'}};
% Modified for the needs of parallell computing features in Psysound3    
    
    p.Frame=[];
    p.SpectrumType='';
    s = mirscalar([],'Data',{{orig'}},'Title','Pitch','Unit','Hz',...
                     'FramePos',{{fp}},'Sampling',f,'Name',{inputname(1)});
    p = class(p,'MIRPITCH',s);
    varargout = {p};
else
    varargout = mirfunction(@mirpitch,orig,varargin,nargout,specif,@init,@main);
end



function [y type] = init(orig,option)
if option.tolo
    option.enh = 2:10;
    option.gener = .67;
    option.filtertype = '2Channels';
end
if not(option.ac) && not(option.as) && not(option.ce) && not(option.s)
    option.ac = 1;
end
if isnan(option.frame.length.val)
    option.frame.length.val = .0464;
end
if isnan(option.frame.hop.val)
    option.frame.hop.val = .01;
    option.frame.hop.unit = 's';
end
if isamir(orig,'mirscalar') || haspeaks(orig)
    y = orig;
else
    if isamir(orig,'mirautocor')
        y = mirautocor(orig,'Min',option.mi,'Hz','Max',option.ma,'Hz','Freq');
    elseif isamir(orig,'mircepstrum')
        y = orig;
    elseif isamir(orig,'mirspectrum')
        if not(option.as) && not(option.ce) && not(option.s)
            option.ce = 1;
        end
        if option.as
            y = mirautocor(orig,...
                            'Min',option.mi,'Hz','Max',option.ma,'Hz');
        end
        if option.ce
            ce = mircepstrum(orig,'freq',...
                            'Min',option.mi,'Hz','Max',option.ma,'Hz');
            if option.as
                y = y*ce;
            else
                y = ce;
            end
        end
    else
        if option.ac
            x = orig;
            if not(strcmpi(option.filtertype,'NoFilterBank'))
                x = mirfilterbank(x,option.filtertype);
            end
            x = mirframenow(x,option);
            y = mirautocor(x,'Generalized',option.gener,...
                                'Min',option.mi,'Hz','Max',option.ma,'Hz');
            if option.sum
                y = mirsummary(y);
            end
            y = mirautocor(y,'Enhanced',option.enh,'Freq');
        end
        if option.as || option.ce || option.s
            x = mirframenow(orig,option);
            y = mirspectrum(x);
            if option.as
                as = mirautocor(y,...
                                'Min',option.mi,'Hz','Max',option.ma,'Hz');
                if option.ac
                    y = y*as;
                else
                    y = as;
                end
            end
            if option.ce
                ce = mircepstrum(y,'freq',...
                                'Min',option.mi,'Hz','Max',option.ma,'Hz');
                if option.ac || option.as
                    y = y*ce;
                else
                    y = ce;
                end
            end
        end
    end
end
type = {'MIRPITCH',mirtype(y)};
    

function o = main(x,option,postoption)
if option.multi && option.m == 1
    option.m = Inf;
end
if option.mono && option.m == Inf
    option.m = 1;
end
if iscell(x)
    x = x{1};
end
if not(isa(x,'MIRPITCH'))
    x = mirpeaks(x,'Total',option.m,'Track',option.track,...
                   'Contrast',option.thr,'Threshold',.4,...
                   'Reso',option.reso,'NoBegin','NoEnd',...
                   'Order',option.order);
end
if isa(x,'mirscalar')
    pf = get(x,'Data');
else
    pf = get(x,'PeakPrecisePos');
    pa = get(x,'PeakPreciseVal');
end
fp = get(x,'FramePos');
if option.stable(1) < Inf
    for i = 1:length(pf)
        for j = 1:length(pf{i})
            for k = 1:size(pf{i}{j},3)
                for l = size(pf{i}{j},2):-1:option.stable(2)+1
                    for m = length(pf{i}{j}{1,l,k}):-1:1
                        found = 0;
                        for h = 1:option.stable(2)
                            for n = 1:length(pf{i}{j}{1,l-h,k})
                                if abs(log10(pf{i}{j}{1,l,k}(m) ...
                                            /pf{i}{j}{1,l-h,k}(n))) ...
                                       < option.stable(1)
                                    found = 1;
                                end
                            end
                        end
                        if not(found)
                            pf{i}{j}{1,l,k}(m) = [];
                        end
                    end
                    pf{i}{j}{1,1,k} = zeros(1,0);
                end
            end
        end
    end
end
if option.median
    sr = get(x,'Sampling');
    for i = 1:length(pf)
        for j = 1:length(pf{i})
            if size(fp{i}{j},2) > 1
                npf = zeros(size(pf{i}{j}));
                for k = 1:size(pf{i}{j},3)
                    for l = 1:size(pf{i}{j},2)
                        if isempty(pf{i}{j}{1,l,k})
                            npf(1,l,k) = NaN;
                        else
                            npf(1,l,k) = pf{i}{j}{1,l,k}(1);
                        end
                    end
                end
                pf{i}{j} = medfilt1(npf,...
                     round(option.median/(fp{i}{j}(1,2)-fp{i}{j}(1,1))));
            end
        end
    end
end
if isa(x,'mirscalar')
    p.amplitude = 0;
% Modified for the needs of parallell computing features in Psysound3    
    p.OptionStr = {};
    p.Frame=[];
    p.SpectrumType='';
else
    p.amplitude = pa;
% Modified for the needs of parallell computing features in Psysound3
    
    p.Frame=[];
    p.SpectrumType='';
end
s = mirscalar(x,'Data',pf,'Title','Pitch','Unit','Hz');
p = class(p,'MIRPITCH',s);
o = {p,x};