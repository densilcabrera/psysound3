function cq= constQ(x, sparKernel)    % x must be a row vector 
% http://wwwmath.uni-muenster.de/logik/Personen/blankertz/constQ/constQ.html
% A matlab implementation of the efficient algorithm for the constant Q
% transform [Brown and Puckette 92] coded by Benjamin Blankertz. The
% sparseKernel has only to be calculated once. This might take some
% seconds. After that, constant Q transforms of any row vector x can be
% done very efficiently by calling constQ.
cq= fft(x,size(sparKernel,1)) * sparKernel;   