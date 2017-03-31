function varargout = mirpulseclarity(orig,varargin)
%   r = mirpulseclarity(x) estimates the rhythmic clarity, indicating the
%       strength of the beats estimated by the mirtempo function.
%   Optional arguments:
%       mirpulseclarity(...,s): specifies a strategy for pulse clarity
%           estimation.
%           Possible values: 'MaxAutocor' (default), 'MinAutocor',
%               'KurtosisAutocor', MeanPeaksAutocor', 'EntropyAutocor', 
%               'InterfAutocor', 'TempoAutocor', 'ExtremEnvelop', 
%               'Attack', 'Articulation'
%       mirpulseclarity(...,'Frame',l,h): orders a frame decomposition of
%           the audio input of window length l (in seconds) and hop factor
%           h, expressed relatively to the window length.
%           Default values: l = 5 seconds and h = .1
%       Onset detection strategies: 'Envelope' (default), 'DiffEnvelope', 
%           'SpectralFlux', 'Pitch'.
%       Options related to the autocorrelation computation can be specified
%           as well: 'Min', 'Max', 'Resonance', 'Enhanced'
%       Options related to the tempo estimation can be specified here
%           as well: 'Sum', 'Total', 'Contrast'.
%       cf. User's Manual for more details.
%   [r,a] = mirpulseclarity(x) also returns the beat autocorrelation.
        
        model.key = 'Model';
        model.type = 'Integer';
        model.default = 0;
    option.model = model;

        stratg.type = 'String';
        stratg.choice = {'MaxAutocor','MinAutocor','MeanPeaksAutocor',...
                         'KurtosisAutocor','EntropyAutocor',...
                         'InterfAutocor','TempoAutocor','ExtremEnvelop',...
                         'Attack','Articulation'};    ...,'AttackDiff'
        stratg.default = 'MaxAutocor';
    option.stratg = stratg;

        frame.key = 'Frame';
        frame.type = 'Integer';
        frame.number = 2;
        frame.keydefault = [5 .1];
        frame.default = [0 0];
    option.frame = frame;
        
%% options related to mironsets:  

        fea.type = 'String';
        fea.choice = {'Envelope','DiffEnvelope','SpectralFlux','Pitch'};
        fea.default = 'Envelope';
    option.fea = fea;
    
    
    %% options related to 'Envelope':
    
            envmeth.key = 'Method';
            envmeth.type = 'String';
            envmeth.choice = {'Filter','Spectro'};
            envmeth.default = 'Spectro';
        option.envmeth = envmeth;

            %% options related to 'Filter':

                ftype.key = 'FilterType';
                ftype.type = 'String';
                ftype.choice = {'IIR','HalfHann'};
                ftype.default = 'IIR';
            option.ftype = ftype;

                fb.key = 'Filterbank';
                fb.type = 'Integer';
                fb.default = 20;
            option.fb = fb;

                fbtype.key = 'FilterbankType';
                fbtype.type = 'String';
                fbtype.choice = {'Gammatone','Scheirer','Klapuri'};
                fbtype.default = 'Scheirer';
            option.fbtype = fbtype;

            %% options related to 'Spectro':

                band.type = 'String';
                band.choice = {'Freq','Mel','Bark','Cents'};
                band.default = 'Freq';
            option.band = band;


            diffhwr.key = 'HalfwaveDiff';
            diffhwr.type = 'Integer';
            diffhwr.default = 0;
            diffhwr.keydefault = 1;
        option.diffhwr = diffhwr;

            lambda.key = 'Lambda';
            lambda.type = 'Integer';
            lambda.default = 1;
        option.lambda = lambda;

            aver.key = 'Smooth';
            aver.type = 'Integer';
            aver.default = 0;
            aver.keydefault = 30;
        option.aver = aver;

            oplog.key = 'Log';
            oplog.type = 'Boolean';
            oplog.default = 0;
        option.log = oplog;
        
            mu.key = 'Mu';
            mu.type = 'Integer';
            mu.default = 100;
        option.mu = mu;

    %% options related to 'SpectralFlux'
    
            inc.key = 'Inc';
            inc.type = 'Boolean';
            inc.default = 1;
        option.inc = inc;

            median.key = 'Median';
            median.type = 'Integer';
            median.number = 2;
            median.default = [0 0]; % Not same default as in mirtempo
        option.median = median;

            hw.key = 'Halfwave';
            hw.type = 'Boolean';
            hw.default = 0; %NaN; %0; % Not same default as in mirtempo
        option.hw = hw;    
        
    
%% options related to mirattackslope
        slope.type = 'String';
        slope.choice = {'Diff','Gauss'};
        slope.default = 'Diff';
    option.slope = slope;
    
%% options related to mirautocor:    
    
        enh.key = 'Enhanced';
        enh.type = 'Integers';
        enh.default = [];
        enh.keydefault = 2:10;
    option.enh = enh;
    
        r.key = 'Resonance';
        r.type = 'String';
        r.choice = {'ToiviainenSnyder','vonNoorden',0,'off','no'};
        r.default = 'ToiviainenSnyder';
    option.r = r;
        
        mi.key = 'Min';
        mi.type = 'Integer';
        mi.default = 40;
    option.mi = mi;
        
        ma.key = 'Max';
        ma.type = 'Integer';
        ma.default = 200;
    option.ma = ma;    

