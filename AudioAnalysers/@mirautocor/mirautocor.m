function varargout = mirautocor(orig,varargin)
%   a = mirautocor(x) computes the autocorrelation function related to x.
%   Optional parameters:
%       mirautocor(...,'Min',mi) indicates the lowest delay taken into
%           consideration. The unit can be precised:
%               mirautocor(...,'Min',mi,'s') (default unit)
%               mirautocor(...,'Min',mi,'Hz')
%           Default value: 0 s.
%       mirautocor(...,'Max',ma) indicates the highest delay taken into
%           consideration. The unit can be specified as for 'Min'.
%           Default value:
%               if x is a signal, the highest delay is 0.05 s
%                   (corresponding to a minimum frequency of 20 Hz).
%               if x is an envelope, the highest delay is 2 s.
%       mirautocor(...,'Resonance',r) multiplies the autocorrelation function
%           with a resonance curve:
%           Possible values:
%               'Toiviainen' from (Toiviainen & Snyder, 2003)
%               'vanNoorden' from (van Noorden & Moelants, 2001)
%           mirautocor(...,'Center',c) assigns the center value of the
%               resonance curve, in seconds.
%               Works mainly with 'Toiviainen' option.
%               Default value: c = 0.5
%       mirautocor(...,'Enhanced',a) reduces the effect of subharmonics.
%           The original autocorrelation function is half-wave rectified,
%           time-scaled by the factor a (which can be a factor list as
%           well), and substracted from the original clipped function.
%           (Tolonen & Karjalainen)
%               If the 'Enhanced' option is not followed by any value, 
%                   default value is a = 2:10
%       mirautocor(...,'Halfwave') performs a half-wave rectification on the
%           result.
%       mirautocor(...,'Freq') represents the autocorrelation function in the
%           frequency domain.
%       mirautocor(...,'NormalWindow',w): applies a window to the input 
%           signal and divides the autocorrelation by the autocorrelation of  
%           that window (Boersma 1993).
%           Possible values: any windowing function proposed in the Signal
%               Processing Toolbox (help window) plus 'rectangle' (no
%               windowing)
%           Default value:  w = 'hanning'
%           mirautocor(...,'NormalWindow',0): toggles off this normalization
%               (which is on by default).
%   All the parameters described previously can be applied to an
%       autocorrelation function itself, in order to arrange the results
%       after the actual computation of the autocorrelation computations.
%       For instance: a = mirautocor(a,'Resonance','Enhanced')
%   Other optional parameter:
%       mirautocor(...,'Compres',k) computes the autocorrelation in the
%           frequency domain and includes a magnitude compression of the
%           spectral representation. A normal autocorrelation corresponds
%           to the value k=2, but values lower than 2 are suggested by
%           (Tolonen & Karjalainen, 2000).
%           Default value: k = 0.67
%       mirautocor(...,'Normal',n) or simply mirautocor(...,n) specifies
%           the normalization strategy. Accepted values are 'biased',
%           'unbiased', 'coeff' (default  value) and 'none'.
%           See help xcorr for an explanation. 



% Adapted for Psysound3

if nargin==0 %position of the ''end''?


    a.freq = 0;
    a.ofspectrum = [];
    a.window = {};
    a.normalwindow = []; 
a = class(a,'mirautocor', mirdata() );
a=set(a,'Name','MirToolbox (mirautocor)');
varargout={a};

