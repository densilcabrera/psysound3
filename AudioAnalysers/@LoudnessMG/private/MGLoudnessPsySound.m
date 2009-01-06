function [Loudness,SpecLoudness,SharpnessA,SharpnessZ,TimbralWidth,Volume,DissonanceHK,DissonanceS,SpectDissHK,SpectDissS,Esig] = MGLoudnessPsySound(signal,SR,POINTS,Field)
%% Direct Port of Densil's Loudness and Dissonance Code
%
% Needs lots of vectorisation

if length(signal) == 1
	Loudness = 4096;
  return;
end 

% Calibration for the analyser - not in the original PsySound Code
% Worked out by trial and error.
signal = signal/(0.805*(10^-5)*1.8119); % 1.8119 is for blackman window compensation
Intensity = abs(fft(signal,POINTS)/POINTS).^2;
[CompactI,CompactF] = CompressSpectrum(Intensity,SR,POINTS);
CompInt = TransferFunctions(CompactF,CompactI,Field);
RoexL = FindRoexComponentLevels(CompInt,CompactF);	
[Esig,E] = FindExcitation(RoexL,CompactF,CompInt);
[Loudness,SpecLoudness] = CalculateLoudness(Esig);
[SharpnessZ,SharpnessA,TimbralWidth,Volume] = CalculateSharpness(Loudness,SpecLoudness);
[SpectDissHK,SpectDissS] = CalculateSpectDiss(CompactF,CompactI);

[NTones,ToneF,ToneL,ToneRef] = ExtractTonalComponents(Intensity,SR,POINTS);
[DissonanceHK,DissonanceS] = CalculateToneDissonance(ToneF,ToneL,NTones);
 
function [CompactI,CompactF] = CompressSpectrum(Intensity,SR,POINTS)
%reduces the number of spectrum components by using a split linear &
%logarithmic distribution
% NOTES ON IMPLEMENTATION:
%This only works for fs=44.1 kHz and FFT windowlength=4096
%The first function only needs to be run once because CompactF does not
%change - so that could be a way of slightly speeding up the code
for i = 1:41
  CompactF (i) = i*SR/POINTS;
end
for i = 42:108
  CompactF (i) = 458.502 * (2 ^ ((i-42)/12));
end

for i = 1:41
  CompactI (i) = Intensity(i);
end
for i = 42:108
  CompactI(i) = 0;
end
j = 0;

for i = 42:POINTS/2
  if i*SR/POINTS >= 458.502 * 2 ^ (j/12) / 2 ^ (1/24)
    if i*SR/POINTS < 458.502 * 2 ^ (j/12) * 2 ^ (1/24)
      CompactI(j+42) = CompactI(j+42) + Intensity(i);
    elseif j < 66
      j = j+1;
      CompactI(j+42) = CompactI(j+42) + Intensity(i);
    end
  end
end


function CompInt = TransferFunctions(CompactF,CompactI,Field)
% calls outer and middle ear transfer functions 
for i = 1:108
  CompL(i) = I2dB(CompactI (i));
  if strcmp(Field,'F')
    CompL(i) = FreeField(CompL(i), CompactF(i));
  end
  if strcmp(Field,'D')
    CompL(i) = DiffuseField(CompL(i), CompactF(i));
  end
  CompL(i) = MiddleEar(CompL(i), CompactF(i));
  CompInt(i) = dB2I(CompL(i));
end

function  RoexL = FindRoexComponentLevels(CompInt,CompactF)	
%calculates total level in the roex(p) filter around each component 		
%var i, component:integer;		
%	intensity: longreal; %intensity sum of level in a filter 	
%erb: longreal; %ERB of auditory filter centred on the component frequency 		
%p, g: longreal; %see Glasberg and Moore (1990) 		

for i = 1:108
  intensity = 0;
  erb = ERBandwidth(CompactF(i));
  p = 4 * (CompactF(i)) / erb;
  for component = 1:108
    g = abs(((CompactF(component)) - CompactF(i))/CompactF(i));
    if (g <= 2)
      intensity = intensity + (1 + p * g) * exp(-p * g) * CompInt(component);
    end
  end
  if intensity < 1e-10
    intensity = 1e-10;
  end
  RoexL(i) = I2dB(intensity);