%% options related to mirtempo:

        sum.key = 'Sum';
        sum.type = 'String';
        sum.choice = {'Before','After','Adjacent'};
        sum.default = 'Before';
    option.sum = sum;
    
        m.key = 'Total';
        m.type = 'Integer';
        m.default = 1;
    option.m = m;
        
        thr.key = 'Contrast';
        thr.type = 'Integer';
        thr.default = 0.01; % Not same default as in mirtempo
    option.thr = thr;

specif.option = option;

varargout = mirfunction(@mirpulseclarity,orig,varargin,nargout,specif,@init,@main);



%% Initialisation

function [x type] = init(x,option)
%if isframed(x)
%    warning('WARNING IN MIRPULSECLARITY: The input should not be already decomposed into frames.');
%    disp(['Suggestion: Use the ''Frame'' option instead.'])
%end
if iscell(x)
    x = x{1};
end
if isamir(x,'mirautocor')
    type = {'mirscalar','mirautocor'};
elseif length(option.model) > 1
    a = x;
    type = {'mirscalar'};
    for m = 1:length(option.model)
        if option.frame.length.val
            y = mirpulseclarity(a,'Model',option.model(m),...
                                  'Frame',option.frame.length.val,...
                                          option.frame.length.unit,...
                                          option.frame.hop.val,...
                                          option.frame.hop.unit);
        else
            y = mirpulseclarity(a,'Model',option.model(m));
        end
        if m == 1
            x = y;
        else
            x = x + y;
        end
    end
else
    if option.model
        switch option.model
            case 1
            case 2
                option.envmeth = 'Filter';
                option.fbtype = 'Klapuri'; % 'Gammatone' not in Matlab Central version
                option.mu = 0;
                option.r = 0;
                option.lambda = .8;
                option.sum = 'After';
        end
    end
    if length(option.stratg)>7 && strcmpi(option.stratg(end-6:end),'Autocor')
        if (strcmpi(option.stratg,'MaxAutocor') || ...
            strcmpi(option.stratg,'MinAutocor') || ...
            strcmpi(option.stratg,'EntropyAutocor'))
            option.m = 0;
        end
        if strcmpi(option.stratg,'MinAutocor')
            option.enh = 0;
        end
        if option.frame.length.val
            [t,x] = mirtempo(x,option.fea,'Method',option.envmeth,...
                       option.band,...
                       'Sum',option.sum,'Enhanced',option.enh,...
                       'Resonance',option.r,'Smooth',option.aver,...
                       'HalfwaveDiff',option.diffhwr,...
                       'Lambda',option.lambda,...
                       'Frame',option.frame.length.val,...
                               option.frame.length.unit,...
                               option.frame.hop.val,...
                               option.frame.hop.unit,...
                       'FilterbankType',option.fbtype,...
                       'FilterType',option.ftype,...
                       'Filterbank',option.fb,'Mu',option.mu,...
                       'Log',option.log,...
                       'Inc',option.inc,'Halfwave',option.hw,...
                       'Median',option.median(1),option.median(2),...
                       'Min',option.mi,'Max',option.ma,...
                       'Total',option.m,'Contrast',option.thr);
        else
            [t,x] = mirtempo(x,option.fea,'Method',option.envmeth,...
                       option.band,...
                       'Sum',option.sum,'Enhanced',option.enh,...
                       'Resonance',option.r,'Smooth',option.aver,...
                       'HalfwaveDiff',option.diffhwr,...
                       'Lambda',option.lambda,...
                       'FilterbankType',option.fbtype,...
                       'FilterType',option.ftype,...
                       'Filterbank',option.fb,'Mu',option.mu,...
                       'Log',option.log,...
                       'Inc',option.inc,'Halfwave',option.hw,...
                       'Median',option.median(1),option.median(2),...
                       'Min',option.mi,'Max',option.ma,...
                       'Total',option.m,'Contrast',option.thr);
        end
        type = {'mirscalar','mirautocor'};
    elseif strcmpi(option.stratg,'ExtremEnvelop')
        x = mironsets(x,'Filterbank',option.fb);
        type = {'mirscalar','mirenvelope'};
    elseif strcmpi(option.stratg,'Attack')
        x = mirattackslope(x,option.slope);
        type = {'mirscalar','mirenvelope'};
%    elseif strcmpi(option.stratg,'AttackDiff')
%        type = {'mirscalar','mirenvelope'};
    elseif strcmpi(option.stratg,'Articulation')
        x = mirlowenergy(x,'ASR');
        type = {'mirscalar','mirscalar'};
    else
        type = {'mirscalar','miraudio'};
    end
end



%% Main function

function o = main(a,option,postoption)
if option.model == 2
    option.stratg = 'InterfAutocor';
