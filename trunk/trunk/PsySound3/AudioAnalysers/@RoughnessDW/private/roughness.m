function out = roughness(Fs, flag)
% author : Matt Flax <flatmax @ http://www.flatmax.org> : Matt Flax is flatmax
% March 2006 : For the psySoundPro project
%
% revised : Farhan Rizwi
%           July '07
%           Reformatted, copied and vectorised code from InitAll
%           and Hweights into the function space below.  This
%           allows us to use nested functions effeciently.
%

% contact for the original source code :
% http://home.tm.tue.nl/dhermes/

% the following files are support files for this code :
%                InitFs44100N8192.mat
%                InitFs40960N8192.mat
%                InitFs48000N8192.mat

N = 8192;
if ~(Fs == 44100 | Fs == 40960 | Fs == 48000)
  error(['Incorrect sample rate for this roughness algorithm. Please ' ...
         're-sample original file to be Fs=44100,40960 or 48000 ' ...
         'Hz']);
end
if nargin == 2
  out = N;
  return
end

% Create and return a function handle to the roughness routine
out = @RoughBody;

  %
  % Execute the roughness algorithm
  %
  function dataOut = RoughBody(dataIn)
    % xxx - maybe the call to the blackman window should be a method
    AmpCal = db2amp(80)*2/(N*mean(blackman(N, 'periodic')));
    % Calibration between wav-level and loudness-level (assuming
    % blackman window and FFT will follow)
    
    Chno	=	47;
    Cal	 	=	0.25;
    N2		=	N/2;
    q		=	1:1:N;
    qb		=	N0:1:Ntop;
    freqs	=	(qb+1)*Fs/N;
    hBPi	=	zeros(Chno,N);
    hBPrms	=	zeros(1,Chno);
    mdept	=	zeros(1,Chno);
    ki		=	zeros(1,Chno-2);
    ri		=	zeros(1,Chno);

    % Calculate Excitation Patterns
    TempIn =  dataIn*AmpCal;
    [rt,ct]=size(TempIn);
    [r,c]=size(a0);
    if rt~=r; TempIn=TempIn'; end
    %maxAbsW=max(abs(fileHandle.windows.Blackman.wnd*AmpCal))
    %maxAbs=max(abs(TempIn))
    %TempIn=TempIn*10;
    TempIn	=	a0.*fft(TempIn);
    Lg		=	abs(TempIn(qb));
    LdB		=	amp2db(Lg);
    whichL	=	find(LdB>MinExcdB);
    sizL	=	length(whichL);

    % steepness of slopes (Terhardt)
    S1 = -27;
    S2 = zeros(1,sizL);

    for w = 1:1:sizL;
      % Steepness of upper slope [dB/Bark] in accordance with Terhardt
      steep = -24-(230/freqs(w))+(0.2*LdB(whichL(w)));
      if steep < 0
        S2(w) = steep;
      end
    end
    whichZ	= zeros(2,sizL);
    qd		= 1:1:sizL;
    whichZ(1,:)	= floor(2*Barkno(whichL(qd)+N01));
    whichZ(2,:)	= ceil(2*Barkno(whichL(qd)+N01));

    ExcAmp = zeros(sizL,47);
    Slopes = zeros(sizL,47);
    for k=1:1:sizL
      Ltmp = LdB(whichL(k));
      Btmp = Barkno(whichL(k)+N01);

      for l = 1:1:whichZ(1,k)
        Stemp = (S1*(Btmp-(l*0.5)))+Ltmp;
        if Stemp>MinBf(l)
          Slopes(k,l)=db2amp(Stemp);
        end
      end
      for l = whichZ(2,k):1:47
        Stemp =	(S2(k)*((l*0.5)-Btmp))+Ltmp;
        if Stemp>MinBf(l)
          Slopes(k,l)=db2amp(Stemp);
        end
      end
    end
    for k=1:1:47
      etmp = zeros(1,N);
      for l=1:1:sizL
        N1tmp = whichL(l);
        N2tmp = N1tmp + N01;
        if (whichZ(1,l) == k)
          ExcAmp(N1tmp, k) = 1;
        elseif (whichZ(2,l) == k)
          ExcAmp(N1tmp, k) = 1;
        elseif (whichZ(2,l) > k)
          ExcAmp(N1tmp,k) = Slopes(l,k+1)/Lg(N1tmp);
        else
          ExcAmp(N1tmp,k) = Slopes(l,k-1)/Lg(N1tmp);
        end
        etmp(N2tmp) = ExcAmp(N1tmp,k)*TempIn(N2tmp);
      end
      ei(k,:)	= N*real(ifft(etmp));
      etmp	= abs(ei(k,:));
      h0(k)	= mean(etmp);
      Fei(k,:)	= fft(etmp-h0(k));
      hBPi(k,:)	= 2*real(ifft(Fei(k,:).*Hweight(k,:)));
      hBPrms(k)	= rms(hBPi(k,:));
      if h0(k)>0
        mdept(k) = hBPrms(k)/h0(k);
        if mdept(k)>1
          mdept(k)=1;
        end
      else
        mdept(k)=0;
      end
    end
    % find cross-correlation coefficients
    for k=1:1:45
      cfac	=	cov(hBPi(k,:),hBPi(k+2,:));
      den	=	diag(cfac);
      den	=	sqrt(den*den');
      if den(2,1)>0
        ki(k)	=	cfac(2,1)/den(2,1);
      else
        ki(k)	=	0;
      end
    end

    % Calculate specific roughness ri and total roughness R
    ri(1)	=	(gzi(1)*mdept(1)*ki(1))^2;
    ri(2)	=	(gzi(2)*mdept(2)*ki(2))^2;
    for k = 3:1:45
      ri(k)	=	(gzi(k)*mdept(k)*ki(k-2)*ki(k))^2;
    end
    ri(46)	=	(gzi(46)*mdept(46)*ki(44))^2;
    ri(47)	=	(gzi(47)*mdept(47)*ki(45))^2;
    R		=	Cal*sum(ri);
    
    SPL = mean(rms(dataIn));
    if SPL > 0
      SPL = amp2db(SPL)+83; % -20 dBFS <--> 60 dB SPL
    else
      SPL = -400;
    end
    
    % Create a cell array to return
    dataOut{1} = R;
    dataOut{2} = ri;
    dataOut{3} = SPL;
  end % RoughBody

%%%%%%%%%%%%%%%%%
% BEGIN InitAll %
%%%%%%%%%%%%%%%%%
Bark = [0     0	   50	 0.5
        1   100	  150	 1.5
        2   200	  250	 2.5
        3   300	  350	 3.5
        4   400	  450	 4.5
        5   510	  570	 5.5
        6   630	  700	 6.5
        7   770	  840	 7.5
        8   920	 1000	 8.5
        9  1080	 1170	 9.5
        10  1270 1370	10.5
        11  1480 1600	11.5
        12  1720 1850	12.5
        13  2000 2150	13.5
        14  2320 2500	14.5
        15  2700 2900	15.5
        16  3150 3400	16.5
        17  3700 4000	17.5
        18  4400 4800	18.5
        19  5300 5800	19.5
        20  6400 7000	20.5
        21  7700 8500	21.5
        22  9500 10500	22.5
        23 12000 13500	23.5
        24 15500 20000	24.5];

Bark2	= [sort([Bark(:,2);Bark(:,3)]),sort([Bark(:,1);Bark(:,4)])];
N0	= round(20*N/Fs)+1;
N01	= N0-1;
N50     = round(50*N/Fs)-N0+1;
N2	= N/2+1;
Ntop	= round(20000*N/Fs)+1;
Ntop2	= Ntop-N0+1;
dFs	= Fs/N;

% Make list with Barknumber of each frequency bin
Barkno	  = zeros(1,N2);
f	  = N0:1:Ntop;
Barkno(f) = interp1(Bark2(:,1),Bark2(:,2),(f-1)*dFs);

% Make list of frequency bins closest to Cf's
Cf = ones(2,24);
for a=1:1:24
  Cf(1,a)=round(Bark((a+1),2)*N/Fs)+1-N0;
  Cf(2,a)=Bark(a+1,2);
end
%Make list of frequency bins closest to Critical Band Border frequencies
Bf = ones(2,24);
Bf(1,1)=round(Bark(1,3)*N/Fs);
for a=1:1:24
  Bf(1,a+1)=round(Bark((a+1),3)*N/Fs)+1-N0;
  Bf(2,a)=Bf(1,a)-1;
end
Bf(2,25)=round(Bark((25),3)*N/Fs)+1-N0;

%Make list of minimum excitation (Hearing Treshold)
HTres= [	0		130
                0.01   70
                0.17	 60
                0.8	 30
                1		 25
                1.5	 20
                2		 15
                3.3	 10
                4		  8.1
                5		  6.3
                6		  5
                8		  3.5
                10		  2.5
                12		  1.7
                13.3	  0
                15		 -2.5
                16		 -4
                17		 -3.7
                18		 -1.5
                19		  1.4
                20		  3.8
                21		  5
                22		  7.5
                23 	 15
                24 	 48
                24.5 	 60
                25		130];

k = (N0:1:Ntop);
MinExcdB = interp1(HTres(:,1),HTres(:,2),Barkno(k));
  
% Initialize constants and variables
zi    = 0.5:0.5:23.5;
zb    = sort([Bf(1,:),Cf(1,:)]);
MinBf = MinExcdB(zb);
ei    = zeros(47,N);
Fei   = zeros(47,N);

% BarkNo  0     1   2   3   4   5   6   7   8     9     10
%	 11     12  13  14  15  16  17  18  19  20  21  22  23  24 
gr = [ 0,1,2.5,4.9,6.5,8,9,10,11,11.5,13,17.5,21,24;
       0,0.35,0.7,0.7,1.1,1.25,1.26,1.18,1.08,1,0.66,0.46,0.38,0.3];
gzi    = zeros(1,47);
h0     = zeros(1,47);
k      = 1:1:47;
gzi(k) = sqrt(interp1(gr(1,:)',gr(2,:)',k/2));
    
% calculate a0
a0tab =	[ 0	 0
          10	 0
          12	 1.15
          13	 2.31
          14	 3.85
          15	 5.62
          16	 6.92
          16.5	 7.38
          17	 6.92
          18	 4.23
          18.5	 2.31
          19	 0
          20	-1.43
          21	-2.59
          21.5	-3.57
          22	-5.19
        22.5	-7.41
          23	-11.3
          23.5	-20
          24	-40
          25	-130
          26	-999];

a0    = ones(1,N);
k     = (N0:1:Ntop);
a0(k) = db2amp(interp1(a0tab(:,1),a0tab(:,2),Barkno(k)));

%%%%%%%%%%%%%%%
% END InitAll %
%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%
% BEGIN Hweights %
%%%%%%%%%%%%%%%%%%
% weights for freq. bins < N/2

DCbins	= 2;

H2 = [	0	0
        17    0.8
        23	0.95
        25	0.975
        32	1
        37	0.975
        48	0.9
        67    0.8
        90	0.7
        114   0.6
        171   0.4
        206	0.3
        247   0.2
        294	0.1
        358	0 ];

H5 = [	0	0
        32    0.8
        43	0.95
        56	1
        69	0.975
        92	0.9
        120   0.8
        142	0.7
        165   0.6
        231   0.4
        277	0.3
        331   0.2
        397	0.1
        502	0 ];

H16 = [	0	0
        23.5	0.4
        34	0.6
        47	0.8
        56	0.9
        63	0.95
        79	1
        100	0.975
        115	0.95
        135	0.9
        159	0.85
        172	0.8
        194	0.7
        215	0.6
        244	0.5
        290	0.4
        348	0.3
        415	0.2
        500	0.1
        645	0	];

H21 = [	0	0
        19	0.4
        44	0.8
        52.5	0.9
        58	0.95
        75	1
        101.5	0.95
        114.5	0.9
        132.5	0.85
        143.5	0.8
        165.5	0.7
        197.5	0.6
        241	0.5
        290	0.4
        348	0.3
        415	0.2
        500	0.1
        645	0	];


H42 = [ 0	0
        15	0.4
        41	0.8
        49	0.9
        53	0.965
        64	0.99
        71	1
        88	0.95
        94	0.9
        106	0.85
        115	0.8
        137	0.7
        180	0.6
        238	0.5
        290	0.4
        348	0.3
        415	0.2
        500	0.1
        645	0	];

Hweight	= zeros(47,N);

% weighting function H2
last	= floor((358/Fs)*N) ;
k	= DCbins+1:1:last;
f	= (k-1)*Fs/N;
Hweight(2,k) = interp1(H2(:,1),H2(:,2),f(k-DCbins));

% weighting function H5
last	=	floor((502/Fs)*N);
k	=	DCbins+1:1:last;
f	=	(k-1)*Fs/N;
Hweight(5,k)	= interp1(H5(:,1),H5(:,2),f(k-DCbins));

% weighting function H16
last	=	floor((645/Fs)*N);
k	=	DCbins+1:1:last;
f	=	(k-1)*Fs/N;
Hweight(16,k)	= interp1(H16(:,1),H16(:,2),f(k-DCbins));

% weighting function H21
Hweight(21,k)	= interp1(H21(:,1),H21(:,2),f(k-DCbins));

% weighting function H42
Hweight(42,k)	= interp1(H42(:,1),H42(:,2),f(k-DCbins));

% H1-H4
Hweight(1,:) = Hweight(2,:);
Hweight(3,:) = Hweight(2,:);
Hweight(4,:) = Hweight(2,:);

% H5-H15
for l =	6:1:15;
  Hweight(l,:) = Hweight(5,:);
end

% H17-H20
for l =	17:1:20;
  Hweight(l,:) = Hweight(16,:);
end

% H22-H41
for l =	22:1:41;
  Hweight(l,:) = Hweight(21,:);
end

% H43-H47
for l =	43:1:47;
  Hweight(l,:) = Hweight(42,:);
end

%%%%%%%%%%%%%%%%
% END Hweights %
%%%%%%%%%%%%%%%%

end % end roughness