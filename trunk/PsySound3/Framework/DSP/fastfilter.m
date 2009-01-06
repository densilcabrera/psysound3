function f = fastfilter(b)
% FASTFILTER  implements an FIR filter in the frequency domain by
%             using fft. The algorithm is identical to Matlab's
%             fftfilt except that this function supports block
%             processing

% Figure out some parameters
nb   = length(b);       % length of filter
nfft = 2^nextpow2(nb);  % fft block length

% Choose nfft bigger than the filter length otherwise we'll end up
% with the same performace as the direct form
if nfft == nb
  nfft = nfft * 2;
end
L = nfft - nb + 1;   % block length to process

% Only need to compute b's fft once
B = fft(b, nfft);

% Left over cache
Z = [];

% Return the function handle
f = @run;

  %
  % Call this function to run the filter
  %
  function out = run(u)

  nu = length(u);
  nx = ceil(nu/L)*L;
  
  % Allocate memory
  y              = zeros(nx+nb-1, 1);
  y(1:size(Z,1)) = Z; % fill in with previous state
  
  ystart = 1;
  while ystart <= nu
    ifinish = min(nu, ystart+L-1);
    yend    = ystart + nfft - 1;
    
    % L length u
    x = u(ystart:ifinish,:);
    
    % Do fft
    X = fft(x, nfft);
    
    % Multiply by filter and take inverse fft
    Y = ifft(X .* B);

    % overlap and add
    y(ystart:yend,:) = y(ystart:yend,:) + Y;

    % Move ystart forward
    ystart = ystart + L;
  end
  
  % Assign truncated output and save state
  out = y(1:nu,:);
  Z   = y(nu+1:end, :);
  
  end
end

% EOF
