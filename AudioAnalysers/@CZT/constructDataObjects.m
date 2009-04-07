function obj = constructDataObjects(obj, dataBuffer, TimePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% Analogous to assignoutputs
%

fs = get(obj, 'fs');
N  = get(obj, 'windowLength') - 1;
N2 = N/2;
N3 = N2+0.5;
tstep   = diff(TimePoints(1:2));
numWindows   = getNumWindows(obj);
chan = get(obj,'channels');
if chan == 1

    if ~isempty(obj.cztF)
        f1 = obj.cztF(1); f2 = obj.cztF(2);
        fBin = (f2-f1)/N;
        frequencies = (f1:fBin:f2);


        % Create the Time Power Spectrum
        PowSpec = power2dB(dataBuffer.PowSpec.get()) + getlevelOffset(obj);
        tSpec   = createDataObject('tSpectrum', frequencies, PowSpec, TimePoints);
        tSpec.Name = 'CZT Spectrogram';

        % Create the averaged Spectrum
        avPowSpec = mean(PowSpec, 1);
        avSpec    = createDataObject('Spectrum', frequencies, avPowSpec);
        avSpec.Name  = 'CZT Average Power Spectrum';

			if obj.complexAverage
        
        % Create the phase-optimised average complex spectra
        Phase = dataBuffer.PhaseSpec.get();
        Magnitude = dataBuffer.MagnitudeSpec.get();
        [PhaseCorrectedSpec1, PhaseCorrectedSpec2, PhaseCorrectedSpec3] = ...
            complexaverage(PowSpec, avPowSpec, numWindows, N3, Phase, Magnitude);

        avSpecComplex1    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec1+ getlevelOffset(obj));
        avSpecComplex1.Name  = 'CZT Complex Av Spectrum (Method 1)';

        avSpecComplex3    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec3+ getlevelOffset(obj));
        avSpecComplex3.Name  = 'CZT Complex Av Spectrum (Local - Method 3)';

        avSpecComplex2    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec2+ getlevelOffset(obj));
        avSpecComplex2.Name  = 'CZT Complex Av Spectrum (Power-weighted - Method 2)';

			end

        % Create Time series for the higher-order statistics
        moments   = dataBuffer.moments.get();
        SD        = dataBuffer.SD.get();
        kurtosis  = dataBuffer.kurtosis.get();
        skewness  = dataBuffer.skewness.get();
        level     = power2dB(dataBuffer.level.get()) + getlevelOffset(obj);
        bigMatrix = [moments, SD, skewness, kurtosis, level];
        tags      = {'CZT Spectral Centroid (1st Moment)', 'Frequency (Hz)' ;...
            'CZT Spectral 2nd Moment', 'Frequency (Hz)' ;...
            'CZT Spectral 3rd Moment', 'Frequency (Hz)' ;...
            'CZT Spectral 4th Moment', 'Frequency (Hz)' ;...
            'CZT Standard deviation',  'Frequency (Hz)' ;...
            'CZT Skewness',            'units'; ...
            'CZT Kurtosis',            'units'; ...
            'CZT Level', 'dB'};

    else
        frequencies = (fs/N) * (0:N2); % row vect

        % Create the Time Power Spectrum
        PowSpec = power2dB(dataBuffer.PowSpec.get()) + getlevelOffset(obj);
        tSpec   = createDataObject('tSpectrum', frequencies, PowSpec, TimePoints);
        tSpec.Name = 'Spectrogram';

        % Create the averaged Spectrum
        avPowSpec = mean(PowSpec, 1);
        avSpec    = createDataObject('Spectrum', frequencies, avPowSpec);
        avSpec.Name  = 'Average Power Spectrum';

	if obj.complexAverage
        
      
        % Create the phase-optimised average complex spectra
        Phase = dataBuffer.PhaseSpec.get();
        Magnitude = dataBuffer.MagnitudeSpec.get();
        [PhaseCorrectedSpec1, PhaseCorrectedSpec2, PhaseCorrectedSpec3] = ...
            complexaverage(PowSpec, avPowSpec, numWindows, N3, Phase, Magnitude);

        avSpecComplex1    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec1+ getlevelOffset(obj));
        avSpecComplex1.Name  = 'Complex Av Spectrum (Method 1)';

        avSpecComplex3    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec3+ getlevelOffset(obj));
        avSpecComplex3.Name  = 'Complex Av Spectrum (Local - Method 3)';


        avSpecComplex2    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec2+ getlevelOffset(obj));
        avSpecComplex2.Name  = 'Complex Av Spectrum (Power-weighted - Method 2)';
