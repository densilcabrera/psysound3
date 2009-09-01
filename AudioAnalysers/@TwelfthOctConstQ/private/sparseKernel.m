function sparKernel= sparseKernel(minFreq, maxFreq, bins, fs, thresh) 
% http://wwwmath.uni-muenster.de/logik/Personen/blankertz/constQ/constQ.html
% A matlab implementation of the efficient algorithm for the constant Q transform [Brown and Puckette 92] coded by Benjamin Blankertz. The sparseKernel has only to be calculated once. This might take some seconds. After that, constant Q transforms of any row vector x can be done very efficiently by calling constQ.
print ='Generating Kernel'
if nargin<5, thresh= 0.0054; end    % for Hamming window 
Q= 1/(2^(1/bins)-1);                                                      
K= ceil( bins * log2(maxFreq/minFreq) );                                  
fftLen= 2^nextpow2( ceil(Q*fs/minFreq) );
tempKernel= zeros(fftLen, 1); 
sparKernel= []; 
for k= K:-1:1; 
   len= ceil( Q * fs / (minFreq*2^((k-1)/bins)) );                        
   tempKernel(1:len)= hamming(len)/len .* exp(2*pi*i*Q*(0:len-1)'/len);   
   specKernel= fft(tempKernel);                                           
   specKernel(find(abs(specKernel)<=thresh))= 0; 
   sparKernel= sparse([specKernel sparKernel]); 
end 
sparKernel= conj(sparKernel) / fftLen;  