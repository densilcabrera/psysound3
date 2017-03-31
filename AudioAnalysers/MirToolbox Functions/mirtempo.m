function varargout = mirtempo(x,varargin)
%   t = mirtempo(x) evaluates the tempo in beats per minute (BPM).
%   Optional arguments:
%       mirtempo(...,'Total',m) selects not only the best tempo, but the m
%           best tempos.
%       mirtempo(...,'Frame',l,h) orders a frame decomposition of window
%           length l (in seconds) and hop factor h, expressed relatively to
%           the window length. For instance h = 1 indicates no overlap.
%           Default values: l = 3 seconds and h = .1
%       mirtempo(...,'Min',mi) indicates the lowest tempo taken into
%           consideration, expressed in bpm.
%           Default value: 40 bpm.
%       mirtempo(...,'Max',ma) indicates the highest tempo taken into
%           consideration, expressed in bpm.
%           Default value: 200 bpm.
%       mirtempo(...,s) selects the tempo estimation strategy:
%           s = 'Autocor': Approach based on the computation of the
%               autocorrelation. (Default strategy)
%               Option associated to the mirautocor function can be
%               passed here as well (see help mirautocor):
%                   'Enhanced' (toggled on by default here)
%           s = 'Spectrum': Approach based on the computation of the
%               spectrum .
%               Option associated to the mirspectrum function can be
%               passed here as well (see help mirspectrum):
%                   'ZeroPad' (set by default to 10000 samples)
%                   'Prod' (toggled off by default)
%           These two strategies can be combined: the autocorrelation
%               function is translated into the frequency domain in order
%               to be compared to the spectrum curve.
%               tempo(...,'Autocor','Spectrum') multiplies the two curves.
%           Alternatively, an autocorrelation function ac or a spectrum sp
%               can be directly passed to the function tempo:
%                   mirtempo(ac) or mirtempo(sp)
%       The options related to the onset detection phase can be specified 
%               here as well (see help mironsets):
%               onset detection strategies: 'Envelope', 'DiffEnvelope'
%               (corresponding to 'Envelope', 'Diff'), 'SpectralFlux,
%               'Pitch', 'Log', 'Mu', 'Filterbank'
%               mironsets(...,'Sum',w) specifies when to sum the channels.
%                   Possible values:
%                       w = 'Before': sum before the autocorrelation or
%                           spectrum computation.
%                       w = 'After': autocorrelation or spectrum computed
%                           for each band, and summed into a "summary".
%               mirenvelope options: 'HalfwaveCenter','Diff' (toggled on by
%                   default here),'HalfwaveDiff','Center','Smooth',
%                   'Sampling'
%               mirflux options: 'Inc','Halfwave','Complex','Median'
%       mirtempo(...,'Resonance',r) specifies the resonance curve, which
%           emphasizes the periods that are more easily perceived.
%           Possible values: 'ToiviainenSnyder' (default), 0 (toggled off)
%   Optional arguments used for the peak picking (cf. help mirpeaks)
%       mirtempo(...,'Contrast',thr): a threshold value. A given local
%           maximum will be considered as a peak if its distance with the
%           previous and successive local minima (if any) is higher than 
%           this threshold. This distance is expressed with respect to the
%           total amplitude of the autocorrelation function.
%               if no value for thr is given, the value thr=0.1 is chosen
%                   by default.
%
%   [t,p] = mirtempo(...) also displays the result of the signal analysis
%       leading to the tempo estimation, and shows in particular the
%       peaks corresponding to the tempo values.
            
    
        sum.key = 'Sum';
        sum.type = 'String';
        sum.choice = {'Before','After','Adjacent',0};
        sum.default = 'Before';
    option.sum = sum;
        
