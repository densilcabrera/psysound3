function f = integrator(Fs, fastOrSlow)
% INTEGRATOR 
% 
% Generates and applies the integration filter to the input data
%
% For the theory behind this code, please refer to the document 'psy-sound.pdf'
%
% Author : Matt R. Flax <flatmax>
%          Jan. 2007 for the psysound project.
%
% Revised : Farhan Rizwi
%           Mostly cleanup of redundant code
%           July 2007 for the psysound project.
%
% input :
%         dataIn     - data vector
%         fastOrSlow - RC time constant is 'f' fast (125 ms) or 's'
%                      slow (1 s)
%         Fs         - sample rate of the data
%
% Time constant for the leaky integrator is tau. This is basically
% a low-pass filter with a bandwidth of 1/tau.
%
% This yields the following transfer function :
%                      1
%        H(s) =  ---------------
%                tau s  +   1

% Filter coeffecients
if ~isnumeric(fastOrSlow)
switch fastOrSlow
 case 'f' % fast leak - time constant = 125 ms
  tau = 125e-3;
 case 's' % slow leak - time constant = 1 s
  tau = 1;
 case 'i'
	tau = 35e-3; % impulse
	case 'p'
	tau = 50e-6;	
 otherwise
  error(['integrator: unknown leak case ' fastOrSlow]);
end
else
	tau = fastOrSlow;
end

% Exponential term
E = exp(-1/(tau*Fs));

% Filter numerator - with gain adjustment
b = 1 - E;

% Filter denominator
a = [1 -E];

% State vector
Z = [];

% Create run function handle
f = @run;

  function dataOut = run(dataIn)
  % Use filter to perform the integration
    [dataOut, Z] = filter(b, a, abs(dataIn), Z, 1);
  end
end % integrator
