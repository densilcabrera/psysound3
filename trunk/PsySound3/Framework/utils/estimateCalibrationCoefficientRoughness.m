function [calCoeff,RMS]=estimateCalibrationCoefficient(calFileHandle,dBSPL)
% author : Matt Flax <flatmax @ http://www.flatmax.org> : Matt Flax is flatmax
%          Matt Flax @ http://www.flatmaxstudios.com
% March. 2007 : For the psysound.org project - a psychoacoustical analysis
%               package.

% find the calibration coefficient of a 'dBSPL' dB SPL calibration signal

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
% a] accumulate many frames
calFileHandle=readData(calFileHandle);
data=zeros(size(calFileHandle.data));
for j=1:frameCnt
    %data=data+calFileHandle.data;
    data=[data; calFileHandle.data];
    if j<frameCnt % avoid loading the (frameCnt+1)'th frame
        calFileHandle=readData(calFileHandle);
    end
end

% perform RMS
RMS=norm(data)/sqrt(length(data));

%%%%%%%%%
%%% Work out required scaling coefficient
%%%%%%%%%


% their calibration from their files
%SPLdes	=	str2num(get(AdjL,'string'));
%AmpCorr	=	db2amp(dBSPL-83)/rms(source(:,1));
desiredIntensity =	db2amp(dBSPL-83)/RMS;
%source	=	AmpCorr*source;

% return the scaling coefficient
%calCoeff=desiredIntensity/max(abs(data))
calCoeff=desiredIntensity;
end