end

        % Create Time series for the higher-order statistics
        moments   = dataBuffer.moments.get();
        SD        = dataBuffer.SD.get();
        kurtosis  = dataBuffer.kurtosis.get();
        skewness  = dataBuffer.skewness.get();
        level     = power2dB(dataBuffer.level.get()) + getlevelOffset(obj);
        bigMatrix = [moments, SD, skewness, kurtosis, level];
        tags      = {'Spectral Centroid (1st Moment)', 'Hz' ;...
            'Spectral 2nd Moment', 'Hz' ;...
            'Spectral 3rd Moment', 'Hz' ;...
            'Spectral 4th Moment', 'Hz' ;...
            'Standard deviation',  'Hz' ;...
            'Skewness',            ''; ...
            'Kurtosis',            ''; ...
            'Level', 'dB'};

    end


    tsArray = {};
    for i=1:length(tags)
        ts = createDataObject('tSeries', bigMatrix(:, i));
        ts = set(ts, 'Name', tags{i, 1});

        % Set the increment
        ts.TimeInfo.Increment = tstep;

        % Stick this tag in the data info so that we pick it up as ylabel
        % in PlotResult
        ts.DataInfo.Units = tags{i, 2};

        % Assign to cell array
        tsArray{i} = ts;
    end

    % Assign outputs to the object
    % out = {tSpec, avSpec, avPhaseCorrectedSpec, tsArray{:}};
    out = {tSpec, avSpec, tsArray{:}};
		if obj.complexAverage
        
      out = {out{:}, avSpecComplex1, avSpecComplex2, avSpecComplex3};
		end
    obj = set(obj, 'output', out);

