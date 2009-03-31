function dataOut = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%
% NOTE: Every window is the same size and comes appropriately
%       zero-padded both in front and at rear, whenever neccessary,
%       and so that is why the following is just a straightforward
%       call.

% the following should allow ACF of 1-chan files to be analysed, albeit
% inefficiently - not working yet.
% if size(dataIn,2) == 1
%   dataIn2 = cat(2, dataIn, dataIn);
% end

if size(dataIn,2) ~= 2
  dataOut = [];
  return;
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following is adapted from code provided by Shin-ichi Sato

% initial settings
reg_end_delay = 0.2; % Display range of ACF
reg_end_level = -10; % The peaks which have the amplitude more than this level aree used for the tau_e calculation


% read File
% [fname,pname] = uigetfile('*.wav','WAVE DATA');
% [y,Fs,Bits] = wavread(fname);
% file = fname;

% A-Weight filtering
% data = afilter(y,Fs); A-filtering is done elsewhere in the PsySound3
% implementaion
% use the following instead:
data = dataIn;
Fs = get(obj, 'fs');
len      = size(data, 1);
nFFT     =  2^(nextpow2(len + 1));

data1_L = cat(1,data(1:floor(length(data)/2)-1,1), zeros(size(data(floor(length(data)/2):end,1))));
data2_L = data(:,1);
data_L = [data1_L data2_L];

data1_R = cat(1,data(1:floor(length(data)/2)-1,2), zeros(size(data(floor(length(data)/2):end,2))));
data2_R = data(:,2);
data_R = [data1_R data2_R];

% FFT_L = fft(data_L);
% FFT_R = fft(data_R);
FFT_L = fft(data_L, nFFT);
FFT_R = fft(data_R, nFFT);
CONJ_L = conj(FFT_L(:,2));
CONJ_R = conj(FFT_R(:,2));

%IFFT
data = [CONJ_L(:,1).*FFT_L(:,1) ...
        CONJ_R(:,1).*FFT_R(:,1) ...
        CONJ_L(:,1).*FFT_R(:,1) ...
        CONJ_R(:,1).*FFT_L(:,1)];
IFFT = ifft(data);

%ACF
ACF = real(IFFT(:,1:2));
index = (0:1/Fs:(floor(length(ACF))-1)/Fs)';

NACF_L = ACF(1:floor(length(data)),1)./ACF(1,1);
NACF_R = ACF(1:floor(length(data)),2)./ACF(1,2);

acfplot_L = [index NACF_L];
acfplot_R = [index NACF_R];

log_acfplot_L = [index 10*log10(abs(NACF_L))];
log_acfplot_R = [index 10*log10(abs(NACF_R))];

%CCF
nrm = sqrt(ACF(1,1).*ACF(1,2));
lftplt = cat(2, (0:-1000/Fs:round((-1.0*0.01*Fs+1)*1000)/Fs)', ...
             real(IFFT(1:round(1.0*0.01*Fs),3))./nrm); 
rgtplt = cat(2, (1000./Fs:1000./Fs:round(1.0*0.01*Fs-1)*1000./Fs)', ...
             real(IFFT(2:round(1.0*0.01*Fs),4))./nrm);
ccfplot = cat(1, flipud(lftplt), rgtplt);

% exit here if zero data
if or(or(sum(abs(data_L(:,1)))==0,sum(abs(data_L(:,2)))==0), ...
        or(sum(abs(data_R(:,1)))==0,sum(abs(data_R(:,2)))==0))
   % Assign null outputs
  dataOut{1} = zeros(1,nFFT); % make row vector
  dataOut{2} = NaN;
  dataOut{3} = NaN;
  dataOut{4} = NaN;

  dataOut{5} = zeros(1,nFFT); % make row vector
  dataOut{6} = NaN;
  dataOut{7} = NaN;
  dataOut{8} = NaN;
  
  dataOut{9}  = zeros(1,2*0.01*Fs-1); % make row vector
  dataOut{10} = NaN;
  dataOut{11} = NaN;
  dataOut{12} = NaN;
  dataOut{13} = NaN;
    return;
end