end


function [Esig,E] = FindExcitation(RoexL,CompactF,CompInt)
%calculates Esig for each auditory filter 		
p511k = 30.2012922; %p51 @ 1kHz - see Glasberg and Moore (1990) 	
% var 	ecount, i: integer;	
% 	E: longreal; %Erb value of auditory filter 	
% 	frqhz: longreal; %centre frequency of auditory filter in Hz 	
% 	erb: longreal; %ERB of auditory filter 	
% 	p51, g, p: longreal; %see Glasberg and Moore (1990) 	
% 	intensity: longreal; %intensity sum of auditory filter 	
ESTART  = 2;
EEND    = 39;
ESTEP   = 0.1;

for ecount = round(ESTART/ESTEP):round(EEND/ESTEP)
  E     = ecount*ESTEP;
  frqhz = Erb2Fq(E);
  erb   = ERBandwidth(frqhz);
  p51   = 4 * frqhz/erb;
  intensity = 0;
  for i = 1:108
    g = ((CompactF(i)) - frqhz)/frqhz;
    if (g < 2)
      if (g < 0)
        p = p51 - 0.35 *(p51/p511k) * (RoexL(i) - 51);
      end
      if (g >= 0)
        p = p51;
      end
      if (p < 0.1)
        p = 0.1;
      end
      g = abs(g);
      intensity= intensity + CompInt(i) * (1 + p * g) * exp(-p * g);
    end %if (g < 2)
  end
  if intensity < 1e-10
    intensity = 1e-10;
  end
  Esig(ecount) = intensity;
end


function [Loudness,SpecLoud] = CalculateLoudness(Esig)
%calculates specific loudness and total loudness
C = 0.047; %see Moore et al (1997) 	
% var		ecount: integer; %counter 
% 		E: longreal; %Erb value of auditory filter 
% 		frqhz: longreal; %centre frequency of auditory filter 	
% 		Ethrq: longreal; %FindExcitation at Threshold of auditory filter 	
% 		alpha, A, g, gdB: longreal; %see Moore et al (1997) 	
ESTART  = 2;
EEND    = 39;
ESTEP   = 0.1;
EARS = 2;
Loudness = 0;		
%Nmax_T = 0;
for ecount = round(ESTART/ESTEP):round(EEND/ESTEP)
  E= ecount*ESTEP;
  frqhz = Erb2Fq(E);
  if frqhz >= 500
    Ethrq = 2.31;
    alpha = 0.2;
    A = 4.62;
    g = 1;
  else
    Ethrq = dB2I(-4.500239673E-03*frqhz + 3.666468615 + 1272.362339/frqhz);
    g = 2.31 / Ethrq;
    gdB = I2dB(g);
    A = -1.03703703E-04 * (gdB^3) -6.03174603E-04 * (gdB^2) ...
      -1.21375661E-01 * gdB + 4.58825396;
    alpha = 1.346860977E-23 * (gdB^3) +  2.571428571E-05 * (gdB^2) ...
      -2.071428571E-03 * gdB + 1.997142857E-01;
  end

  if I2dB(Esig(ecount)) > 100
    SpecLoud(ecount) = C * sqrt(Esig(ecount) / 1.04e6);
  else
    if Esig(ecount) < Ethrq
      SpecLoud(ecount) = ...
        C * (((2 * Esig(ecount)) / (Esig(ecount) + Ethrq))^1.5)...
        * (((g * Esig(ecount) + A)^alpha) - (A^alpha));
    else
      SpecLoud(ecount) = C * (((g * Esig(ecount)+ A)^alpha) - (A^alpha));
    end %if Esig(ecount) < Ethrq
  end %if I2dB(Esig(ecount)) > 100
  SpecLoud(ecount) = SpecLoud(ecount) * EARS; %1 or 2 ears
  Loudness = SpecLoud(ecount) * ESTEP + Loudness;
end %for ecount = round(ESTART/ESTEP):round(EEND/ESTEP)
if Loudness >= 1079
  Loudness = 9999.9;
end
%if Nmax_T < Loudness
%  Nmax_T = Loudness;
%end


