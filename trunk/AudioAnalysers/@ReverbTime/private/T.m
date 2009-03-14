function [RevInteg,Time] =T(A,fs)

RevInteg=flipud(A.^2);
RevInteg=cumsum(RevInteg);
RevInteg=flipud(RevInteg);
RevInteg=10*log10(RevInteg/((20*10^-6)^2));

ts=timeseries(A);
ts.time=ts.time/fs;
Time = ts.time;

T0=find(RevInteg>=max(RevInteg-0.01),1,'last'); T0Pressure=RevInteg(T0); T0Time=T0/fs;
T5=find(RevInteg>=max(RevInteg-5.01),1,'last'); T5Pressure=RevInteg(T5); T5Time=T5/fs;
T10=find(RevInteg>=max(RevInteg-10.01),1,'last'); T10Pressure=RevInteg(T10); T10Time=T10/fs;
T25=find(RevInteg>=max(RevInteg-25.01),1,'last'); T25Pressure=RevInteg(T25); T25Time=T25/fs;
T35=find(RevInteg>=max(RevInteg-35.01),1,'last'); T35Pressure=RevInteg(T35); T35Time=T35/fs;

% EDT=(T10Time-T0Time)*6
% T20=(T25Time-T5Time)*3
% T30=(T35Time-T5Time)*2
% 
% 
% plot(ts.time, RevInteg, T0Time, T0Pressure, 'rx', T5Time, T5Pressure, 'ro', T10Time, T10Pressure, 'rx', T25Time, T25Pressure, 'ro', T35Time, T35Pressure,'ro')
        
        