% calculation of tau_1 and phi_1
% Left
trg_L = 1;     % initialise just in case
trg_R = trg_L; % initialise just in case

for i = 1:reg_end_delay*Fs/2
  if acfplot_L(i,2) < 0
    trg_L = i; break,
  end
end
peak_L = zeros(floor(reg_end_delay*Fs/2),2);
for i = trg_L : floor(reg_end_delay*Fs/2)-1
  if acfplot_L(i,2)>acfplot_L(i+1,2) & acfplot_L(i,2)>acfplot_L(i-1,2)
    if acfplot_L(i,1) > reg_end_delay
      break
    end
    peak_L(i,[1 2]) = acfplot_L(i,[1 2]);
    index_L = find(peak_L(:,2));
    peak_L = peak_L(index_L,:);
  end
end
[phi1_L,index_L] = max(peak_L(:,2));
tau1_L = peak_L(index_L,1);

% Right
for i = 1:reg_end_delay*Fs/2
  if acfplot_R(i,2) < 0
    trg_R = i;,break,
  end
end
peak_R = zeros(floor(reg_end_delay*Fs/2),2);
for i = trg_R : floor(reg_end_delay*Fs/2)-1
  if acfplot_R(i,2)>acfplot_R(i+1,2) & acfplot_R(i,2)>acfplot_R(i-1,2)
    if acfplot_R(i,1) > reg_end_delay
      break
    end
    peak_R(i,[1 2]) = acfplot_R(i,[1 2]);
    index_R = find(peak_R(:,2));
    peak_R = peak_R(index_R,:);
  end
end
[phi1_R,index_R] = max(peak_R(:,2));
tau1_R = peak_R(index_R,1);

% calculation of tau_e (effective duration of ACF)
% Left
if log_acfplot_L(floor(0.005*Fs):floor(reg_end_delay*Fs), 2) < -10
  peak_taue_L = zeros(floor(0.005*Fs),2);
  for i = trg_L : floor(0.005*Fs)-1
    if log_acfplot_L(i,2)>log_acfplot_L(i+1,2) & log_acfplot_L(i, ...
                                                        2)> ...
          log_acfplot_L(i-1,2)
      peak_taue_L(i,[1 2]) = log_acfplot_L(i,[1 2]);
      index_taue_L = find(peak_taue_L(:,2));
      peak_taue_L = peak_taue_L(index_taue_L,:);
    end
  end

  [phi_taue_L,index] = max(peak_taue_L(:,2));
  tau_taue_L = peak_taue_L(index,1);

  reg0_L = polyfit([0, tau_taue_L],[0, phi_taue_L],1);
  taue_L = (-10-reg0_L(1,2))/reg0_L(1,1);
  
  % xxx
  taue_R = taue_L;
  
