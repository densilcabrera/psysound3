function fHandles = weightings(N, Fs, weightingType)
%  WEIGHTING
% Generates and applies the weighting filters to fileHandle.data
%
% For the theory behind this code, please refer to the document 'psy-sound.pdf'
%
% Author : Matt R. Flax <flatmax>
%          Dec. 2006 for the psysound project.
% Revised : Farhan Rizwi
%           Converted to use nested functions
%           July 2007 for the psysound project
%
% This algorithm produces A, B, C and D weighting filters as required.

% These are the exported function handles
fHandles.run  = @run;
fHandles.show = @show;

% Setup filter weigthings 
weightings = struct('a', [], 'b', []);

% Popuplate the weightings struct
generateWFilters();

% State vector
Z = [];

  %%%%%%%%%%%%%%%%%%%%
  % NESTED FUNCTIONS %
  %%%%%%%%%%%%%%%%%%%%
  function dataOut = run(dataIn)
  % filter the data - alway operate on columns
    [dataOut, Z] = filter(weightings.b, weightings.a, dataIn, Z, 1);
  end % end run

  function show
  % Displays the weightings
    fprintf(' %s weightings:\n', weightingType);

    % Disp A weightings
    fprintf('  A =\n');
    for i=1:length(weightings.a)
      fprintf(' \t% .5f\n', weightings.a(i));
    end
    
    % Disp B weightings
    fprintf('  B =\n');
    for i=1:length(weightings.b)
      fprintf(' \t% .5f\n', weightings.b(i));
    end
    
    fprintf('\n');
  end % end show
  
  function generateWFilters
  % Generate the filters

  % the frequency of each Fourier bin
  f = (0:Fs/2/(N-1):Fs/2);

  % take a perceptual sampling of the frequency domain - for design
  % purposes 
  eMin   = freq2erb(min(f)); % ERB min
  eMax   = freq2erb(max(f)); % ERB max
  eScale = eMin:(eMax-eMin)/(length(f)-1):eMax; % ERB scale
  fScale = erb2freq(eScale); % frequencies sample according to a
                             % linear ERB scale

  fLinear = f; % save the linear frequency scale
  f = fScale;  % switch the reference frequencies to be f

  s = i*2*pi*f; % set up the s-plane variable

  % determine the weighting filter frequency responses
  % convienient to accuratly set the desired filter orders (n,m)
  % here to.
  switch weightingType
   case 'A' % A-weighting filter
    K = 7.39705e9;
    freqResp = K*s.^4./((s+129.4).^2 .* (s+676.7).*(s+4636).*(s+76655).^2);
    
    n = 4; % at most we need a 4'th order filter
    m = n; 
  
    zrs =  [0; 0; 0; 0];
    pls = -[129.4; 129.4; 676.7; 4636; 76655; 76655];
   
   case 'B' % B-weighting filter
    K = 5.99185e9;
    freqResp = K*s.^3./((s+129.4).^2 .* (s+995.9).*(s+76655).^2);

    n = 3; % at most we need a 4'th order filter
    m = 4; 
   
    zrs =  [0; 0; 0];
    pls = -[129.4; 129.4; 995.9; 76655; 76655];

   case 'C' % C-weighting filter
    K = 5.91797e9;
    freqResp = K*s.^2./((s+129.4).^2 .*(s+76655).^2);

    n = 2; % at most we need a 4'th order filter
    m = 4; 

    zrs =  [0; 0];
    pls = -[129.4; 129.4; 76655; 76655];

   case 'D' % D-weighting filter
    K = 91104.32;
    freqResp = K*s.*(s.^2+6532*s+4.0975e7)./((s+1776.3) .*(s+7288.5).*(s.^2+21514*s+3.8836e8));

    n = 3; % at most we need a 4'th order filter
    m = 4; 
   
    zrs = [0; roots([1 6532 4.0975e7])];
    pls = [-1776.3; -7288.5; roots([1 21514 3.8836e8])];
    
	 case 'R'
		% Filter weightings from [1], pg 12
		% These are defined for 48k
		b = [1 -2 1];
		a = [1 -1.99004745483398 0.99007225036621];

		% Use direct substituition of the definition of the z-transform
		% (z=exp(s*T)) to recalculate coeffecients for a different sampling
		% rate
		% Note: This could be another option for pre-filtering

		if Fs ~= 48e3;
  	poles = roots(a);
  
  	% Make polynomial after fixing up the roots
  	% 
  	% z = exp(s*T) --> s = ln(z)/T
  	%
  	% s = ln(z1)/T1 = ln(z2)/T2  -->  z2 = exp(ln(z1)*T2/T1)
  	%
  	a = poly(exp(log(poles)*48e3/Fs));
  
  	% Note that the two zeros at 1 remain there.
  	% Note also, that the negligible high frequency gain adjustment
  	% is ignored.
		end

		weightings.a = a;
    weightings.b = b;
    
    % ... and we're done
    return		
		
   case 'Z' % un-weighted
    weightings.a = 1;
    weightings.b = 1;
    
    % ... and we're done
    return
    
   otherwise % unknown request
    error(['weightingType=''' weightingType ''' is unknown. Options ' ,...
           'are ''A'', ''B'', ''C'' or ''D'''])
  end
  
  m = m+1;
  n = n*2;
  m = m*2;
  
  % the total frequency response
  totalResp = freqResp;

  % look at the responses
  if 0; displayResponses(f, freqResp, totalResp); end
  
  % generate the filter
  if (2*f ~= Fs) % correct small frequency error on the last fourier sample.
    f(end) = Fs/2;
  end
  
  % if 1 % use invfreqz method for IIR filter design.
  %  [b, a] = invfreqz(totalResp, 2*f/Fs*pi, n, m, [], 1024);
  % else
  % if m>n; n=m; end
  %  [b, a] = yulewalk(n,2*f/Fs,totalResp);
  % end

  %
  % Use the bilinear transformation to discretize the above
  % transfer function.
  %
  warnState = warning('off', 'MATLAB:nearlySingularMatrix');
  [Zd, Pd, Kd] = bilinear(zrs, pls, K, Fs);
  [b, a] = zp2tf(Zd, Pd, Kd);
  warning(warnState);

  % Assign
  weightings.a = a;
  weightings.b = b;
  
  % check how the filter performs against the desired frequency response
  if 0; displayFilterResponse(f,a,b,totalResp,Fs); end
  if 0; displayImpulseResponses(f,a,b,totalResp,Fs); end

  if 0
    % Plot frequency respones
    % figure;
    mag = freqz(b, a, 2*pi*f/Fs);

    % subplot(211);
    % semilogx(f, 20*log10(abs(freqResp)), f, 20*log10(abs(mag)));
    % This is very strange, sometimes Matlab does not want to plot
    % using a log scale?
    semilogx(f, 10*log10(abs(mag).^2));
    grid;
    title([weightingType, ' weighted']);
    xlabel('Freq (Hz)');
    ylabel('dB');
    % legend('Original','fitted', 'Location', 'NorthWest');
    
    % subplot(212);
    % Plot error
    % semilogx(f, abs(freqResp) - abs(mag));
    % title('Absolute error');
    % xlabel('Freq (Hz)');
    % ylabel('Magnitude');
    % grid
  end
  
  % rescale ... if desired
  % work out the difference from unity
  % factor=sum(ones(size(abs(totalResp))))/sum(abs(totalResp))
  % b=b*factor;

  % fvtool(b,a) % use this to look at the filtes
  end % generateFilters
