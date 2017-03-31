function varargout = mircepstrum(orig,varargin)
%   s = mircepstrum(x) computes the cepstrum, which indicates
%       periodicities, and is used for instance for pitch detection.
%   x can be either a spectrum, an audio signal, or the name of an audio file.
%   Optional parameter:
%       mircepstrum(...,'Min',min) specifies the lowest delay taken into
%           consideration, in seconds.
%           Default value: 0.0002 s (corresponding to a maximum frequency of 
%               5 kHz).
%       mircepstrum(...,'Max',max) specifies the highest delay taken into
%           consideration, in seconds.
%           Default value: 0.05 s (corresponding to a minimum frequency of 
%               20 Hz).
%       mircepstrum(...,'Freq') represents the cepstrum in the frequency 
%           domain.

if nargin==0 % In order for Psysound to get the Name field with PossAnalyser
    s=struct;
    s.phase = [];
    s.freq=[];
    
base=mirdata();
s=class(s,'mircepstrum',base);
s=set(s,'Name','Mirtoolbox (mircepstrum)');
varargout={s};

else
    
    
    if isstruct(orig) && nargin==1
% Adapted for Psysound3 (does this situation actually exist for MirToolbox classes?)

    cl=struct;
    cl.phase = [];
    cl.freq=[];
    
base=mirdata(orig);
cl=class(cl,'mircepstrum',base);
cl=set(cl,'Name','Mirtoolbox (mircepstrum)'); 

varargout = {cl};
    else
        mi.key = 'Min';
        mi.type = 'Integer';
        mi.default = 0.0002;
        mi.unit = {'s','Hz'};
        mi.defaultunit = 's';
        mi.opposite = 'ma';
    option.mi = mi;

        ma.key = 'Max';
        ma.type = 'Integer';
        ma.default = .05;
        ma.unit = {'s','Hz'};
        ma.defaultunit = 's';
        ma.opposite = 'mi';
    option.ma = ma;
        
        fr.key = 'Freq';
        fr.type = 'Boolean';
        fr.default = 0;
    option.fr = fr;

        complex.key = 'Complex';
        complex.type = 'Boolean';
        complex.default = 0;
    option.complex = complex;

specif.option = option;

specif.defaultframelength = 0.05;
specif.defaultframehop = 0.5;

varargout = mirfunction(@mircepstrum,orig,varargin,nargout,specif,@init,@main);

    end %For Psysound3
end %For Psysound3


function [x type] = init(x,option)
if not(isamir(x,'mircepstrum'))
    x = mirspectrum(x);
end
type = 'mircepstrum';


function c = main(orig,option,postoption)
if iscell(orig)
    orig = orig{1};
end
c.phase = [];
if isa(orig,'mircepstrum')
    c.freq = orig.freq;
else
    c.freq = 0;
end
c = class(c,'mircepstrum',mirdata(orig));
c = purgedata(c);
c = set(c,'Title','Cepstrum','Abs','quefrency (s)','Ord','magnitude');
c=set(c,'Name','Mirtoolbox (mircepstrum)'); %For Psysound3

if isa(orig,'mircepstrum')
    if option.ma < Inf || option.mi > 0 || get(orig,'FreqDomain')
        mag = get(orig,'Magnitude');
        pha = get(orig,'Phase');
        que = get(orig,'Quefrency');
        for h = 1:length(mag)
            for k = 1:length(mag{h})
                if get(orig,'FreqDomain')
                    mag{h}{k} = flipud(mag{h}{k});
                    que{h}{k} = flipud(1./que{h}{k});
                    pha{h}{k} = flipud(pha{h}{k});
                end
                range = find(que{h}{k}(:,1,1) <= option.ma & ...
                             que{h}{k}(:,1,1) >= option.mi);
                mag{h}{k} = mag{h}{k}(range,:,:);
                pha{h}{k} = pha{h}{k}(range,:,:);
                que{h}{k} = que{h}{k}(range,:,:);
            end
        end
        c = set(c,'Magnitude',mag,'Phase',pha,'Quefrency',que,'FreqDomain',0);
    end
    c = modif(c,option);
elseif isa(orig,'mirspectrum')
    mag = get(orig,'Magnitude');
    pha = get(orig,'Phase');
    f = get(orig,'Sampling');
    q = cell(1,length(mag));
    for h = 1:length(mag)
        len = ceil(option.ma*f{h});
        start = ceil(option.mi*f{h})+1;
        q{h} = cell(1,length(mag{h}));
        for k = 1:length(mag{h})
            m = mag{h}{k}.*exp(1i*pha{h}{k});
            m = [m(1:end-1,:) ; conj(flipud(m))];  % Reconstitution of the complete abs(FFT)
            if not(option.complex)
                m = abs(m);
            end
            m = log(m);
            c0=fft(m);
            q0=repmat((0:(size(c0,1)-1))'/f{k},[1,size(m,2),size(m,3)]);
            len = min(len,floor(size(c0,1)/2));
            mag{h}{k} = abs(c0(start:len,:,:));
            if option.complex
                pha{h}{k} = unwrap(angle(c0(start:len,:,:)));    
            else
                pha{h}{k} = nan(size(c0(start:len,:,:)));
            end
            q{h}{k} = q0(start:len,:,:);
        end
    end
    c = set(c,'Magnitude',mag,'Phase',pha,'Quefrency',q);
    c = modif(c,option);
end


function c = modif(c,option)
mag = get(c,'Magnitude');
que = get(c,'Quefrency');
if option.fr && not(get(c,'FreqDomain'))
    for k = 1:length(mag)
        for l = 1:length(mag{k})
            m = mag{k}{l};
            q = que{k}{l};
            if not(isempty(m))
                if q(1,1) == 0
                    m = m(2:end,:,:);
                    q = q(2:end,:,:);
                end
                m = flipud(m);
                q = flipud(1./q);
            end
            mag{k}{l} = m;
            que{k}{l} = q;
        end
    end
    c = set(c,'FreqDomain',1,'Abs','frequency (Hz)');
end
c = set(c,'Magnitude',mag,'Quefrency',que,'Freq');