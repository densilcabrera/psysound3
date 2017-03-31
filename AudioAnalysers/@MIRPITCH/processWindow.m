function dataOut = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%
% We are using raw mode - the whole file to be analysed is stored 
% in dataIn.

if dataIn == 1
  dataOut = 1;
  return;
end




fs = get(obj, 'fs');

% oDataRate = get(obj, 'outputDataRate');


% get the options of the Mirpitch algorithm chosen by the user (in the GUI)
OptionStr=get(obj,'OptionStr');


% Core of The Analyser 
dataOut=miraudio(dataIn,fs);


[p, ac] = mirpitch(dataOut,OptionStr{:});

w = mirinharmonicity(dataOut); % example for the new release manual
inh = mirgetdata(w); % mirgetdata extracts the numeric data of w, which is a "mirscalar" object.

z = mirroughness(dataOut);
rough = mirgetdata(z);


% Numerical Data extraction from the MIRPITCH object p
acData=get(ac,'Data');
freq=get(ac,'Pos');
fp=get(ac,'FramePos');

%Get the frequency peaks selected by the mirpitch algorithm and display
%them (by order of Amplitude)


% fprintf('\n \n \n  \t \t \t************************************ \n \t \t The peak(s) (in Hz) selected by the MirPitch algorithm is/are \n \t \t \t************************************ \n \n \n');
%  
% 
%  displ=mirgetdata(p);
%  if size(disp,2)>1
%      displ
%  else
%      displ'
%  end
% 
% % for i=1:length(p(1,:))
% % fprintf('%f \n',p(:,i))
% % fprintf('\n')
% % end
% 
% fprintf('\n \n \t \t \t************************************  \n \n \n')


acData=acData{1}{1};
freq=freq{1}{1};
frequencies=freq(:,1);



dataOut = {acData,p,fp,frequencies,inh,rough};
end







