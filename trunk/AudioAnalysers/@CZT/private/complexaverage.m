function [PhaseCorrectedSpec1, PhaseCorrectedSpec2, PhaseCorrectedSpec3] = ...
    complexaverage(PowSpec, avPowSpec, numWindows, N3, Phase, Magnitude)

% These methods of complex averaging are implemented on a trial basis at
% present, and may change in future implementations. - densil 21Oct2008
    DiffPhase = diff(Phase,1,1);
    
    % TYPE 1 - COMPLEX AVERAGE BASED ON OVERALL AVERAGE PHASE
    % this method of complex averaging finds the 'mean' phase difference for each
    % spectrum component between every window of the analysis. This 'mean'
    % is done for real and imaginary components of the phase angle, which
    % are then recombined into a phase angle. This mean difference multiplied 
    % by the window number is then subtracted from the original phase
    % spectrum, and combined with the magnitude spectrum prior to taking
    % the complex average of the spectra.
    % 
    % This method is sensitive to steady state tones throughout the recording, or 
    % other perfectly periodic characteristics in the recording. It
    % suppresses spectral components that have random or varying phase changes between
    % windows.
    
    % real and imaginary phase difference between windows
    DiffRealAngle      = cos(DiffPhase);
    DiffImAngle        = sin(DiffPhase);
    % average phase difference between windows - not weighted by power
    AvPhaseStep1        = angle(complex(mean(DiffRealAngle,1),mean(DiffImAngle,1)));
    Phase1 = zeros(numWindows, N3);
    for i = 1:numWindows
        Phase1(i,:) = Phase(i,:) - AvPhaseStep1.*i;
    end
    PhaseCorrectedSpec1 = power2dB(abs(mean(Magnitude .* exp(j*Phase1),1)).^2);
        

    
    % TYPE 3 - COMPLEX AVERAGE BASED ON LOCAL AVERAGE PHASE
    % This method compares the phase values for each window to those of the
    % surrounding eight windows (four on either side). If there is no
    % difference, a phase angle of 0 is used for the complex spectrum
    % average. Differences result in non-zero phase angles which will tend
    % to suppress the average for that spectral component.
    %
    % The value of this method is that it is sensitive to local
    % periodicities (e.g., musical tones from an instrument), which may not
    % be reflected by long term periodicities. Of course, the periodicities
    % should span at least nine windows to be picked up in the present
    % implementation.
    RunningAvLength = 9;
    Phase3 = zeros(numWindows-1-RunningAvLength, N3);
    if numWindows > RunningAvLength+1
        for i=1:numWindows-1-RunningAvLength
            Phase3(i,:) = 10 * ( ...
            (DiffRealAngle(i+4,:) ...
                -((DiffRealAngle(i,:) + DiffRealAngle(i+1,:) + DiffRealAngle(i+2,:)+ ...
                DiffRealAngle(i+3,:) + DiffRealAngle(i+5,:)+ DiffRealAngle(i+6,:) + ...
                DiffRealAngle(i+7,:) + DiffRealAngle(i+8,:))./(RunningAvLength-1)))...
            + (DiffImAngle(i+4,:) ...
                -((DiffImAngle(i,:)+ DiffImAngle(i+1,:) + DiffImAngle(i+2,:)+ ...
                DiffImAngle(i+3,:) + DiffImAngle(i+5,:)+ DiffImAngle(i+6,:) + ...
                DiffImAngle(i+7,:) + DiffImAngle(i+8,:))./(RunningAvLength-1))));
        end
        PhaseCorrectedSpec3 = power2dB(abs(mean(Magnitude(4:numWindows-RunningAvLength+2,:) ...
            .* exp(j*Phase3),1)).^2);
    else
        PhaseCorrectedSpec3 = zeros(1,N3);
    end %if
    
    % TYPE 2 - COMPLEX AVERAGE BASED ON POWER-WEIGHTED AVERAGE PHASE
    % This is the same as method 1, except that the average phase is weighted by
    % the time-varying power of each spectral component.
    %
    % In many cases this yields similar results to method 1.
    % Code below is written to preserve memory, and so reuses some
    % variables from method 1.
    for i = 1:numWindows-1
        DiffRealAngle(i,:) = DiffRealAngle(i,:) .* (PowSpec(i,:)+PowSpec(i+1,:))./2;
        DiffImAngle(i,:) = DiffImAngle(i,:) .* (PowSpec(i,:)+PowSpec(i+1,:))./2;
    end
    AvPhaseStep2 = angle(complex(sum(DiffRealAngle,1)./(avPowSpec .* (numWindows-1)), ...
        sum(DiffImAngle,1)./(avPowSpec .* (numWindows-1))));
    for i = 1:numWindows
        Phase1(i,:) = Phase(i,:) - AvPhaseStep2.*i;
    end
    PhaseCorrectedSpec2 = power2dB(abs(mean(Magnitude .* exp(j*Phase1),1)).^2);