%% options related to mironsets:    

        frame.key = 'Frame';
        frame.type = 'Integer';
        frame.number = 2;
        frame.default = [0 0];
        frame.keydefault = [3 .1];
    option.frame = frame;
    
        fea.type = 'String';
        fea.choice = {'Envelope','DiffEnvelope','SpectralFlux','Pitch'};
        fea.default = 'Envelope';
    option.fea = fea;
    
    %% options related to 'Envelope':
    
            envmeth.key = 'Method';
            envmeth.type = 'String';
            envmeth.choice = {'Filter','Spectro'};
            envmeth.default = 'Filter';
        option.envmeth = envmeth;
    
        %% options related to 'Filter':

                fb.key = 'Filterbank';
                fb.type = 'Integer';
                fb.default = 10;
            option.fb = fb;

                fbtype.key = 'FilterbankType';
                fbtype.type = 'String';
                fbtype.choice = {'Gammatone','Scheirer','Klapuri'};
                fbtype.default = 'Scheirer'; % 'Gammatone' not in Matlab Central version
            option.fbtype = fbtype;

                ftype.key = 'FilterType';
                ftype.type = 'String';
                ftype.choice = {'IIR','HalfHann'};
                ftype.default = 'IIR';
            option.ftype = ftype;

        %% options related to 'Spectro':
        
                band.type = 'String';
                band.choice = {'Freq','Mel','Bark','Cents'};
                band.default = 'Freq';
            option.band = band;

        
            chwr.key = 'HalfwaveCenter';
            chwr.type = 'Boolean';
            chwr.default = 0;
        option.chwr = chwr;

            diff.key = 'Diff';
            diff.type = 'Boolean';
            diff.default = 1; % Different default for mirtempo
        option.diff = diff;

            diffhwr.key = 'HalfwaveDiff';
            diffhwr.type = 'Integer';
            diffhwr.default = 0;
            diffhwr.keydefault = 1;
        option.diffhwr = diffhwr;
        
            lambda.key = 'Lambda';
            lambda.type = 'Integer';
            lambda.default = 1;
        option.lambda = lambda;

            mu.key = 'Mu'; 
            mu.type = 'Integer'; 
            mu.default = 0; 
	        option.mu = mu; 
        
            log.key = 'Log';
            log.type = 'Boolean';
            log.default = 0;
        option.log = log;

            c.key = 'Center';
            c.type = 'Boolean';
            c.default = 0;
        option.c = c;

            aver.key = 'Smooth';
            aver.type = 'Integer';
            aver.default = 0;
            aver.keydefault = 30;
        option.aver = aver;

            sampling.key = 'Sampling';
            sampling.type = 'Integer';
            sampling.default = 0;
        option.sampling = sampling;

    %% options related to 'SpectralFlux'
    
            complex.key = 'Complex';
            complex.type = 'Boolean';
            complex.default = 0;
        option.complex = complex;

            inc.key = 'Inc';
            inc.type = 'Boolean';
            inc.default = 1;
        option.inc = inc;

            median.key = 'Median';
            median.type = 'Integer';
            median.number = 2;
            median.default = [.2 1.3];
        option.median = median;

            hw.key = 'Halfwave';
            hw.type = 'Boolean';
            hw.default = 1;
        option.hw = hw;                
        
        
%% options related to mirautocor:    

        aut.key = 'Autocor';
        aut.type = 'Integer';
        aut.default = 0;
        aut.keydefault = 1;
    option.aut = aut;            
    
        nw.key = 'NormalWindow';
        nw.default = 0;
    option.nw = nw;

        enh.key = 'Enhanced';
        enh.type = 'Integers';
        enh.default = 2:10;
        enh.keydefault = 2:10;
    option.enh = enh;

        r.key = 'Resonance';
        r.type = 'String';
        r.choice = {'ToiviainenSnyder','vanNoorden',0,'off','no'};
        r.default = 'ToiviainenSnyder';
    option.r = r;


%% options related to mirspectrum:
    
        spe.key = 'Spectrum';
        spe.type = 'Integer';
        spe.default = 0;
        spe.keydefault = 1;
    option.spe = spe;

        zp.key = 'ZeroPad';
        zp.type = 'Integer';
        zp.default = 10000;
        zp.keydefault = Inf;
    option.zp = zp;
    
        prod.key = 'Prod';
        prod.type = 'Integers';
        prod.default = 0;
        prod.keydefault = 2:6;
    option.prod = prod;

    
%% options related to the peak detection

        m.key = 'Total';
        m.type = 'Integer';
        m.default = 1;
    option.m = m;
        
        thr.key = 'Contrast';
        thr.type = 'Integer';
        thr.default = 0.1;
    option.thr = thr;
        
        mi.key = 'Min';
        mi.type = 'Integer';
        mi.default = 40;
    option.mi = mi;
        
        ma.key = 'Max';
        ma.type = 'Integer';
        ma.default = 200;
    option.ma = ma;

        track.key = 'Track';
        track.type = 'Boolean';
        track.default = 0;
    option.track = track;

        pref.key = 'Pref';
        pref.type = 'Integer';
        pref.number = 2;
        pref.default = [0 .2];
    option.pref = pref;
            
        perio.key = 'Periodicity';
        perio.type = 'Boolean';
        perio.default = 0;
    option.perio = perio;
    
specif.option = option;

varargout = mirfunction(@mirtempo,x,varargin,nargout,specif,@init,@main);


%% INIT

function [y type] = init(x,option)
if iscell(x)
    x = x{1};
end
if option.perio
    option.m = 3;
    option.enh = 2:10;