else
        min.key = 'Min';
        min.type = 'Integer';
        min.unit = {'s','Hz'};
        if isamir(orig,'mirspectrum')
            min.defaultunit = 'Hz';
        else
            min.defaultunit = 's';
        end
        min.default = 0;
        min.opposite = 'max';
    option.min = min;
        
        max.key = 'Max';
        max.type = 'Integer';
        max.unit = {'s','Hz'};
        if isamir(orig,'mirspectrum')
            max.defaultunit = 'Hz';
        else
            max.defaultunit = 's';
        end
        if isamir(orig,'mirenvelope') || isamir(orig,'mirdiffenvelope')
            max.default = 2;             % for envelopes, longest period: 2 seconds.
        elseif isamir(orig,'miraudio')  || ischar(orig)  % for audio signal,lowest frequency: 20 Hz.
            max.default = 1/20; 
        else
            max.default = Inf;
        end
        max.opposite = 'min';
    option.max = max;
        
        scaleoptbw.key = 'Normal'; %'Normal' keyword optional
        scaleoptbw.key = 'Boolean';
    option.scaleoptbw = scaleoptbw;
        scaleopt.type = 'String';
        scaleopt.choice = {'biased','unbiased','coeff','none'};
        scaleopt.default = 'coeff';
    option.scaleopt = scaleopt;
            
        gener.key = {'Generalized','Compres'};
        gener.type = 'Integer';
        gener.default = 2;
        gener.keydefault = .67;
    option.gener = gener;
        
        ni.key = 'NormalInput';  %% Normalize before frame or chunk??
        ni.type = 'Boolean';
        ni.default = 0;
    option.ni = ni;
    
        reso.key = 'Resonance';
        reso.type = 'String';
        reso.choice = {'ToiviainenSnyder','Toiviainen','vanNoorden','no','off',0};
        reso.keydefault = 'Toiviainen';
        reso.when = 'After';
        reso.default = 0;
    option.reso = reso;
        
        resocenter.key = {'Center','Centre'};
        resocenter.type = 'Integer';
        resocenter.when = 'After';
    option.resocenter = resocenter;

        h.key = 'Halfwave';
        h.type = 'Boolean';
        h.when = 'After';
        h.default = 0;
    option.h = h;
        
        e.key = 'Enhanced';
        e.type = 'Integers';
        e.default = [];
        e.keydefault = 2:10;
        e.when = 'After';
    option.e = e;
        
        fr.key = 'Freq';
        fr.type = 'Boolean';
        fr.default = 0;
        fr.when = 'After';
    option.fr = fr;
        
        nw.key = 'NormalWindow';
        nw.when = 'Both';
        if isamir(orig,'mirspectrum')
            nw.default = 0;
        elseif isamir(orig,'mirenvelope')
            nw.default = 'rectangular';
        else
            nw.default = 'hanning';
        end
    option.nw = nw;
    
        win.key = 'Window';
        win.type = 'String';
        win.default = NaN;
    option.win = win;
    
specif.option = option;

specif.defaultframelength = 0.05;
specif.defaultframehop = 0.5;
specif.eachchunk = @eachchunk;
specif.combinechunk = @combinechunk;

if isamir(orig,'mirscalar') || isamir(orig,'mirenvelope')
    specif.nochunk = 1;
end

varargout = mirfunction(@mirautocor,orig,varargin,nargout,specif,@init,@main);
end


function [x type] = init(x,option)
type = 'mirautocor';


function a = main(orig,option,postoption)
if iscell(orig)
    orig = orig{1};
end
if isa(orig,'mirautocor')
    a = orig;
    if not(isempty(option)) && ...
            (option.min || iscell(option.max) || option.max < Inf)
        coeff = get(a,'Coeff');
        delay = get(a,'Delay');
        for h = 1:length(coeff)
            if a.freq
                mi = 1/option.max;
                ma = 1/option.min;
            else
                mi = option.min;
                ma = option.max;
            end
            for k = 1:length(coeff{h})
                range = find(and(delay{h}{k}(:,1,1) >= mi,...
                                 delay{h}{k}(:,1,1) <= ma));
                coeff{h}{k} = coeff{h}{k}(range,:,:);
                delay{h}{k} = delay{h}{k}(range,:,:);
            end
        end
        a = set(a,'Coeff',coeff,'Delay',delay);
    end
    if not(isempty(postoption)) && not(isequal(postoption,0))
        a = post(a,postoption);
    end
elseif ischar(orig)
    a = mirautocor(miraudio(orig),option,postoption);
else
    if nargin == 0
        orig = [];
    end
    a.freq = 0;
    a.ofspectrum = 0;
    a.window = {};
    a.normalwindow = 0;
    a = class(a,'mirautocor',mirdata(orig));
    a = purgedata(a);