end
if isa(a,'mirscalar') && not(strcmpi(option.stratg,'Attack')) % not very nice test... to improve.
    o = {a};
    return
end
if option.m == 1 && ...
        (strcmpi(option.stratg,'InterfAutocor') || ...
         strcmpi(option.stratg,'MeanPeaksAutocor'))
    option.m = Inf;
end
if iscell(a)
    a = a{1};
end
if strcmpi(option.stratg,'MaxAutocor')
    d = get(a,'Data');
    rc = mircompute(@max,d);
elseif strcmpi(option.stratg,'MinAutocor')
    d = get(a,'Data');
    rc = mircompute(@minusmin,d);
elseif strcmpi(option.stratg,'MeanPeaksAutocor')
    m = get(a,'PeakVal');
    rc = mircompute(@meanpeaks,m);    
elseif strcmpi(option.stratg,'KurtosisAutocor')
    a = mirpeaks(a,'Extract','Total',option.m,'NoBegin','NoEnd');
    k = mirkurtosis(a);
    %d = get(k,'Data');
    %rc = mircompute(@meanpeaks,d);
    rc = mirmean(k);
elseif strcmpi(option.stratg,'EntropyAutocor')
    rc = mirentropy(a);
elseif strcmpi(option.stratg,'InterfAutocor')
    a = mirpeaks(a,'Total',option.m,'NoBegin','NoEnd');
    m = get(a,'PeakVal');
    p = get(a,'PeakPosUnit');
    rc = mircompute(@interf,m,p);
elseif strcmpi(option.stratg,'TempoAutocor')
    a = mirpeaks(a,'Total',1,'NoBegin','NoEnd');
    p = get(a,'PeakPosUnit');
    rc = mircompute(@tempo,p);
elseif strcmpi(option.stratg,'ExtremEnvelop')
    a = mirenvelope(a,'Normal');
    p = mirpeaks(a,'Order','Abscissa');
    p = get(p,'PeakPreciseVal');
    n = mirpeaks(a,'Valleys','Order','Abscissa');
    n = get(n,'PeakPreciseVal');
    rc = mircompute(@shape,p,n);
elseif strcmpi(option.stratg,'Attack')
    rc = mirmean(a);
%elseif strcmpi(option.stratg,'AttackDiff')
%    a = mirpeaks(a);
%    m = get(a,'PeakVal');
%    rc = mircompute(@meanpeaks,m);    
elseif strcmpi(option.stratg,'Articulation')
    rc = a;
end

if iscell(rc)
    pc = mirscalar(a,'Data',rc,'Title','Pulse clarity');
else
    pc = set(rc,'Title',['Pulse clarity (',get(rc,'Title'),')']);
end

if option.model
    switch option.model
        case 1
            alpha = 0;
            beta = 2.2015;
            lambda = .1;
        case 2
            alpha = 0;
            beta = 3.5982;
            lambda = 1.87;
    end
    if not(lambda == 0)
        pc = (pc+alpha)^lambda * beta;
    else
        pc = log(pc+alpha) * beta;
    end
    title = ['Pulse clarity (Model ',num2str(option.model),')'];
    pc = set(pc,'Title',title);
end

o = {pc a};


%% Routines

function r  = shape(p,n)
p = p{1};
n = n{1};
if length(p)>length(n)
    d = sum(p(1:end-1) - n) + sum(p(2:end) - n);
    r  = d/(2*length(n));
elseif length(p)<length(n)
    d = sum(p - n(1:end-1)) + sum(p - n(2:end));
    r  = d/(2*length(p));
else
    d = sum(p(2:end) - n(1:end-1)) + sum(p(1:end-1) - n(2:end));
    r  = d/(2*(length(p)-1));
end


function rc = minusmin(ac)
rc = -min(ac);


function rc = meanpeaks(ac)
rc = zeros(1,length(ac));
for j = 1:length(ac)
    if isempty(ac{j})
        rc(j) = NaN;
    else
        rc(j) = mean(ac{j});
    end
end


function rc = interf(mk,pk)
rc = zeros(size(mk));
for j = 1:size(mk,3)
    for i = 1:size(mk,2)
        pij = pk{1,i,j};
        mij = mk{1,i,j};
        if isempty(pij)
            rc(1,i,j) = 0;
        else
            high = max(pij(2:end),pij(1));
            low = min(pij(2:end),pij(1));
            quo = rem(high,low)./low;
            nomult = quo>.15 & quo<.85;
            fij = mij(2:end)/mij(1) .*nomult;
            fij(fij<0) = 0;
            rc(1,i,j) = exp(-sum(fij)/4); % Pulsations that are not in integer ratio
                                          % with dominant pulse decrease clarity
        end
    end
end


function rc = tempo(pk)
rc = zeros(size(pk));
for j = 1:size(pk,3)
    for i = 1:size(pk,2)
        pij = pk{1,i,j};
        if isempty(pij)
            rc(1,i,j) = 0;
        else
            rc(1,i,j) = exp(-pij(1)/4)/exp(-.33/4); % Fast dominant pulse
                                                    % increases clarity
        end
    end
end