%%%%%%%%%%%%%%%%%%% TWO CHANNEL PROCESSING BELOW %%%%%%%%%%%%%%%%
else % if chan ==1
    if ~isempty(obj.cztF)
        f1 = obj.cztF(1); f2 = obj.cztF(2);
        fBin = (f2-f1)/N;
        frequencies = (f1:fBin:f2);


        % Create the Time Power Spectrum
        RawPowSpecL = dataBuffer.PowSpecL.get();
        RawPowSpecR = dataBuffer.PowSpecR.get();
        RawPowSpec = 0.5.*(RawPowSpecL + RawPowSpecR);
        PowSpec = power2dB(RawPowSpec) + getlevelOffset(obj);
        PowSpecL = power2dB(RawPowSpecL)+ getlevelOffset(obj);
        PowSpecR = power2dB(RawPowSpecR)+ getlevelOffset(obj);
        
        tSpecLR   = createDataObject('tSpectrum', frequencies, PowSpec, TimePoints);
        tSpecLR.Name = 'CZT Spectrogram LR Average';
        
        tSpecL   = createDataObject('tSpectrum', frequencies, PowSpecL, TimePoints);
        tSpecL.Name = 'CZT Spectrogram Left';
        
        tSpecR   = createDataObject('tSpectrum', frequencies, PowSpecR, TimePoints);
        tSpecR.Name = 'CZT Spectrogram Right';
        
        tSpecDiff   = createDataObject('tSpectrum', frequencies, PowSpecR-PowSpecL, TimePoints);
        tSpecDiff.Name = 'CZT Spectrogram R-L Difference';

        % Create the averaged Spectrum
        avPowSpec = power2dB(mean(RawPowSpec, 1))+ getlevelOffset(obj);
        avSpecLR    = createDataObject('Spectrum', frequencies, avPowSpec);
        avSpecLR.Name  = 'CZT Average Power Spectrum LR';
        
        avPowSpecL = power2dB(mean(RawPowSpecL, 1))+ getlevelOffset(obj);
        avSpecL    = createDataObject('Spectrum', frequencies, avPowSpecL);
        avSpecL.Name  = 'CZT Average Power Spectrum Left';
        
        avPowSpecR = power2dB(mean(RawPowSpecR, 1))+ getlevelOffset(obj);
        avSpecR    = createDataObject('Spectrum', frequencies, avPowSpecR);
        avSpecR.Name  = 'CZT Average Power Spectrum Right';
        
        avSpecDiff    = createDataObject('Spectrum', frequencies, avPowSpecR-avPowSpecL);
        avSpecDiff.Name  = 'CZT Average Power Spectrum L-R difference';

        if obj.complexAverage
        % Create the phase-optimised average complex spectra Left
        PhaseL = dataBuffer.PhaseSpecL.get();
        MagnitudeL = dataBuffer.MagnitudeSpecL.get();
        [PhaseCorrectedSpec1L, PhaseCorrectedSpec2L, PhaseCorrectedSpec3L] = ...
            complexaverage(PowSpecL, avPowSpecL, numWindows, N3, PhaseL, MagnitudeL);

        avSpecComplex1L    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec1L+ getlevelOffset(obj));
        avSpecComplex1L.Name  = 'CZT Complex Av Spectrum L (Method 1)';

        avSpecComplex3L    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec3L+ getlevelOffset(obj));
        avSpecComplex3L.Name  = 'CZT Complex Av Spectrum L (Local - Method 3)';


        avSpecComplex2L    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec2L+ getlevelOffset(obj));
        avSpecComplex2L.Name  = 'CZT Complex Av Spectrum L (Power-weighted - Method 2)';

        % Create the phase-optimised average complex spectra Right
        PhaseR = dataBuffer.PhaseSpecR.get();
        MagnitudeR = dataBuffer.MagnitudeSpecR.get();
        [PhaseCorrectedSpec1R, PhaseCorrectedSpec2R, PhaseCorrectedSpec3R] = ...
            complexaverage(PowSpecR, avPowSpecR, numWindows, N3, PhaseR, MagnitudeR);

        avSpecComplex1R    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec1R+ getlevelOffset(obj));
        avSpecComplex1R.Name  = 'CZT Complex Av Spectrum R (Method 1)';

        avSpecComplex3R    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec3R+ getlevelOffset(obj));
        avSpecComplex3R.Name  = 'CZT Complex Av Spectrum R (Local - Method 3)';


        avSpecComplex2R    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec2R+ getlevelOffset(obj));
        avSpecComplex2R.Name  = 'CZT Complex Av Spectrum R (Power-weighted - Method 2)';
      end

        % Create Time series for the higher-order statistics Left
        momentsL   = dataBuffer.momentsL.get();
        SDL        = dataBuffer.SDL.get();
        kurtosisL  = dataBuffer.kurtosisL.get();
        skewnessL  = dataBuffer.skewnessL.get();
        levelL     = power2dB(dataBuffer.levelL.get()) + getlevelOffset(obj);
        bigMatrixL = [momentsL, SDL, skewnessL, kurtosisL, levelL];
        tags      = {'CZT L Spectral Centroid (1st Moment)', 'Frequency (Hz)' ;...
            'CZT L Spectral 2nd Moment', 'Frequency (Hz)' ;...
            'CZT L Spectral 3rd Moment', 'Frequency (Hz)' ;...
            'CZT L Spectral 4th Moment', 'Frequency (Hz)' ;...
            'CZT L Standard deviation',  'Frequency (Hz)' ;...
            'CZT L Skewness',            'units'; ...
            'CZT L Kurtosis',            'units'; ...
            'CZT L Level', 'dB'};
        
                % Create Time series for the higher-order statistics Right
        momentsR   = dataBuffer.momentsR.get();
        SDR        = dataBuffer.SDR.get();
        kurtosisR  = dataBuffer.kurtosisR.get();
        skewnessR  = dataBuffer.skewnessR.get();
        levelR     = power2dB(dataBuffer.levelR.get()) + getlevelOffset(obj);
        bigMatrixR = [momentsR, SDR, skewnessR, kurtosisR, levelR];
        tagsR      = {'CZT Spectral Centroid (1st Moment)', 'Frequency (Hz)' ;...
            'CZT R Spectral 2nd Moment', 'Frequency (Hz)' ;...
            'CZT R Spectral 3rd Moment', 'Frequency (Hz)' ;...
            'CZT R Spectral 4th Moment', 'Frequency (Hz)' ;...
            'CZT R Standard deviation',  'Frequency (Hz)' ;...
            'CZT R Skewness',            'units'; ...
            'CZT R Kurtosis',            'units'; ...
            'CZT R Level', 'dB'};

    else
        frequencies = (fs/N) * (0:N2); % row vect

        % Create the Time Power Spectrum
        RawPowSpecL = dataBuffer.PowSpecL.get();
        RawPowSpecR = dataBuffer.PowSpecR.get();
        RawPowSpec = 0.5.*(RawPowSpecL + RawPowSpecR);
        PowSpec = power2dB(RawPowSpec) + getlevelOffset(obj);
        PowSpecL = power2dB(RawPowSpecL)+ getlevelOffset(obj);
        PowSpecR = power2dB(RawPowSpecR)+ getlevelOffset(obj);
        
        tSpecLR   = createDataObject('tSpectrum', frequencies, PowSpec, TimePoints);
        tSpecLR.Name = 'Spectrogram LR Average';
        
        tSpecL   = createDataObject('tSpectrum', frequencies, PowSpecL, TimePoints);
        tSpecL.Name = 'Spectrogram Left';
        
        tSpecR   = createDataObject('tSpectrum', frequencies, PowSpecR, TimePoints);
        tSpecR.Name = 'Spectrogram Right';
        
        tSpecDiff   = createDataObject('tSpectrum', frequencies, PowSpecR-PowSpecL, TimePoints);
        tSpecDiff.Name = 'Spectrogram R-L Difference';

        % Create the averaged Spectrum
        avPowSpec = power2dB(mean(RawPowSpec, 1))+ getlevelOffset(obj);
        avSpecLR    = createDataObject('Spectrum', frequencies, avPowSpec);
        avSpecLR.Name  = 'Average Power Spectrum LR';
        
        avPowSpecL = power2dB(mean(RawPowSpecL, 1))+ getlevelOffset(obj);
        avSpecL    = createDataObject('Spectrum', frequencies, avPowSpecL);
        avSpecL.Name  = 'Average Power Spectrum Left';
        
        avPowSpecR = power2dB(mean(RawPowSpecR, 1))+ getlevelOffset(obj);
        avSpecR    = createDataObject('Spectrum', frequencies, avPowSpecR);
        avSpecR.Name  = 'Average Power Spectrum Right';
        
        avSpecDiff    = createDataObject('Spectrum', frequencies, avPowSpecR-avPowSpecL);
        avSpecDiff.Name  = 'Average Power Spectrum L-R difference';
 if obj.complexAverage
       
        % Create the phase-optimised average complex spectra Left
        PhaseL = dataBuffer.PhaseSpecL.get();
        MagnitudeL = dataBuffer.MagnitudeSpecL.get();
        [PhaseCorrectedSpec1L, PhaseCorrectedSpec2L, PhaseCorrectedSpec3L] = ...
            complexaverage(PowSpecL, avPowSpecL, numWindows, N3, PhaseL, MagnitudeL);

        avSpecComplex1L    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec1L+ getlevelOffset(obj));
        avSpecComplex1L.Name  = 'Complex Av Spectrum L (Method 1)';

        avSpecComplex3L    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec3L+ getlevelOffset(obj));
        avSpecComplex3L.Name  = 'Complex Av Spectrum L (Local - Method 3)';


        avSpecComplex2L    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec2L+ getlevelOffset(obj));
        avSpecComplex2L.Name  = 'Complex Av Spectrum L (Power-weighted - Method 2)';

        % Create the phase-optimised average complex spectra Right
        PhaseR = dataBuffer.PhaseSpecR.get();
        MagnitudeR = dataBuffer.MagnitudeSpecR.get();
        [PhaseCorrectedSpec1R, PhaseCorrectedSpec2R, PhaseCorrectedSpec3R] = ...
            complexaverage(PowSpecR, avPowSpecR, numWindows, N3, PhaseR, MagnitudeR);

        avSpecComplex1R    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec1R+ getlevelOffset(obj));
        avSpecComplex1R.Name  = 'Complex Av Spectrum R (Method 1)';

        avSpecComplex3R    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec3R+ getlevelOffset(obj));
        avSpecComplex3R.Name  = 'Complex Av Spectrum R (Local - Method 3)';


        avSpecComplex2R    = createDataObject('Spectrum', frequencies, PhaseCorrectedSpec2R+ getlevelOffset(obj));
        avSpecComplex2R.Name  = 'Complex Av Spectrum R (Power-weighted - Method 2)';