function I = dB2I(dB) 
%converts level to intensity 
 I = 10.^(dB/10); 

function dB = I2dB(int) 
  %converts intensity to level
  dB = 10*log10(int);

function A = dBA (dB, Hz)
%calculates A-weighted level from unweighted level for a single frequency 
%var Log2Hz; %base 2 log of Hertz 
 
Log2Hz = 1.442695041 * log(Hz); 
A = dB -7.948405468E-03 * Log2Hz^4  + 3.109159487E-01 * Log2Hz ^ 3 ...
-5.470890122 * Log2Hz^2 + 50.39066638 * log2Hz -188.1740783; 

function B = dBB (dB, Hz) 
%calculates B-weighted level from unweighted level for a single frequency 
%var Log2Hz; %base 2 log of Hertz 
 
Log2Hz = 1.442695041 * log(Hz); 
B = dB -1.30002E-02 * Log2Hz^4  +  5.00058E-01 * Log2Hz^3 ...
-7.58896E+00 * Log2Hz^2 +  5.40999E+01 * log2Hz -1.51680E+02; 

function C = dBC (dB, Hz) 
%calculates C-weighted level from unweighted level for a single frequency 
%var Log2Hz; %base 2 log of Hertz 
Log2Hz = 1.442695041 * log(Hz); 
C = dB -1.66236E-02 * Log2Hz^4 +  5.94785E-01 * Log2Hz^3 ...
-7.90433E+00 * Log2Hz^2 +  4.62472E+01 * log2Hz -1.00608E+02; 

function Fq= Erb2Fq (ERB) 
%converts Erb-number to Hz  
  Fq = 1000*(exp((ERB/21.36554)*log(10))-1)/4.368; 

function ERB = Fq2Erb (Hz) 
%converts Herz to Erb-number 
   ERB = 21.365554*0.43429448*log(0.004368*Hz + 1); 

function Bandwidth = ERBandwidth (Hz) 
%finds the ERB of the auditory filter centred on a given frequency 
 Bandwidth = 24.673 * (4.368 * Hz/1000 + 1); 

function Bark = Erb2Bark (ERB) 
%converts Erb number to critical band rate in Barks  
  Bark = 13 * atan(0.76*((exp((ERB/21.36554)*log(10))-1)/4.368))... 
  + 3.5 * atan((((exp((ERB/21.36554)*log(10))-1)/4.368)^2)/56.25); 

function TH = Threshold(f) 
%calculates the Threshold of hearing for a given frequency in Hz 
f = f/1000; 
TH = 3.64 * f.^-0.8 - 6.5 * exp(-0.6 * ((f - 3.3).^2)) + 1e-3 * f.^4;
% 	f := f/1000;
% 	Threshold := 3.64 * f**-0.8
% 	- 6.5 * exp(-0.6 * sqr(f - 3.3))
% 	+ 1e-3 * f**4;

function FF = FreeField(dB, Hz)
%Transfer function from free Field to eardrum 
%Based on chart in Moore et al 1997 
%var lnkHz; 
 
lnkHz = log(Hz/1000); 
if (Hz < 16080) && (Hz > 104)
  if (Hz > 14910)
    FF = dB + 5.679E+01 *lnkHz -1.553E+02 ;
  elseif (Hz > 12670)
    FF = dB + -4.171E+01 *lnkHz+1.108E+02 ;
  elseif (Hz > 9892)
    FF = dB + 2.614E+01 *lnkHz -6.145E+01 ;
  elseif (Hz > 8966)
    FF = dB + -7.580E+00 *lnkHz+1.583E+01 ;
  elseif (Hz > 4126)
    FF = dB + -1.932E+01 *lnkHz+4.158E+01 ;
  elseif (Hz > 3068)
    FF = dB + -3.713E+00 *lnkHz+1.946E+01 ;
  elseif (Hz > 2593)
    FF = dB + -9.512E+00 *lnkHz+2.596E+01 ;
  elseif (Hz > 1495)
    FF = dB + 2.128E+01 *lnkHz -3.378E+00 ;
  elseif (Hz > 1259)
    FF = dB + 1.176E+01 *lnkHz +4.521E-01;
  elseif (Hz > 1003)
    FF = dB + 2.7714 *lnkHz+2.5217 ;
  elseif (Hz > 789)
    FF = dB + -0.207798 *lnkHz +2.53062 ;
  elseif (Hz > 756)
    FF = dB + -2.6052 *lnkHz +1.96095 ;
  elseif (Hz > 501)
    FF = dB + 2.429E+00 *lnkHz +3.370E+00 ;
  elseif (Hz > 318)
    FF = dB + 6.840E-01 *lnkHz +2.163E+00 ;
  elseif (Hz > 318)
    FF = dB + 1.856E+00 *lnkHz +3.504E+00 ;
  else
    FF = dB + 7.343E-01 *lnkHz +1.680E+00;
  end
