function out = dlm(fs, flag)
% [N, main_N, spec_N]=dlm(sig, HL, k);
% Dynamic Loudness Model (Chalupper 2001)
% calculates loudness N, main loudness main_N and specific loudness spec_N
% for a signal sig (fs=44.1 kHz, 107 dBSPL FS RMS(i.e. a sinusoid
% with amplitudes ranging from -1 to 1 - "full scale" - has 107 dB
% SPL) and a given hearing loss (HL) (optional parameter: default
% 0dB)
% Optionally, also a k-vector can be entered (default: k=0.8)
% HL and k are 1x24 vectors according to Zwicker's critical bands
% (regarding definition of center frequencies and bandwidth)
%
% References:
% Chalupper, J.,Fastl, H. (2002): Dynamic loudness model (DLM) for normal
% and hearing-impaired listeners. ACUSTICA/acta acustica, 88: 378-386
% Chalupper, J. (2001) - in german - : Perzeptive Folgen von
% Innenohrschwerh?rigkeit:
% Modellierung, Simulation und Rehabilitation. Dissertation at the Technical
% University of Munich, Shaker Verlag.
%
% Author: Josef Chalupper (josef.chalupper@siemens.com)
% original version: 12.12.2000
% new version (with comments and examples): 6.1.2007

% Altered by MFFM Matt Flax <flatmax> for the Psy-Sound project
% Jan. 2007
% Comments :
% This file is altered from its original form to allow block based
% processing. Block processing is a requirement of the Psy-Sound project.
% Block based processing requires that all necessary filter and data states
% are remembered between 'dlm' function calls. In order for this to be
% possible, the 'fileHandle' structure is altered accordingly.

f_abt = 1/2e-3; % 2 ms sampling period
if nargin == 2 % return the window size
  [t_pa,w,t_sb,t_sa,t_pb] = staticParamDLM;
  [h,t, erd] = tep_window(t_pb,t_pa,t_sb,t_sa,w,fs);
  N = length(h);
  
  out = N;
  return
end

HL = zeros(1,24);
k  = 0.8;

% Splitting of hearing loss into HL_ihc and HL_ohc
HL_ohc = k.*HL;
HL_ihc = HL-HL_ohc;

% Approximation of the transfer function through the human outer
% and and middle ear
[b, a] = butter_hp(fs); % generate the butterworth filter coeffs

% filter state vector.
Z = [];

% Calculation of coefficients of critical band filterbank
S = make_fttbank1(fs);

kern_l = [];

% Smoothed critical band loudness fitler creation
[smooth.b, smooth.a] = int_tp(f_abt);
smooth.Zfa = [];
smooth.Zfb = [];

% Return the run function handle
out = @run;

%
% RUN nested function
%
  function [N, main_N, spec_N] = run(sig)
  % Run the butterworth filter
  [sig, Z] = filter(b, a, sig, Z);
  
  % Applying critical band filterbank
  [fgrp, S] = ftt_bank1(sig, S, f_abt,fs);
  fgrp_d    = damp_a0(fgrp, HL_ihc); % Attenuation due to outer & middle
                                     % ear and inner hair cell hearing
                                     % loss
  
  % Calculation of main loudness
  kern_l = [kern_l; kernlaut24_two(fgrp_d, HL_ohc)];

  % Calculation of forward masking (aka "post masking")
  try
    kern_dyn = post_maskn(kern_l, f_abt);
  catch
    % caught the case where no postprocessing is possible, use a string to
    % indicate to the calling function.
    N = 'no postprocessing';
    main_N = 0;
    spec_N = 0;
    return
  end

  kern_l = []; % On successful post-processing, clear the processed data

  % Calculation of spectral masking and spectral summation of
  % specific loudness 
  [spec_N, lauth] = flankenlautheit24(kern_dyn);
  
  % Calculation of critical band loudness
  kl = bark_sum(spec_N);
  
  % Smoothed critical band loudness
  [main_N, smooth.Zfa] = filter(smooth.b, smooth.a, kl, smooth.Zfa);
  main_N(find(main_N <0)) = 0;

  % Loudness integration
  [N, smooth.Zfb] = filter(smooth.b, smooth.a, lauth, smooth.Zfb);
  N(find(N <0)) = 0;
  
  end % run
end % dlm
