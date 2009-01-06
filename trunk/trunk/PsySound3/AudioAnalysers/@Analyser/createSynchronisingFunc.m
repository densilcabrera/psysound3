function func = createSynchronisingFunc(obj, rate, varargin)
% CREATESYNCHRONISINGFUNC  Create the synchronising function handle
%                          based on the Analyser type.
%
% Currently, we have 2 types:
% --------------------------
%  1. Simple resampling
%     This is for things like SLM/Hilbert/Loudness models
%     where the output is resampled on a sync period. Here we
%     make use of Matlab's resample function to allow for
%     fractionaly rate changes.
%
%  2. Window time step adjustment. FFT/Cepstrum/AutoCorrelation etc..
%     This simple sets up the window time step to be the same as
%     the new data rate.  Users still have full control of the
%     windowlength but we choose the overlap.
%     Note: This is a noop here.

% Switch on the Analyser type, create and return the appropriate
% function handle

func = [];

% Special handling
index = 0;
if nargin > 2
  index = varargin{1};
end

switch(obj.type)
 case {'TimeDomain', 'Psychoacoustic','Raw'}
  % MATLAB's resample function is very effecient as it:
  %   - uses a polyphase implementation in C
  %   - compensates for the filter delay
  %
  % However, we do need to buffer the overlap
  % 
  % Another way would be to use an FIR filter and keep track of the
  % initial condition but then we'll need to compensate for the
  % delay manually.  The other disadvantage is that for good
  % results the filter order needs to be quite high, however in
  % this case fftfilt would be more effecient
  %
  % We could also use an IIR filter and use filtfilt to compensate
  % for the delay. However, in both this and the previous case, the
  % filter command is not as fast as the upfirdn mex file that
  % resample uses.

  % Work out the new downsampling ratio
  if index
    [p, q] = rat(rate/getDataRate(obj, index), 1e-12);
  else
    [p, q] = rat(rate/getDataRate(obj), 1e-12);
  end

  % Order (and consequently, the delay) of resample's FIR filter
  N = 10;
  
  % This is the actual resampling function
  func = @resampleTimeDomain;
  B    = N;  % place holder for filter coeffecients
  
  % Local fields
  arr       = [];
  ptrVal    = 1;
  indOffset = 1;
  vfirst    = true;
  
 case 'FrequencyDomain'
  % Nothing to do here. Should've been handled already
 
 otherwise
  % Do nothing
end % switch

  %
  % RESAMPLETIMEDOMAIN
  % 
  % Note: dataIn must have column time
  %
  function dataOut = resampleTimeDomain(dataIn, first, last)
    % Append dataIn
    dataIn = [arr; dataIn];

    % Overlapping mechanism
    xArr = (ptrVal:ptrVal+size(dataIn,1)-1);
    x    = downsample(upsample(xArr, p), q);

    % Check if window is big enough
    if ~last && length(x) < 2*p*N+1
      % We need to buffer the windows until its big enough
      % warning('Buffering dataIn');
      arr     = dataIn;
      dataOut = [];
      return
    end
    
    % Resample, only creates the filter on the first invokation
    [dataOut, B] = resample(dataIn, p, q, B);
  
    % Find the first non-zero entry atleast N and 2N from the end
    indN  = find(x(1:end-p*N),   1, 'last');
    ind2N = find(x(1:end-p*2*N), 1, 'last');

    % Cache overlapping region, caching its global index
    arr    = dataIn(x(ind2N)-ptrVal+1:end,:);  % allow for matrices
    ptrVal = x(ind2N);

    if vfirst
      % Truncate at end only, unless this is the whole chunck
      if ~last
        dataOut = dataOut(1:indN,:);
      end
    elseif last
      % Truncate at the beginning only
      dataOut = dataOut(indOffset:end,:);
    else
      % Truncate both ends
      dataOut = dataOut(indOffset:indN,:);
    end

    % This is where dataOut will start next time
    indOffset = indN - ind2N + 1 + 1;
    
    % vfrist is the very first time we execute this block, in
    % this case fisrt will already be false
    vfirst = false;
  end % function resampleTimeDomain

end % createDownSamplingFunc
% EOF