end

        % Create Time series for the higher-order statistics Left
        momentsL   = dataBuffer.momentsL.get();
        SDL        = dataBuffer.SDL.get();
        kurtosisL  = dataBuffer.kurtosisL.get();
        skewnessL  = dataBuffer.skewnessL.get();
        levelL     = power2dB(dataBuffer.levelL.get()) + getlevelOffset(obj);
        bigMatrixL = [momentsL, SDL, skewnessL, kurtosisL, levelL];
        tags      = {'L Spectral Centroid (1st Moment)', 'Frequency (Hz)' ;...
            'L Spectral 2nd Moment', 'Frequency (Hz)' ;...
            'L Spectral 3rd Moment', 'Frequency (Hz)' ;...
            'L Spectral 4th Moment', 'Frequency (Hz)' ;...
            'L Standard deviation',  'Frequency (Hz)' ;...
            'L Skewness',            'units'; ...
            'L Kurtosis',            'units'; ...
            'L Level', 'dB'};
        
                % Create Time series for the higher-order statistics Right
        momentsR   = dataBuffer.momentsR.get();
        SDR        = dataBuffer.SDR.get();
        kurtosisR  = dataBuffer.kurtosisR.get();
        skewnessR  = dataBuffer.skewnessR.get();
        levelR     = power2dB(dataBuffer.levelR.get()) + getlevelOffset(obj);
        bigMatrixR = [momentsR, SDR, skewnessR, kurtosisR, levelR];
        tagsR      = {'Spectral Centroid (1st Moment)', 'Frequency (Hz)' ;...
            'R Spectral 2nd Moment', 'Frequency (Hz)' ;...
            'R Spectral 3rd Moment', 'Frequency (Hz)' ;...
            'R Spectral 4th Moment', 'Frequency (Hz)' ;...
            'R Standard deviation',  'Frequency (Hz)' ;...
            'R Skewness',            'units'; ...
            'R Kurtosis',            'units'; ...
            'R Level', 'dB'};

    end


    tsArrayL = {};
    for i=1:length(tags)
        ts = createDataObject('tSeries', bigMatrixL(:, i));
        ts = set(ts, 'Name', tags{i, 1});

        % Set the increment
        ts.TimeInfo.Increment = tstep;

        % Stick this tag in the data info so that we pick it up as ylabel
        % in PlotResult
        ts.DataInfo.Units = tags{i, 2};

        % Assign to cell array
        tsArrayL{i} = ts;
    end
        tsArrayR = {};
    for i=1:length(tags)
        ts = createDataObject('tSeries', bigMatrixR(:, i));
        ts = set(ts, 'Name', tags{i, 1});

        % Set the increment
        ts.TimeInfo.Increment = tstep;

        % Stick this tag in the data info so that we pick it up as ylabel
        % in PlotResult
        ts.DataInfo.Units = tags{i, 2};

        % Assign to cell array
        tsArrayR{i} = ts;
    end

    % Assign outputs to the object
    % out = {tSpec, avSpec, avPhaseCorrectedSpec, tsArray{:}};
    out = {tSpecLR, tSpecL, tSpecR, tSpecDiff, ...
        avSpecLR, avSpecL, avSpecR, avSpecDiff, ...
        tsArrayL{:}, tsArrayR{:}};
		if obj.complexAverage
			out = {out{:},      avSpecComplex1L, avSpecComplex2L, avSpecComplex3L, ...
             avSpecComplex1R, avSpecComplex2R, avSpecComplex3R};
		end   

 obj = set(obj, 'output', out);
end
% end constructDataObjects
%