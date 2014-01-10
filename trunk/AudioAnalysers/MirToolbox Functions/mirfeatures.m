function r = mirfeatures(x,varargin)
%   f = mirfeatures(x) computes a large set of features from one or several
%       audio files. x can be either the name of an audio file, or the
%       'Folder' keyword.
%   mirfeatures(...,'Stat') returns the statistics of the features instead
%       of the complete features themselves.
%   mirfeatures(...,'Segment',t) segments the audio sequence at the 
%       temporal positions indicated in the array t (in s.), and analyzes
%       each segment separately.

%(not available yet)
%   mirfeatures(...,'Filterbank',nc) computes the analysis on each channel
%       of a filterbank decomposition.
%       Default value: nc = 5
%   mirfeatures(...,'Frame',...) 
%   mirfeatures(...,'Normal')
%   mirfeatures(...,'Sampling',s)
%   miraudio options (Extract, ...)

[stat,nchan,segm,feat] = scanargin(varargin);

if isa(x,'miraudio') || isa(x,'mirdesign')
    a = miraudio(x,'Normal'); % normalize with respect to RMS energy 
                              % in order to consider timbre independently of
                             % energy
else
    a = miraudio('Design','Normal');
end

if not(isempty(segm))
    a = mirsegment(a,segm);
end



% DYNAMICS
% --------

r.dynamics.rms = mirrms(a,'Frame');
% Perceived dynamics: spectral slope?

% RHYTHM
% ------

%r.fluctuation = mirstruct; % not in Matlab Central version
%r.fluctuation.tmp.f = mirfluctuation(a,'Summary');
%r.fluctuation.peak = mirpeaks(r.fluctuation.tmp.f,'Total',1);%only one?
%r.fluctuation.centroid = mircentroid(r.fluctuation.tmp.f);

r.rhythm = mirstruct;
r.rhythm.tmp.onsets = mironsets(a);

%r.rhythm.eventdensity = ...

r.rhythm.tempo = mirtempo(r.rhythm.tmp.onsets,'Frame');
%r.rhythm.pulseclarity = mirpulseclarity(r.tmp.onsets,'Frame');
    % Should use the second output of mirtempo.

attacks = mironsets(r.rhythm.tmp.onsets,'Attacks');
r.rhythm.attack.time = mirattacktime(attacks);
r.rhythm.attack.slope = mirattackslope(attacks);

% TIMBRE
% ------

f = mirframe(a,.05,.5);
r.spectral = mirstruct;
r.spectral.tmp.s = mirspectrum(f);
%pitch = mirpitch(a,'Frame',.05,.5);

r.spectral.centroid = mircentroid(r.spectral.tmp.s);
r.spectral.brightness = mirbrightness(r.spectral.tmp.s);
r.spectral.spread = mirspread(r.spectral.tmp.s);
r.spectral.skewness = mirskewness(r.spectral.tmp.s);
r.spectral.kurtosis = mirkurtosis(r.spectral.tmp.s);
r.spectral.rolloff95 = mirrolloff(r.spectral.tmp.s,95);
r.spectral.rolloff85 = mirrolloff(r.spectral.tmp.s,85);
r.spectral.spectentropy = mirentropy(r.spectral.tmp.s);
r.spectral.flatness = mirflatness(r.spectral.tmp.s);

r.spectral.roughness = mirroughness(r.spectral.tmp.s);
r.spectral.irregularity = mirregularity(r.spectral.tmp.s);
%r.spectral.inharmonicity = mirinharmonicity(r.spectral.tmp.s,'f0',pitch);

%r.spectral.mfcc = mirmfcc(r.spectral.tmp.s); %not in Matlab Central version
%r.spectral.dmfcc = mirmfcc(r.spectral.mfcc,'Delta');
%r.spectral.ddmfcc = mirmfcc(r.spectral.dmfcc,'Delta');

r.timbre.zerocross = mirzerocross(f);
r.timbre.lowenergy = mirlowenergy(f);
r.timbre.spectralflux = mirflux(f);

% PITCH
% -----

r.tonal = mirstruct;
r.tonal.tmp.chromagram = mirchromagram(a,'Frame','Wrap',0,'Pitch',0);
r.tonal.chromagram.peak=mirpeaks(r.tonal.tmp.chromagram,'Total',1);
r.tonal.chromagram.centroid=mircentroid(r.tonal.tmp.chromagram);

% TONALITY/HARMONY
% ----------------

keystrengths = mirkeystrength(r.tonal.tmp.chromagram);
[k r.tonal.keyclarity] = mirkey(keystrengths,'Total',1);
%r.tonal.keyclarity = k{2};
r.tonal.mode = mirmode(keystrengths);
r.tonal.hcdf = mirhcdf(r.tonal.tmp.chromagram);

if stat
    r = mirstat(r);
    % SHOULD COMPUTE STAT OF CURVES FROM FRAMED_DECOMPOSED HIGH FEATURES
end
    
if not(isa(x,'miraudio')) && not(isa(x,'mirdesign'))
    r = mireval(r,x);
end


function [stat,nchan,segm,feat] = scanargin(v)
stat = 0;
nchan = 1;
segm = [];
feat = {};
i = 1;
while i <= length(v)
    arg = v{i};
    if ischar(arg) && strcmpi(arg,'Filterbank')
        i = i+1;
        if i <= length(v)
            nchan = v{i};
        else
            nchan = 10;
        end
    elseif ischar(arg) && strcmpi(arg,'Stat')
        i = i+1;
        if i <= length(v)
            stat = v{i};
        else
            stat = 1;
        end
    elseif ischar(arg) && strcmpi(arg,'Segment')
        i = i+1;
        if i <= length(v)
            segm = v{i};
        else
            segm = 1;
        end
    else
        feat{end+1} = arg;
    end    
    i = i+1;
end