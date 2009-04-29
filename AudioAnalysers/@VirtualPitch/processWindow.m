function dataOut = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%

% Sampling rate
fs = get(obj, 'fs');

% make frequencies from 440 - midi notes
%%%% This is set up for equal temperament, but COULD be changed 
%%%% for other temperament schemes here. 
i = -68:47;
notes = log2(440*2 .^ (i / 12));

% Window already has Hanning applied
% Compute the Power Spectrum
PowSpec = abs(fft(dataIn)) .^ 2;

% Call the terhardt pitch analysis module function
[vPitch, sPitch] = terhardtVPitch(fs, PowSpec);

VP = zeros(1, length(notes));
if ~isempty(vPitch)
  VP = createSpectrum(vPitch, notes);
end

SP = zeros(1, length(notes));
if ~isempty(sPitch)
  SP = createSpectrum(sPitch, notes);
end

% run Parncutt measures
[PureTonalness, ComplexTonalness, Multiplicity, Salience] = ...
    calculateParncuttMeasures(vPitch, sPitch);

S = zeros(1, length(notes));
CP = zeros(1, 12);
if ~isempty(vPitch) || ~isempty(sPitch)
  S = createSpectrum(Salience, notes);
  %CP = createChromaPattern(S);
end

% Create a cell array to return
dataOut = {VP, SP, PureTonalness, ComplexTonalness, Multiplicity, S, CP};

% end processWindow



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local nested function
%
function out = createSpectrum(pitch, notes)
% get the frequencies in this frame - convert to midi
notesInFrame = log2(pitch(:,1));

% get the corresponding saliences
saliencesInFrame = pitch(:,2);

% setup vector
out = zeros(1, length(notes));
for j =1:length(notesInFrame)
  % which two are we looking at
  lowNoteIndex  = find(notes < notesInFrame(j), 1, 'last');
  highNoteIndex = find(notes > notesInFrame(j), 1, 'first');
  
  % what's the difference
  difference = notes(highNoteIndex) - notes(lowNoteIndex);

  % Multiply by distance from each of the notes
  out(lowNoteIndex)  = saliencesInFrame(j) * ...
      ((notes(highNoteIndex) - notesInFrame(j))/difference);

  out(highNoteIndex) = saliencesInFrame(j) * ...
      ((notesInFrame(j) - notes(lowNoteIndex))/difference);
end
% end createSpectrum




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local nested function
function out = createChromaPattern(notespectrum)
% output with two columns: chroma, sum of salience
chromaoffset = 0; % integer to change numerical assignment of chroma
out = zeros(1,12); % set up vector
chromapattern = zeros(2,12);
% chromapattern(:,1) = 1:12 - 1 + chromaoffset; % chroma in simple assending order
chromapattern(1:12,1) = mod((1:12 - 1 + chromaoffset) * 7, 12); % chroma in cycle of fifths order
% sum the saliences of each chroma
for j = 1:length(notespectrum)
    chromapattern((mod(j,12)+1),2) = chromapattern((mod(j,12)+1),2)...
        + notespectrum(j);
chromapattern = sortrows(chromapattern,1);
out(1:12,1) = chromapattern(1:12,2);
end %end createChromaPattern

