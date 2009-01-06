function f = createWindowFunc(obj)
% F = CREATEWINDOWFUNC Returns a handle to the windowing
%                      function requested
% window functions are set for 0 dB gain (averaged over their duration)
% this is achieved with the coefficient at the end of each line

wl   = get(obj, 'windowLength');
winF = get(obj, 'windowFunc');

f = @getWin;

switch(winF)
 case 'Hanning'
  data = hanning(wl, 'periodic').* 1.6330;
 case 'Hamming'
  data = hamming(wl, 'periodic') .* 1.5863;
 case 'Bartlett'
  data = bartlett(wl) .* 1.7321;
 case 'Bohman'
  data = bohmanwin(wl) .* 1.8464;
 case 'Gaussian'
  data = gausswin(wl) .* 1.6799;  
 case 'ModifiedBartlett-Hann'
  data = barthannwin(wl) .* 1.6576;
 case 'Blackman'
  data = blackman(wl, 'periodic') .* 1.8119;
 case 'BlackmanHarris'
  data = blackmanharris(wl) .* 1.9689;
 case 'Nuttall'
   data = nuttallwin(wl) .*  1.9566;
 case 'Chebyshev100dB'
   data = chebwin(wl, 100) .*  1.9380;
 case 'Chebyshev120dB'
   data = chebwin(wl, 120) .*  2.0317;
 case 'Chebyshev140dB'
   data = chebwin(wl, 140) .*  2.1140;
 case 'Flattop'
  data = flattopwin(wl, 'periodic') .* 2.3891;  

 otherwise
  % No window
  data = 1;
end

  % Returns the stored window
  function out = getWin
    out = data;
  end
end