end
if not(isamir(x,'mirautocor')) && not(isamir(x,'mirspectrum'))
    if isframed(x) && strcmpi(option.fea,'Envelope') && not(isamir(x,'mirscalar'))
        warning('WARNING IN MIRTEMPO: The input should not be already decomposed into frames.');
        disp(['Suggestion: Use the ''Frame'' option instead.'])
    end
    if strcmpi(option.sum,'Before')
        optionsum = 1;
    elseif strcmpi(option.sum,'Adjacent')
        optionsum = 5;
    else
        optionsum = 0;
    end
    if option.frame.length.val
        x = mironsets(x,option.fea,'Filterbank',option.fb,...
                    'FilterbankType',option.fbtype,...
                    'FilterType',option.ftype,...
                    'Sum',optionsum,'Method',option.envmeth,...
                    option.band,'Center',option.c,...
                    'HalfwaveCenter',option.chwr,'Diff',option.diff,...
                    'HalfwaveDiff',option.diffhwr,'Lambda',option.lambda,...
                    'Smooth',option.aver,'Sampling',option.sampling,...
                    'Complex',option.complex,'Inc',option.inc,...
                    'Median',option.median(1),option.median(2),...
                    'Halfwave',option.hw,'Detect',0,...
                    'Mu',option.mu,'Log',option.log,...
                    'Frame',option.frame.length.val,...
                            option.frame.length.unit,...
                            option.frame.hop.val,...
                            option.frame.hop.unit);
    else
        x = mironsets(x,option.fea,'Filterbank',option.fb,...
                    'FilterbankType',option.fbtype,...
                    'FilterType',option.ftype,...
                    'Sum',optionsum,'Method',option.envmeth,...
                    option.band,'Center',option.c,...
                    'HalfwaveCenter',option.chwr,'Diff',option.diff,...
                    'HalfwaveDiff',option.diffhwr,'Lambda',option.lambda,...
                    'Smooth',option.aver,'Sampling',option.sampling,...
                    'Complex',option.complex,'Inc',option.inc,...
                    'Median',option.median(1),option.median(2),...
                    'Halfwave',option.hw,'Detect',0,...
                    'Mu',option.mu,'Log',option.log);
    end
end
if option.aut == 0 && option.spe == 0
    option.aut = 1;
end
if isamir(x,'mirautocor') || (option.aut && not(option.spe))
    y = mirautocor(x,'Min',60/option.ma,'Max',60/option.mi,...
          'Enhanced',option.enh,...'NormalInput','coeff',...
          'Resonance',option.r,'NormalWindow',option.nw);
elseif isamir(x,'mirspectrum') || (option.spe && not(option.aut))
    y = mirspectrum(x,'Min',option.mi/60,'Max',option.ma/60,...
                       'Prod',option.prod,...'NormalInput',...
                       'ZeroPad',option.zp,'Resonance',option.r);
elseif option.spe && option.aut
    ac = mirautocor(x,'Min',60/option.ma,'Max',60/option.mi,...
          'Enhanced',option.enh,...'NormalInput','coeff',...
          'Resonance',option.r);
    sp = mirspectrum(x,'Min',option.mi/60,'Max',option.ma/60,...
                       'Prod',option.prod,...'NormalInput',...
                       'ZeroPad',option.zp,'Resonance',option.r);
    y = ac*sp;
end
if ischar(option.sum)
    y = mirsum(y);
end
y = mirpeaks(y,'Total',option.m,'Track',option.track,...
               'Pref',option.pref(1),option.pref(2),...
               'Contrast',option.thr,'NoBegin','NoEnd',...
               'Normalize','Local');
type = {'mirscalar',mirtype(y)};            


%% MAIN

function o = main(p,option,postoption)
if iscell(p)
    p = p{1};
end
pt = get(p,'TrackPrecisePos');
track = 1;
if isempty(pt) || isempty(pt{1})
    pt = get(p,'PeakPrecisePos');
    track = 0;
end
bpm = cell(1,length(pt));
for j = 1:length(pt)
    bpm{j} = cell(1,length(pt{j}));
    for k = 1:length(pt{j})
        ptk = pt{j}{k};
        bpmk = cell(1,size(ptk,2));
        for h = 1:size(ptk,3)
            for l = 1:size(ptk,2)
                ptl = ptk{1,l,h};
                if isempty(ptl)
                    bpmk{1,l,h} = NaN;
                else
                    if isa(p,'mirautocor') && not(get(p,'FreqDomain'))
                        bpmk{1,l,h} = 60./ptl;
                    else
                        bpmk{1,l,h} = ptl*60;
                    end
                end
            end
        end
        if track
            bpmk = bpmk{1};
        end
        bpm{j}{k} = bpmk;
    end 
end
t = mirscalar(p,'Data',bpm,'Title','Tempo','Unit','bpm');
o = {t,p};