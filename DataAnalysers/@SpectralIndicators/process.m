function process(obj, hObj)
% PROCESS  This method is called when the Process button is pressed
%
% Get the tree nodes

[TSObj, dataObjS, node, uit] = getDataFromNode(obj, hObj, 'tSeries');

specdata = TSObj.data;
f   = TSObj.Freq;
t = TSObj.Time;

% 
[ER, SPR, Alpha, SB] = Spectrality(specdata, f, t);

timestep = diff(t);
timestep = timestep(1);
% Repackage
dataObjS.DataObj = createDataObject('tSeries',ER');
dataObjS.DataObj.TimeInfo.Increment = timestep;
dataObjS.DataObj.Name = 'Energy Ratio';
dataObjS.DataObj.DataInfo.Unit = 'dB';
% Add to node in tree
out = addToDataAnalysisFolder(obj, getValue(node), dataObjS, uit);


% Repackage
dataObjS.DataObj = createDataObject('tSeries',SPR');
dataObjS.DataObj.TimeInfo.Increment = timestep;
dataObjS.DataObj.Name = 'Singing Power Ratio';
dataObjS.DataObj.DataInfo.Unit = 'dB';
% Add to node in tree
out = addToDataAnalysisFolder(obj, getValue(node), dataObjS, uit);

% Repackage
dataObjS.DataObj = createDataObject('tSeries',Alpha');
dataObjS.DataObj.TimeInfo.Increment = timestep;
dataObjS.DataObj.Name = 'Alpha';
dataObjS.DataObj.DataInfo.Unit = 'dB';
% Add to node in tree
out = addToDataAnalysisFolder(obj, getValue(node), dataObjS, uit);

% Repackage
dataObjS.DataObj = createDataObject('tSeries', SB' );
dataObjS.DataObj.TimeInfo.Increment = timestep;
dataObjS.DataObj.Name = 'Spectral Balance';
dataObjS.DataObj.DataInfo.Unit = 'dB';
% Add to node in tree
out = addToDataAnalysisFolder(obj, getValue(node), dataObjS, uit);


% collapseAndUnLoadTree(obj, p);
% Try this instead of the above collapse
% openTree(obj, p, out);

% EOF


function [ER, SPR, Alpha, SB] = Spectrality(specdata, f, t)
% [ER, SPR, Centroid] = Spectrality(signal, Fs, measPeriod, windowLength)
%
%% Spectrality: Spectral measures of sound. 
%
% Spectral measures of sound are calculated using a hanning window with a
% specified time step and window length. ER is the 'energy ratio' calculated
% by using the ratio of energy in the 0-2kHz band against the 2-4kHz band.
% SPR is similar but instead of the sum it uses the peak. Thus it is totally 
% dependent on the windowLength used. 
%
% Musical Sound Analysis Template
% 2006 Sam Ferguson
%
% Energy Ratio (ER) is defined by Thorpe (2001)
% Singing Power Ratio (SPR) is defined by Omori (1996)
% ALPHA by Frokjaer-Jensen (1976)
% Spectral Balance (SB) by Ternstrom et al. (2006)

    % How many Frames?
    numberOfFrames = length(t);
specdata = specdata';
    fftMatrix = 10.^(specdata/10);

    % FOR ER find indexes between 0-2kHz and 2-4kHz
    lowFreq = find(f >= 0 & f < 2000); 
    hiFreq  = find(f >= 2000 & f <= 4000);
		% for ER get sum of signal in high and low Frequency. 
		ER = 10*log10(sum(fftMatrix(hiFreq,:))) - 10*log10(sum(fftMatrix(lowFreq,:)));

    % FOR ALPHA find indexes between 0-1kHz and 1-6kHz
    lowFreq = find(f >= 0 & f < 1000); 
    hiFreq  = find(f >= 1000 & f <= 6000);
		Alpha = 10*log10(sum(fftMatrix(hiFreq,:))) - 10*log10(sum(fftMatrix(lowFreq,:)));

    % FOR SB find indexes between 100Hz-1kHz and 2-6kHz (leaving out 1-2kHz)
    lowFreq = find(f >= 100 & f < 1000); 
    hiFreq  = find(f >= 2000 & f <= 6000);
		SB = 10*log10(sum(fftMatrix(hiFreq,:))) - 10*log10(sum(fftMatrix(lowFreq,:)));

    % for SPR get max of signal in high and lowFrequency.
    lowFreq = find(f >= 0 & f < 1000); 
    hiFreq  = find(f >= 1000 & f <= 6000);
    SPR = 10*log10(max(fftMatrix(hiFreq,:))) - 10*log10(max(fftMatrix(lowFreq,:))); 
  