a=set(a,'Name','MirToolbox (mirautocor)'); % Adapted for Psysound3
    sig = get(orig,'Data');
    if isa(orig,'mirspectrum')
        a = set(a,'Title','Spectrum autocorrelation','OfSpectrum',1,...
                  'Abs','frequency (Hz)');
        pos = get(orig,'Pos');
    else
        if isa(orig,'mirscalar')
            a = set(a,'Title',[get(orig,'Title') ' autocorrelation']);
            pos = get(orig,'FramePos');
            for k = 1:length(sig)
                for l = 1:length(sig{k})
                    sig{k}{l} = sig{k}{l}';
                    pos{k}{l} = pos{k}{l}(1,:,:)';
                end
            end
        else
            if isa(orig,'mirenvelope')
                a = set(a,'Title','Envelope autocorrelation');
            elseif not(isa(orig,'mirautocor'))
                a = set(a,'Title','Waveform autocorrelation');
            end
            pos = get(orig,'Pos');
        end
        a = set(a,'Abs','lag (s)');
    end
    f = get(orig,'Sampling');
    
    if isnan(option.win) 
        if isequal(option.nw,0) || ...
                strcmpi(option.nw,'Off') || strcmpi(option.nw,'No')
            option.win = 0;
        elseif isequal(option.nw,1) || strcmpi(option.nw,'On') || ...
                                     strcmpi(option.nw,'Yes')
            option.win = 'hanning';
        else
            option.win = postoption.nw;
        end
    end

    coeff = cell(1,length(sig));
    lags = cell(1,length(sig));
    wind = cell(1,length(sig));
    for k = 1:length(sig)
        s = sig{k};
        p = pos{k};
        fk = f{k};
        if iscell(option.max)
            mi = option.min{k};
            ma = option.max{k};
        else
            mi = option.min;
            ma = option.max;
        end
        coeffk = cell(1,length(s));
        lagsk = cell(1,length(s));
        windk = cell(1,length(s));
        for l = 1:length(s)
            sl = s{l};
            sl(isnan(sl)) = 0;
            if option.ni
                mxsl = repmat(max(sl),[size(sl,1),1,1]);
                mnsl = repmat(min(sl),[size(sl,1),1,1]);
                sl = (sl-mnsl)./(mxsl-mnsl);
            end
            pl = p{l};
            pl = pl-repmat(pl(1,:,:),[size(pl,1),1,1]);
            ls = size(sl,1);
 
            if mi
                misp = find(pl(:,1,1)>=mi);
                if isempty(misp)
                    warning('WARNING IN MIRAUTOCOR: The specified range of delays exceeds the temporal length of the signal.');
                    disp('Minimum delay set to zero.')
                    misp = 1;  % misp is the lowest index of the lag range
                    mi = 0;
                else
                    misp = misp(1);
                end
            else
                misp = 1;
            end
            if ma
                masp = find(pl(:,1,1)>=ma);
                if isempty(masp)
                    masp = Inf;
                else
                    masp = masp(1);
                end
            else
                masp = Inf;
            end
            masp = min(masp,ceil(ls/2));
            if masp <= misp
                if size(sl,2) > 1
                    warning('WARNING IN MIRAUTOCOR: Frame length is too small.');    
                else
                    warning('WARNING IN MIRAUTOCOR: The audio sequence is too small.');    
                end
                display('The autocorrelation is not defined for this range of delays.');
            end
            sl = center(sl);
            if not(ischar(option.win)) || strcmpi(option.win,'Rectangular')
                kw = ones(size(sl));
            else
                N = size(sl,1);
                winf = str2func(option.win);
                try
                    w = window(winf,N);
                catch
                    if strcmpi(option.win,'hamming')
                        disp('Signal Processing Toolbox does not seem to be installed. Recompute the hamming window manually.');
                        w = 0.54 - 0.46 * cos(2*pi*(0:N-1)'/(N-1));
                    else
                        warning(['WARNING in MIRAUTOCOR: Unknown windowing function ',option.win,' (maybe Signal Processing Toolbox is not installed).']);
                        disp('No windowing performed.')
                        w = ones(size(sl,1),1);
                    end
                end
                kw = repmat(w,[1,size(sl,2),size(sl,3)]);
                sl = sl.* kw;
            end

            if strcmpi(option.scaleopt,'coeff')
                scaleopt = 'none';
            else
                scaleopt = option.scaleopt;
            end
            c = zeros(masp,size(sl,2),size(sl,3));
            for i = 1:size(sl,2)
                for j = 1:size(sl,3)
                    if option.gener == 2
                        cc = xcorr(sl(:,i,j),masp-1,scaleopt);
                        c(:,i,j) = cc(masp:end);
                    else
                        ss = abs(fft(sl(:,i,j)));
                        ss = ss.^option.gener;
                        cc = ifft(ss);
                        ll = (0:masp-1);
                        c(:,i,j) = cc(ll+1);
                    end
                end
                if strcmpi(option.scaleopt,'coeff') && option.gener == 2
                    % to be adapted to generalized autocor
                    c(:,i,:) = c(:,i,:)/xcorr(sum(sl(:,i,:),3),0);
                    % This is a kind of generalization of the 'coeff'
                    % normalization for multi-channels signals. In the
                    % original 'coeff' option, the autocorrelation at zero
                    % lag is identically 1.0. In this multi-channels
                    % version, the autocorrelation at zero lag is such that
                    % the sum over channels becomes identically 1.0. 
                end
            end
            coeffk{l} = c(misp:end,:,:);
            pl = pl(find(pl(:,1,1) >=mi),:,:);
            lagsk{l} = pl(1:min(size(coeffk{l},1),size(pl,1)),:,:);
            windk{l} = kw;
        end
        coeff{k} = coeffk;
        lags{k} = lagsk;
        wind{k} = windk;
    end
    a = set(a,'Coeff',coeff,'Delay',lags,'Window',wind);
    if not(isempty(postoption))
        a = post(a,postoption);
    end
end


function a = post(a,option)
debug = 0;
coeff = get(a,'Coeff');
lags = get(a,'Delay');
wind = get(a,'Window');
freq = option.fr && not(get(a,'FreqDomain'));
if isequal(option.e,1)
    option.e = 2:10;
end
if max(option.e) > 1
    pa = mirpeaks(a,'NoBegin','NoEnd','Contrast',.01);
    va = mirpeaks(a,'Valleys','Contrast',.01);
    pv = get(pa,'PeakVal');
    vv = get(va,'PeakVal');
end
for k = 1:length(coeff)
    for l = 1:length(coeff{k})
        c = coeff{k}{l};  % Coefficients of autocorrelation
        t = lags{k}{l};   % Delays of autocorrelation
        if not(isempty(c))
            if not(isequal(option.nw,0) || strcmpi(option.nw,'No') || ...
                   strcmpi(option.nw,'Off') || a.normalwindow) % 'NormalWindow' option
                xw = zeros(size(c));
                lc = size(c,1);
                for j = 1:size(c,3)
                    for i = 1:size(c,2)
                        xwij = xcorr(wind{k}{l}(:,i,j),lc,'coeff');
                        xw(:,i,j) = xwij(lc+2:end);
                    end
                end
                c = c./ xw;
                a.normalwindow = 1;
            end
            if ischar(option.reso) && ...
                    (strcmpi(option.reso,'ToiviainenSnyder') || ...
                    strcmpi(option.reso,'Toiviainen') || ...
                    strcmpi(option.reso,'vanNoorden'))
                if isa(a,'mirautocor') && get(a,'FreqDomain')
                    ll = 1./t;
                else
                    ll = t;
                end
                if not(option.resocenter)
                    option.resocenter = .5;
                end
                if strcmpi(option.reso,'ToiviainenSnyder') || ...
                    strcmpi(option.reso,'Toiviainen')
                    w = max(1 - 0.25*(log2(max(ll,1e-12)/option.resocenter)).^2, 0);
                elseif strcmpi(option.reso,'vanNoorden')
                    f0=2.193; b=option.resocenter; 
                    f=1./ll; a1=(f0*f0-f.*f).^2+b*f.^2; a2=f0^4+f.^4;
                    w=(1./sqrt(a1))-(1./sqrt(a2));
                end
                if max(w) == 0
                    warning('The resonance curve, not defined for this range of delays, will not be applied.')
                else
                    w = w/max(w);
                    c = c.* repmat(w,[1,size(c,2),size(c,3)]);
                end
            end
            if option.h
                c = hwr(c);
            end
            if max(option.e) > 1
                if a.freq
                    freq = 1;
                    for i = 1:size(c,3)
                        c(:,:,i) = flipud(c(:,:,i));
                    end
                    t = flipud(1./t);
                end
                
                for g = 1:size(c,2)
                    for h = 1:size(c,3)
                        cgh = c(:,g,h);
                        if length(cgh)>1
                            pvk = pv{k}{l}{1,g,h};
                            mv = [];
                            if not(isempty(pvk))
                                mp = min(pv{k}{l}{1,g,h}); %Lowest peak
                                vvv = vv{k}{l}{1,g,h}; %Valleys
                                mv = vvv(find(vvv<mp,1,'last'));
                                    %Highest valley below the lowest peak

                                if not(isempty(mv))
                                    cgh = cgh-mv;
                                end
                            end
                            cgh2 = cgh;
                            tgh2 = t(:,g,1);
                            coef = cgh(2)-cgh(1); % initial slope of the autocor curve
                            tcoef = tgh2(2)-tgh2(1);
                            deter = 0;
                            inter = 0;

                            repet = find(not(diff(tgh2)));  % Avoid bug if repeated x-values
                            if repet
                                warning('WARNING in MIRAUTOCOR: Two successive samples have exactly same temporal position.');
                                tgh2(repet+1) = tgh2(repet)+1e-12;
                            end

                            if coef < 0
                                % initial descending slope removed
                                deter = find(diff(cgh2)>0,1)-1;
                                    % number of removed points
                                if isempty(deter)
                                    deter = 0;
                                end
                                cgh2(1:deter) = [];
                                tgh2(1:deter) = [];
                                coef = cgh2(2)-cgh2(1);
                            end

                            if coef > 0
                                % initial ascending slope prolonged to the left
                                % until it reaches the x-axis
                                while cgh2(1) > 0
                                    coef = coef*1.1;
                                        % the further to the left, ...
                                        % the more ascending is the slope
                                        % (not sure it always works, though...)
                                    inter = inter+1;
                                        % number of added points
                                    cgh2 = [cgh2(1)-coef; cgh2];
                                    tgh2 = [tgh2(1)-tcoef; tgh2];
                                end
                                cgh2(1) = 0;
                            end

                            for i = option.e  % Enhancing procedure
                                % option.e is the list of scaling factors
                                % i is the scaling factor
                                if i
                                    be = find(tgh2 & tgh2/i >= tgh2(1),1);
                                        % starting point of the substraction
                                        % on the X-axis

                                    if not(isempty(be))
                                        ic = interp1(tgh2,cgh2,tgh2/i);
                                            % The scaled autocorrelation
                                        ic(1:be-1) = 0;
                                        ic(find(isnan(ic))) = Inf;
                                            % All the NaN values are changed
                                            % into 0 in the resulting curve
                                        ic = max(ic,0);

                                        if debug
                                           hold off,plot(tgh2,cgh2)
                                        end

                                        cgh2 = cgh2 - ic;       
                                            % The scaled autocorrelation
                                            % is substracted to the initial one

                                        cgh2 = max(cgh2,0);
                                            % Half-wave rectification

                                        if debug
                                           hold on,plot(tgh2,ic,'r')
                                           hold on,plot(tgh2,cgh2,'g')
                                           drawnow
                                           figure
                                        end
                                    end
                                end
                            end

                            % The  temporary modifications are
                            % removed from the final curve
                            if inter>=deter
                                c(:,g,h) = cgh2(inter-deter+1:end);
                                if not(isempty(mv))
                                    c(:,g,h) = c(:,g,h) + mv;
                                end
                            else
                                c(:,g,h) = [zeros(deter-inter,1);cgh2];
                            end
                        end
                    end
                end
            end
            if freq
                if t(1,1) == 0
                    c = c(2:end,:,:);
                    t = t(2:end,:,:);
                end
                for i = 1:size(c,3)
                    c(:,:,i) = flipud(c(:,:,i));
                end
                t = flipud(1./t);
            end
            coeff{k}{l} = c;
            lags{k}{l} = t;
        end
    end
end
a = set(a,'Coeff',coeff,'Delay',lags,'Freq');
if freq
    a = set(a,'FreqDomain',1,'Abs','frequency (Hz)');
end


function [y orig] = eachchunk(orig,option,missing,postchunk)
option.scaleopt = 'none';
y = mirautocor(orig,option);


function y = combinechunk(old,new)
do = get(old,'Data');
do = do{1}{1};
dn = get(new,'Data');
dn = dn{1}{1};
if abs(size(dn,1)-size(do,1)) <= 2 % Probleme of border fluctuation
    mi = min(size(dn,1),size(do,1));
    dn = dn(1:mi,:,:);
    do = do(1:mi,:,:);
elseif length(dn) < length(do)
    dn(length(do),:,:) = 0; % Zero-padding
end
y = set(old,'ChunkData',do+dn);
