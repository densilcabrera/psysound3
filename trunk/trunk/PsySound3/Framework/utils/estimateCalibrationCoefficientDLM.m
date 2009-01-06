function [calCoeff,RMS]=estimateCalibrationCoefficientDLM(calFileHandle,dBSPL)
% author : Matt Flax <flatmax @ http://www.flatmax.org> : Matt Flax is flatmax
%          Matt Flax @ http://www.flatmaxstudios.com
% March. 2007 : For the psysound.org project - a psychoacoustical analysis
%               package.

% find the calibration coefficient of a 'dBSPL' dB SPL calibration signal
% this version of the 'estimateCalibrationCoefficient' is specificly
% tailorder to work with Chalupper's DLM

% find the RMS power in the calibration file
% a] Read in multiple frames and average
% b] Using the average over many frames, work out the RMS power level

frameCnt=10;
N=size(calFileHandle.data);
N=max(N); % for multichannel sound files, assume length is the maximal dimension
if frameCnt*N>calFileHandle.samples
    prevFrameCnt=frameCnt;
    frameCnt=floor(calFileHandle.samples/N);
    message=sprintf('Maximum calibration block count is %d blocks. Normally Psysound uses %d blocks of data. Please record longer calibration files in future',...
        framCnt,prevFrameCnt);
    msgbox(message,'Short calibration file warning','warn')
end

technique2=1; % technique 2 is a non-averaged model for calibration
% a] Average many frames
calFileHandle=readData(calFileHandle);
data=zeros(size(calFileHandle.data));
if technique2
    for j=1:frameCnt
        data=[data; calFileHandle.data];
        if j<frameCnt % avoid loading the (frameCnt+1)'th frame
            calFileHandle=readData(calFileHandle);
        end
    end
    %maxData=max(abs(data))
    % b] Find the RMS level in dBSPL
    L=true_rms(data);
    RMS=L;
    boost_ammount=dBSPL-L;
    gain=invTrue_rms(boost_ammount);
    gain0dB=invTrue_rms(0);
    calCoeff=gain/gain0dB;
    return
    
    if 0
        % scale to unity.
        %data=data/maxData;
        sigSq=std(data)^2
        boostAmmount=(dBSPL-10*log10(sigSq/20e-6))
        boostIntensity=sqrt(20e-6*10.^(boostAmmount/10))
        calCoeff=boostIntensity
        RMS=1
        %return
    data=data.^2;
    % perform RMS

    RMS=norm(data)/sqrt(length(data))
    boostAmmount=(dBSPL-10*log10(RMS/20e-6))
    boostIntensity=sqrt(20e-6*10.^(boostAmmount/10))
    calCoeff=boostIntensity
    end
    return
else
    for j=1:frameCnt
        data=data+calFileHandle.data;
        if j<frameCnt % avoid loading the (frameCnt+1)'th frame
            calFileHandle=readData(calFileHandle);
        end
    end
    data=data/frameCnt; % complete the average

    maxData=max(abs(data))
    % b] Find the RMS level
    % scale to unity.
    data=data/maxData;
    % perform RMS
    RMS=norm(data)/sqrt(length(data))
end

%%%%%%%%%
%%% Work out required scaling coefficient
%%%%%%%%%

% power dB_SPL = 10*log10(int/20u)
if technique2
    constantPowerLevel=20e-6*10^(dBSPL/20);
    % find sine power level in intensity
    powerLevel=(constantPowerLevel);
    % power level = desiredIntensity * RMS
    desiredIntensity=powerLevel/RMS;
else
    dbfs=20*log10(1/20e-6);
    dBSPLCorrected=dBSPL+(107-dbfs)
    constantPowerLevel=20e-6*10^(dBSPLCorrected/10);
    % find sine power level in intensity
    powerLevel=(constantPowerLevel);
    % power level = desiredIntensity * RMS
    desiredIntensity=powerLevel/RMS;
end

% return the scaling coefficient
%calCoeff=desiredIntensity/maxData;
calCoeff=desiredIntensity;

% this step is taken directly from true_rms.m
calCoeff=calCoeff/(2*10^.5);
end

function L = true_rms(sig,dbfs)
% Author: Josef Chalupper (josef.chalupper@siemens.com)
% original version: 12.12.2000
% new version (with comments and examples): 6.1.2007

% L = true_rms(sig,dbfs);
% calculates level (dB SPL) of input sig according to calibration of DLM
% DLM assumes that a pure tone with a maximum amplitude of "1" has a level
% of 107 dB SPL ("dB full scale")
% optional: other calibrations can be used by setting dbfs to another value
% than 107
%
% Author: Josef Chalupper (josef.chalupper@siemens.com)
% original version: 12.12.2000
% new version (with comments and examples): 6.1.2007

sig=2*10^.5*sig;
signal=sig.^2;
summe=sum(signal);
peff=sqrt(summe/length(signal));
if peff == 0
    peff=realmin;
end
L=20*log10(peff/2e-5);

if nargin>1
    L=L-(107-dbfs);
end
end

function gain=invTrue_rms(dBSPL)
peff=2e-5*10.^(dBSPL/20);
gain=peff/(2*10^.5);
end