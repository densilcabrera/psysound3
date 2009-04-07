function obj = assignOutputs(obj, dataIn, dataBuf, s)
% ASSIGNOUTPUTS This method updates the output structure with each
%               new block of analysed data.  The output structures
%               (and any underlying data objects, eg. timeseries)
%               should already be allocated and all that should be
%               needed is assignment

% Convenience variables
N   = get(obj, 'windowLength') - 1;
N2  = N/2;
fs  = get(obj, 'fs');
numWindows   = getNumWindows(obj);
chan = get(obj,'channels');



if chan ==1
    % Moment calculations
    if ~isempty(obj.cztF)
        % We already have the frequency range
        f1 = obj.cztF(1); f2 = obj.cztF(2);
        fBin = (f2-f1)/N;
        frequencies = (f1:fBin:f2);
        DFT = dataIn / N;
    else
        DFT = dataIn(1:end/2) / N;
        frequencies = (fs/N) * (0:N2); % row vect
    end

    PowSpec            = abs(DFT) .^ 2;
if obj.complexAverage
    % IF COMPLEX AVERAGE THEN DO THE FOLLOWING
    Magnitude          = abs(DFT);
    Phase              = angle(DFT);
    dataBuf.MagnitudeSpec.assign(Magnitude);
    dataBuf.PhaseSpec.assign(Phase);
    % END
end

    % Assign the power spectrum
    dataBuf.PowSpec.assign(PowSpec);

    % Assign the level
    Power = sum(PowSpec);
    dataBuf.level.assign(Power);

    % Normalize the PowSpectrum
    PowSpec = PowSpec/Power;

    % Mean, which is also the 1st Moment
    meanPowSpec = frequencies * PowSpec';

    moments = meanPowSpec;
    % Calculate higher-order moments
    n = 4;  % Change to get higher ones
    for i=2:n
        moments(1,i) = ((frequencies - meanPowSpec) .^ i) * PowSpec';
    end

    % Assign moments
    dataBuf.moments.assign(moments);

    % SD - this is the square root of the 2nd moment which is the
    %      variance
    SD = sqrt(moments(2));
    dataBuf.SD.assign(SD);

    % Skewness and Kurtosis
    % This are the 3rd and 4th standardised moments, respectively
    dataBuf.skewness.assign(moments(3)/ (SD^3));
    dataBuf.kurtosis.assign(moments(4)/ (SD^4));
end    % if chan == 1



if chan == 2
    % Moment calculations
    if ~isempty(obj.cztF)
        % We already have the frequency range
        f1 = obj.cztF(1); f2 = obj.cztF(2);
        fBin = (f2-f1)/N;
        frequencies = (f1:fBin:f2);
        DFT = dataIn ./ N;
    else
        DFT = dataIn(:,1:end/2) ./ N;
        frequencies = (fs/N) * (0:N2); % row vect
    end

    PowSpecL            = abs(DFT(1,:)) .^ 2;
    PowSpecR            = abs(DFT(2,:)) .^ 2;
% 
% if obj.complexAverage
%     % IF COMPLEX AVERAGE THEN DO THE FOLLOWING
%     MagnitudeL          = abs(DFT(1,:));
%     PhaseL              = angle(DFT(1,:));
%     dataBuf.MagnitudeSpecL.assign(MagnitudeL);
%     dataBuf.PhaseSpecL.assign(PhaseL);
%     
%     MagnitudeR          = abs(DFT(2,:));
%     PhaseR              = angle(DFT(2,:));
%     dataBuf.MagnitudeSpecR.assign(MagnitudeR);
%     dataBuf.PhaseSpecR.assign(PhaseR);
%     % END
% end

    % Assign the power spectrum
    dataBuf.PowSpecL.assign(PowSpecL);
    dataBuf.PowSpecR.assign(PowSpecR);

    % Assign the level
    PowerL = sum(PowSpecL);
    dataBuf.levelL.assign(PowerL);
    
    PowerR = sum(PowSpecR);
    dataBuf.levelR.assign(PowerR);

    % Normalize the PowSpectrum
    PowSpecL = PowSpecL/PowerL;
    PowSpecR = PowSpecR/PowerR;

    % Mean, which is also the 1st Moment
    meanPowSpecL = frequencies * PowSpecL';
    meanPowSpecR = frequencies * PowSpecR';

    momentsL = meanPowSpecL;
    % Calculate higher-order moments
    n = 4;  % Change to get higher ones
    for i=2:n
        momentsL(1,i) = ((frequencies - meanPowSpecL) .^ i) * PowSpecL';
    end

    % Assign moments
    dataBuf.momentsL.assign(momentsL);

    % SD - this is the square root of the 2nd moment which is the
    %      variance
    SDL = sqrt(momentsL(2));
    dataBuf.SDL.assign(SDL);

    % Skewness and Kurtosis
    % This are the 3rd and 4th standardised moments, respectively
    dataBuf.skewnessL.assign(momentsL(3)/ (SDL^3));
    dataBuf.kurtosisL.assign(momentsL(4)/ (SDL^4));
    
    momentsR = meanPowSpecR;
    % Calculate higher-order moments
    n = 4;  % Change to get higher ones
    for i=2:n
        momentsR(1,i) = ((frequencies - meanPowSpecR) .^ i) * PowSpecR';
    end

    % Assign moments
    dataBuf.momentsR.assign(momentsR);

    % SD - this is the square root of the 2nd moment which is the
    %      variance
    SDR = sqrt(momentsR(2));
    dataBuf.SDR.assign(SDR);

    % Skewness and Kurtosis
    % This are the 3rd and 4th standardised moments, respectively
    dataBuf.skewnessR.assign(momentsR(3)/ (SDR^3));
    dataBuf.kurtosisR.assign(momentsR(4)/ (SDR^4));

end % if chan == 2
% end assignOutputs