else
  FF = dB;
end

function DF = DiffuseField(dB, Hz)
%Transfer function from diffuse Field to eardrum 
%Based on Kuhn: 'The pressure Transformation from a Diffuse Sound Field to the External Ear & to the Body & Head Surface', 
%Journal of the Acoustical Society of America, 65(4), 1979, 991-1000, (p995) 
%var Log2Hz; %base 2 log of Hertz 
Log2hz = 1.442695041 * log(Hz); 
if (Hz < 3000) && (Hz > 100)
  DF = dB + 0.284503283 * (Log2hz^3) -6.810700263 * (Log2hz^2) + 54.47419379 * Log2hz -144.9775695 ;
elseif (Hz >= 3000)
  DF = dB + 2.45970242* (Log2hz^6) -190.4723336 * (Log2hz^5) + 6136.70484 * (Log2hz^4) -105294.2136 * (Log2hz^3 )+ 1014768.533 * (Log2hz^2)  -5208395.924 * Log2hz + 11122764.39 ;
else
  DF = dB;
end %DiffuseField 

function ME = MiddleEar(dB, Hz)
%Transfer function of middle ear 
%Based on chart in Moore et al 1997 
%var lnkHz; 

lnkHz = log(Hz/1000);
if (Hz < 1000)
  ME = dB - (-1.565202883E-01*(lnkHz^5) -7.440518971E-01*(lnkHz^4) -3.837211687E-01*lnkHz^3 +3.213833938*lnkHz^2 + 1.938393276E-01*lnkHz +2.451477201);
elseif (Hz >= 1000) &&(Hz < 2550)
  ME = dB -(-30.68030779*lnkHz^5 +25.5855675*lnkHz^4 +11.59712163*lnkHz^3 +1.528651497*lnkHz^2 -3.276553725E-01*lnkHz +2.456571632);
elseif (Hz >= 2550) &&(Hz < 3770)
  ME = dB -(-583.4951348*lnkHz^5 +2146.842242 * lnkHz^4 -2032.566814 * lnkHz^3 -1070.229384 * lnkHz^2 +2550.529019*lnkHz -1000.795891);
elseif (Hz >= 3770) &&(Hz < 4900)
  ME = dB - 5.59 ;
elseif (Hz >= 4900) &&(Hz < 8460)
  ME = dB -(-54.73534189*lnkHz^3 + 305.6375959*lnkHz^2 -554.4794737*lnkHz +334.5546823) ;
elseif (Hz >= 8460) &&(Hz < 10100)
  ME = dB -(239.6317428*lnkHz^3 -1595.018816*lnkHz^2 +3530.273977*lnkHz -2587.559754) ;
else
  ME = dB -(16.7795*lnkHz -29.1991);
end %MiddleEar