else
  if tau1_L < 0.005
    for k = 2:floor(reg_end_delay/0.005)
      range_taue_L = log_acfplot_L(floor((k-1)*0.005*Fs+1):floor(k*0.005*Fs),[1 2]);
      [peak_taue_L(k,2),index] = max(range_taue_L(:,2));
      peak_taue_L(k,1) = range_taue_L(index,1);
    end
  else 
    if tau1_L > 0.05
      for k = 2:floor(reg_end_delay/0.05)
        range_taue_L = log_acfplot_L(floor((k-1)*0.05*Fs+1): ...
                                     floor(k*0.05*Fs),[1 2]);
        [peak_taue_L(k,2),index] = max(range_taue_L(:,2));
        peak_taue_L(k,1) = range_taue_L(index,1);
      end
    else 
      for k = 2:floor(reg_end_delay/(tau1_L*0.95))
        range_taue_L = log_acfplot_L(floor((k-1)*tau1_L*0.95*Fs+1): ...
                                     floor(k*tau1_L*0.95*Fs),[1 2]);
        [peak_taue_L(k,2),index] = max(range_taue_L(:,2));
        peak_taue_L(k,1) = range_taue_L(index,1);
      end
    end
  end
  max_L = max(peak_taue_L(1:end,2));
  reg_L = zeros(length(peak_taue_L),2);
  for i = 1:length(peak_taue_L)/2
    if peak_taue_L(i,2) > reg_end_level
      reg_L(i,:) = peak_taue_L(i,:);
    end
  end

  index_taue_L = find(reg_L(:,2));
  reg_L = reg_L(index_taue_L,:);
  
  reg0_L = polyfit(reg_L(:,1),reg_L(:,2),1);
  taue_L = (-10-reg0_L(1,2))/reg0_L(1,1);
  
  if taue_L < 0
    taue_L = 0.0001;
    % else taue_L = taue_L;
  end
  
  % acf_fac_L = [tau1_L phi1_L reg0_L];
  
  % Right
  if log_acfplot_R(floor(0.005*Fs):floor(reg_end_delay*Fs),2) < -10
    peak_taue_R = zeros(floor(0.005*Fs),2);
    for i = trg_R : floor(0.005*Fs)-1
      if log_acfplot_R(i,2)>log_acfplot_R(i+1,2) & log_acfplot_R(i, ...
                                                          2)> ...
            log_acfplot_R(i-1,2)
        peak_taue_R(i,[1 2]) = log_acfplot_R(i,[1 2]);
        index_taue_R = find(peak_taue_R(:,2));
        peak_taue_R = peak_taue_R(index_taue_R,:);
      end
    end

    [phi_taue_R,index] = max(peak_taue_R(:,2));
    tau_taue_R = peak_taue_R(index,1);

    reg0_R = polyfit([0, tau_taue_R],[0, phi_taue_R],1);
    taue_R = (-10-reg0_R(1,2))/reg0_R(1,1);

  else
    if tau1_R < 0.001
      for k = 2:floor(reg_end_delay/0.005)
        range_taue_R = log_acfplot_R(floor((k-1)*0.005*Fs+1):floor(k*0.005*Fs),[1 2]);
        [peak_taue_R(k,2),index] = max(range_taue_R(:,2));
        peak_taue_R(k,1) = range_taue_R(index,1);
      end
    else 
      if tau1_R > 0.05
        for k = 2:floor(reg_end_delay/0.05)
          range_taue_R = log_acfplot_R(floor((k-1)*0.05*Fs+1):floor(k*0.05*Fs),[1 2]);
          [peak_taue_R(k,2),index] = max(range_taue_R(:,2));
          peak_taue_R(k,1) = range_taue_R(index,1);
        end
      else 
        for k = 2:floor(reg_end_delay/(tau1_L*0.95))
          range_taue_R = log_acfplot_R(floor((k-1)*tau1_L*0.95*Fs+1):floor(k*tau1_L*0.95*Fs),[1 2]);
          [peak_taue_R(k,2),index] = max(range_taue_R(:,2));
          peak_taue_R(k,1) = range_taue_R(index,1);
        end
      end
    end
    max_R = max(peak_taue_R(1:end,2));
    reg_R = zeros(length(peak_taue_R),2);
    for i = 1:length(peak_taue_R)/2
      if peak_taue_R(i,2) > reg_end_level
        reg_R(i,:) = peak_taue_R(i,:);
      end
    end
    
    index_taue_R = find(reg_R(:,2));
    reg_R = reg_R(index_taue_R,:);

    reg0_R = polyfit(reg_R(:,1),reg_R(:,2),1);
    taue_R = (-10-reg0_R(1,2))/reg0_R(1,1);

    if taue_R < 0
      taue_R = 0.0001;
      % else taue_R = taue_R;
    end
    % acf_fac_R = [tau1_R phi1_R reg0_R];
  end
end
  %  calculation of IACC, tau_IACC, and W_IACC
  %IACC
  tau_center = ceil(length(ccfplot)/2);
  t1_lim = ceil(tau_center - 0.0005*Fs);
  t2_lim = floor(tau_center + 0.0005*Fs);
  [IACC,index] = max(ccfplot(t1_lim:t2_lim,2));

  %tau_IACC
tau  = ccfplot(t1_lim+index-1,1);

% %W_IACC
dlt = 0.1;
mns0 = ccfplot(1:t1_lim+index-1,:);
mns = flipdim(mns0,1);
for i = 1:length(mns)
   mns2(i,:) = mns(i,:);
   if mns(i,2) < (1-dlt)*IACC
       mns2(i+1,:) = mns(i+1,:);
      break
   end