end % createWeightingsFunc

%
% Sub-functions
%
function displayResponses(f,freqResp, totalResp)
figure(1);
subplot(2,1,1) % plot the frequency spectrum
semilogx(f,20*log10(abs(totalResp)),'r'); hold on
semilogx(f,20*log10(abs(freqResp)),'g');  hold off
legend('total Response', 'weighting filter response');
title('Frequency response'); xlabel('f (Hz)'); ylabel('dB');
subplot(2,1,2) % plot the phase spectrum
semilogx(f,angle(totalResp),'r'); hold on
semilogx(f,angle(freqResp),'g'); hold off
legend('total Response', 'weighting filter response');
title('Phase response'); xlabel('f (Hz)'); ylabel('phase');
subplot
disp('paused');
pause
end

function displayFilterResponse(f,a,b,totalResp,Fs)
signal=randn(1,length(f)*2); signal=signal/max(abs(signal));
SIGNAL=abs(fft(signal));
SIGNAL=SIGNAL(1:length(f));
output=filter(b,a,signal);
OUTPUT=abs(fft(output));
OUTPUT=OUTPUT(1:length(f));
fLinear=0:Fs/2/(length(OUTPUT)-1):Fs/2; % the frequency of each Fourier bin
totalRespResamp=interp1(f,abs(totalResp),fLinear);
figure;
subplot(3,1,1)
semilogx(fLinear,SIGNAL,'r');
title('input signal')
ylabel('magnitude')
subplot(3,1,2)
semilogx(fLinear,OUTPUT,'r');
title('filtered signal')
ylabel('magnitude')
subplot(3,1,3)
semilogx(fLinear,totalRespResamp);
xlabel('f (Hz)')
ylabel('magnitude')
title('desired freq. resp.')
subplot
end

function displayImpulseResponses(f,a,b,totalResp,Fs)
signal=[1 zeros(1,2*length(f)-1)];
SIGNAL=abs(fft(signal));
SIGNAL=SIGNAL(1:length(f));
output=filter(b,a,signal);
OUTPUT=abs(fft(output));
OUTPUT=OUTPUT(1:length(f));
fLinear=0:Fs/2/(length(OUTPUT)-1):Fs/2; % the frequency of each Fourier bin

figure;
subplot(3,1,1)
semilogx(fLinear,SIGNAL,'r');
title('input signal')
ylabel('magnitude')
subplot(3,1,2)
semilogx(fLinear,OUTPUT,'r');
title('filtered signal')
ylabel('magnitude')
subplot(3,1,3)
totalRespResamp=interp1(f,abs(totalResp),fLinear);
semilogx(fLinear,totalRespResamp);
xlabel('f (Hz)')
ylabel('magnitude')
title('desired freq. resp.')
subplot
figure;
subplot
temp=abs(OUTPUT-totalRespResamp)./totalRespResamp*100;
semilogx(fLinear(1:end),temp(1:end))
title('Error between the impulse and frequency response')
xlabel('f (Hz)')
end