function [SharpnessZ,SharpnessA,TimbralWidth,Volume] = CalculateSharpness(Loudness,SpecLoud)
%calculates sharpness, timbral width and volume from specific loudness
ESTART  = 2;
EEND    = 39;
ESTEP   = 0.1;
EARS = 2;
c = 0.585; %constant in Aures' formula
% var ecount: integer;
% 	E: longreal; %Erb value of auditory filter
% 	gzZ, gzA: longreal; %g(z) function from Zwicker & Fastl, g'(z) function in Aures
% 	SnumeratorZ, SnumeratorA, Vnumerator, Tnumerator: longreal; %numerators
% 	Timbrepeak: integer;
% 	specloudmax: longreal;

	if Loudness < 0.01  
		SharpnessZ = 0;
		SharpnessA = 0;
		TimbralWidth = 1;
		Volume = 0;
	else 	
		SnumeratorZ = 0;
		SnumeratorA = 0;
		specloudmax = 0;
		Vnumerator = 0;
		gzZ = 1;
		for ecount = round(ESTART/ESTEP):round(EEND/ESTEP)  
			E= ecount * ESTEP;	
			if E >= 24.5   
				gzZ = -5.86183e-5 * E^3	+ 2.09379e-2 * E^2 - 9.71707e-1 * E + 1.31746e1;
		 	end	
		SnumeratorZ = SnumeratorZ + (SpecLoud(ecount) * ESTEP * gzZ * Erb2Bark(E));
		 	gzA = 0.0165 * exp(0.171 * Erb2Bark(E));
		 	SnumeratorA = SnumeratorA + (SpecLoud(ecount) * ESTEP * gzA);
		 	if SpecLoud(ecount) > specloudmax  
		 		specloudmax = SpecLoud(ecount);
		 		Timbrepeak = ecount;
		 	end;
		 	Vnumerator = Vnumerator + SpecLoud (ecount) * ESTEP * (E + 8.65);
		end; %for ecount = round(ESTART/ESTEP) to round(EEND/ESTEP)  
		SharpnessZ = 0.11 * SnumeratorZ / Loudness;
		SharpnessA = (c * SnumeratorA / (EARS/2)) / log((Loudness / (EARS/2) + 20)/20);
		Tnumerator = 0;
		for ecount = round(ESTART/ESTEP):round(EEND/ESTEP) 
			if (ecount < Timbrepeak - round(0.5/ESTEP)) | (ecount >= Timbrepeak + round(0.5/ESTEP)) 
				Tnumerator = Tnumerator + SpecLoud (ecount) * ESTEP;
      end
    end
    TimbralWidth = (Tnumerator / Loudness) ^ 2;
		Volume = 3.47e5 * ((Loudness / (EARS/2))^0.5 / ((Vnumerator / (EARS/2))/(Loudness / (EARS/2)))^4);
end


function [NTones,ToneF,ToneL,ToneRef] = ExtractTonalComponents(Intensity,SR,POINTS)
%extracts tonal components from the lowest 1/4 of the Fourier spectrum}
NCOMPS = 512;
NTones = 0;
dBIntensity = I2dB(Intensity) + 104.11;
for i = 4:(NCOMPS - 3)
  if (dBIntensity(i-1) < dBIntensity(i)) && (dBIntensity(i) >= dBIntensity(i+1)) && (dBIntensity(i) > 10)
    if ((dBIntensity(i) - dBIntensity(i-3)) >= 7) && ((dBIntensity(i) - dBIntensity(i-2)) >= 7) && ((dBIntensity(i) - dBIntensity(i+2)) >= 7) &  ((dBIntensity(i) - dBIntensity(i+3)) >= 7)
      NTones = NTones + 1;
      ToneF(NTones) = i*SR/POINTS + 0.46 * (dBIntensity(i+1) - dBIntensity(i-1));
      ToneL(NTones) = dBIntensity(i) +1.6;
      ToneRef(NTones) = i;
    end
  end
end
if NTones == 0
  ToneF =[];
  ToneL = [];
  ToneRef =[];
end

