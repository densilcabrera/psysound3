function [PureTonalness, ComplexTonalness, Multiplicity, Salience]= ...
    calculateParncuttMeasures(vPitch, sPitch)

% the input virtual (vPitch) and spectral (sPitch) pitches are of
% the form [frequency salience]

% Taken from the original Psysound2 Pascal listing and ported to Matlab.

% Authors: Matt Flax <flatmax@> flatmaxstudios, Sam Ferguson, Densil
% Cabrera
% Jan. 2008

% Initialise minimal output arguments in case of early return
PureTonalness = 0;
Multiplicity  = 0;
ComplexTonalness = 0;
multsum = 0;
Salience = 0;

% assemble and sort the pitches
[r, c] = size(vPitch);
if r > 0
  vPitch=[vPitch ones(r,1)]; % add ones to indicate virtual pitches
end

[r, c]=size(sPitch);
if r > 0
  sPitch=[sPitch zeros(r,1)]; % add zeros to indicate spectral pitches
end

if isempty(vPitch) && isempty(sPitch)
%  disp('no pitches, spectral nor virtual - returning');
  return
end

pitches = [vPitch; sPitch];
[r, c]  = size(pitches);

pitches = sortrows(pitches,1); % sort the pitches according to frequency

ptsum   = 0;
for j = 1:r
  ptsum   = ptsum + pitches(j,2) ^ 2;
  multsum = multsum + pitches(j,2);
  if pitches(j,3) && ((pitches(j,2) / 6.2) > ComplexTonalness)
    ComplexTonalness=pitches(j,2) / 6.2;
  end
end

PureTonalness = sqrt(ptsum / 5.2);
Multiplicity  = sqrt(multsum / pitches(1,2));

% Densil's version Jan 08
% 
maxweight = max(pitches(:, 2));
Salience = pitches(:, 1);
Salience(:, 2) = pitches(:, 2) / sqrt(maxweight * multsum);


end % function