end

pls = ccfplot(t1_lim+index-1:end,:);
for i=1:length(pls)
   pls2(i,:) = pls(i,:);
   if pls(i,2) < (1-dlt)*IACC
       pls2(i+1,:) = pls(i+1,:);
      break
   end
end

wpls = interp1(mns2(1:length(mns2),2),mns2(1:length(mns2),1),(1-0.1)*IACC,'cubic');
wmns = interp1(pls2(1:length(pls2),2),pls2(1:length(pls2),1),(1-0.1)*IACC,'cubic');
Wiacc = abs(wpls-wmns);

% iacf_fac = [IACC tau wpls wmns];


  % iacf_fac = [IACC tau];

  % figure
  % % NACF
  % subplot('Position',[0.1 0.6 0.4 0.3]),
  % plot(acfplot_L(1:floor(length(data))-1,1)*1000,acfplot_L(1:floor(length(data))-1,2));
  % title(['Left'])
  % xlabel('Delay time [ms]')
  % ylabel('nACF')
  % axis([0 reg_end_delay*1000 -1 1])
  % 
  % % subplot(2,2,2)
  % % plot(acfplot_R(1:floor(length(data))-1,1)*1000,acfplot_R(1:floor(length(data))-1,2));
  % % title(['Right'])
  % % xlabel('Delay time [ms]')
  % % ylabel('nACF')
  % % axis([0 reg_end_delay*1000 -1 1])
  % 
  % % NACF in logarithmic scale
  % x_L = 1:50:1000*reg_end_delay*Fs/2;
  % y_L = acf_fac_L(1,3)*x_L/1000 + acf_fac_L(1,4);  %taue_L
  % subplot('Position',[0.1 0.1 0.4 0.3]),
  % plot(log_acfplot_L(1:floor(length(data)/2)-1,1)*1000,log_acfplot_L(1:floor(length(data)/2)-1,2), x_L, y_L, 'r-.', reg_L(:,1).*1000, reg_L(:,2), '.r');
  % title(['t_e: ' num2str(taue_L*1000, 3),' ms'])
  % xlabel('Delay time [ms]')
  % ylabel('LogACF[dB]')
  % axis([0 reg_end_delay*1000 -15 0])
  % 
  % % x_R = 1:50:1000*reg_end_delay*Fs/2;
  % % y_R = acf_fac_L(1,3)*x_R/1000 + acf_fac_R(1,4);  %taue_L
  % % subplot(2,2,4)
  % % plot(log_acfplot_R(1:floor(length(data)/2)-1,1)*1000,log_acfplot_R(1:floor(length(data)/2)-1,2), x_R, y_R, 'r-.', reg_R(:,1).*1000, reg_R(:,2), '.r');
  % % title(['tau_e: ' num2str(taue_R*1000, 3),' ms'])
  % % xlabel('Delay time [ms]')
  % % ylabel('LogACF[dB]')
  % % axis([0 reg_end_delay*1000 -15 0])
  % 
  % % IACF
  % subplot('Position',[0.6 0.3 0.35 0.35])
  % plot(ccfplot(1:2*0.01*Fs-1,1),ccfplot(1:2*0.01*Fs-1,2), tau, IACC,'+r');
  % title(['IACC: ' num2str(IACC, 3)])
  % xlabel('Delay time [ms]')
  % ylabel('nIACF')
  % axis([-1 1  -1 1])

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  phi0  = nrm;

  % Assign outputs
  dataOut{1} = NACF_L'; % make row vector
  dataOut{2} = tau1_L;
  dataOut{3} = phi1_L;
  dataOut{4} = taue_L;

  dataOut{5} = NACF_R'; % make row vector
  dataOut{6} = tau1_R;
  dataOut{7} = phi1_R;
  dataOut{8} = taue_R;
  
  dataOut{9}  = ccfplot(1:2*0.01*Fs-1,2)'; % make row vector
  dataOut{10} = phi0;
  dataOut{11} = IACC;
  dataOut{12} = tau;
  dataOut{13} = Wiacc;

% end processWindow