function [DissonanceHK,DissonanceS] = CalculateToneDissonance(ToneF,ToneL,NTones)
% computes acoustic dissonance following Hutchinson and Knopoff
% AND Sethares.
% The tonal components of the spectrum used for the calculation.}
Setharesfactor = 20; % arbitrary adjustment of dB conversion
sumA =0; % amplitude sum (denominator) - H&K
sumAAg =0; % numerator - H&K
g =0; % dissonance factor - H&K
fCBW =0; % freq difference/CBW - H&K
A=0; % amplitude of (CompL - thresholddB)
s =0; % from Sethares
f1 =0; % frequency (i) - to speed up processing
A1 =0; % amplitude (i) - to speed up processing
dB1 =0;
dB2 =0; % decibel (i) - to speed up processing - Sethares
DissonanceS = 0;
DissonanceHK = 0;
if NTones > 1
  for i = 1:NTones
    A(i) = sqrt(dB2I(ToneL(i) - Threshold(ToneF(i)))/1e4);
  end
  sumA = 0;
  sumAAg = 0;
  for i = 1:NTones
    sumA = sumA + A(i)^2;
    f1 = ToneF(i);
    A1 = A(i);
    dB1 = I2dB(A1^2 + 1e-32)/Setharesfactor;
    if dB1 < 0
      dB1 = 0;
    end
    s = 0.24 / (0.0207 * f1 + 18.96);
    for j = 1:NTones
      fCBW = abs(f1 - ToneF(j)) / (1.72 * ((f1 + ToneF(j)) / 2) ^ 0.65);
      g = 0;
      if fCBW < 1.2
        g = 5.439061859 * fCBW^5 -25.24247636 * fCBW^4 + 44.07577904 * fCBW^3 -34.4678618 * fCBW^2 + 10.2345604 * fCBW  + 5.012466409E-03;
        if g > 1
          g = 1;
        end
        sumAAg = sumAAg + A1 * A(j) * g;
        dB2 = I2dB(A(j)^2 + 1e-32)/Setharesfactor;
        if dB2 < 0
          dB2 = 0;
        end
        DissonanceS = DissonanceS + dB1 * dB2 * (exp(-3.5 * s * abs(ToneF(j) - f1)) - exp(-5.75 * s * abs(ToneF(j) - f1)));
      end
    end %for i = 1 : NTones do begin}
    DissonanceHK = 0.5 * sumAAg / sumA;
  end %if NTones > 1 then begin}
end; %CalculateToneDissonance}


function [SpectDissHK,SpectDissS] = CalculateSpectDiss(CompactF,CompactI)
% computes acoustic dissonance following Hutchinson and Knopoff and Sethares.
% The compact spectrum is used for the calculation
Setharesfactor = 1e2; %arbitrary adjustment of dB conversion}
sumA =0; %amplitude sum (denominator) - H&K}
sumAAg =0; %numerator - H&K}
g =0; %dissonance factor - H&K}
fCBW =0; %freq difference/CBW - H&K}
A =0; %intensity of (CompL - thresholddB)}
s =0; %from Sethares}
f1 =0; %frequency (i) - to speed up processing}
A1 =0; %amplitude (i) - to speed up processing}
dB1 =0;
dB2 =0; %decibel (i) - to speed up processing - Sethares}
SpectDissS = 0;
SpectDissHK = 0;
i = 1:108;
A(i) = sqrt(dB2I(I2dB(CompactI(i)) - Threshold(CompactF(i)))/1e4);

sumA = 0;
sumAAg = 0;
for i = 1:108
  sumA = sumA + A(i)^2;
  f1 = CompactF(i);
  A1 = A(i);
  dB1 = I2dB(A1^2 + 1e-32)/Setharesfactor;
  if dB1 < 0
    dB1 = 0;
  end
  s = 0.24 / (0.0207 * f1 + 18.96);
  for j = i:107
    fCBW = abs(f1 - CompactF(j)) / (1.72 * ((f1 + CompactF(j)) / 2)^0.65);
    g= 0;
    if fCBW < 1.2
      g = 5.439061859 *fCBW^5 -25.24247636 * fCBW^4	+ 44.07577904 *fCBW^3 -34.4678618 * fCBW^2 + 10.2345604 * fCBW  + 5.012466409E-03;
      if g > 1
        g = 1;
      end
    end
    sumAAg = sumAAg + A1 * A(j) * g;
    dB2 = I2dB(A(j)^2 + 1e-32)/Setharesfactor;
    if dB2 < 0
      dB2 = 0;
    end
    SpectDissS = SpectDissS + dB1 * dB2 * (exp(-3.5 * s * (CompactF(j) - f1)) - exp(-5.75 * s * (CompactF(j) - f1)));
  end %for j := i to NCOMPS-1 do begin}
end %for i := 1 to NCOMPS do begin}
if sumA > 0
  SpectDissHK = sumAAg / sumA;
else
  SpectDissHK = 0;
end