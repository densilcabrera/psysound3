function [N_entire,N_single] = loudness_1991(P, Pref, Fs, Mod,plotFlag)

% LOUDNESS
% ********************************************************
% based on ISO 532 B / DIN 45 631
% Source: BASIC code in J Acoust Soc Jpn (E) 12, 1 (1991)
% sig_t: time signal
% sampfrq: sampling frequency [Hz]
% N_entire = entire loudness [sone]
% N_single = partial loudness  [sone/Bark]
%*********************************************************
% Claire Churchill Jun. 2004

%****************************************************************************************
% PART 1
% fprintf('PART 1:Filters the data with Butterworth 1/3 octave filters of steepness N=4\n')
%****************************************************************************************

%'Generally used third-octave band filters show a leakage towards neighbouring filters of about 
% -20dB. This means that a 70dB, 1-kHz tone produces the following levels at different centre 
% frequencies: 10dB at 500 Hz, 30dB at 630Hz, 50dB at 800Hz and 70dB at 1kHz.' 
% P211 Psychoacoustics: Facts and Models, E. Zwicker and H. Fastl
% (A filter order of 4 gives approx this result)
% Mod = 0 for free field
% Mod = 1 for diffuse field

Fmin = 25;
Fmax = 12500;
order = 4;
% [Ptotal, P, F] = filter_third_octaves_downsample(x, Pref, Fs, Fmin, Fmax, order, 0);

% P = P(1:end-1); %avoid 16kHz value

% *****************************************************************************
% PART 2: line 1480
% fprintf('PART 2: A list of the constants\n')
% *****************************************************************************

% Centre frequencies of 1/3 Oct bands (FR)
FR = [25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 ...
        1600 2000 2500 3150 4000 5000 6300 8000 10000 12500];

% Ranges of 1/3 Oct bands for correction at low frequencies according to equal loudness contours
RAP = [45 55 65 71 80 90 100 120];

% Reduction of 1/3 Oct Band levels at low frequencies according to equal loudness contours 
% within the eight ranges defined by RAP (DLL)
DLL = [-32 -24 -16 -10 -5 0 -7 -3 0 -2 0;
    -29 -22 -15 -10 -4 0 -7 -2 0 -2 0;
    -27 -19 -14 -9 -4 0 -6 -2 0 -2 0;
    -25 -17 -12 -9 -3 0 -5 -2 0 -2 0;
    -23 -16 -11 -7 -3 0 -4 -1 0 -1 0;
    -20 -14 -10 -6 -3 0 -4 -1 0 -1 0;
    -18 -12 -9 -6 -2 0 -3 -1 0 -1 0;
    -15 -10 -8 -4 -2 0 -3 -1 0 -1 0];

% Critical band level at absolute threshold without taking into account the 
% transmission characteristics of the ear
LTQ = [30 18 12 8 7 6 5 4 3 3 3 3 3 3 3 3 3 3 3 3]; % Threshold due to internal noise
% Hearing thresholds for the excitation levels (each number corresponds to a critical band 12.5kHz is not included)

% Attenuation representing transmission between freefield and our hearing system
A0  = [0 0 0 0 0 0 0 0 0 0 -.5 -1.6 -3.2 -5.4 -5.6 -4 -1.5 2 5 12]; % Attenuation due to transmission in the middle ear
% Moore et al disagrees with this being flat for low frequencies

% Level correction to convert from a free field to a diffuse field (last critical band 12.5kHz is not included)
DDF = [0 0 .5 .9 1.2 1.6 2.3 2.8 3 2 0 -1.4 -2 -1.9 -1 .5 3 4 4.3 4];

% Correction factor because using third octave band levels (rather than critical bands)
DCB = [-.25 -.6 -.8 -.8 -.5 0 .5 1.1 1.5 1.7 1.8 1.8 1.7 1.6 1.4 1.2 .8 .5 0 -.5];

% Upper limits of the approximated critical bands
ZUP  = [.9 1.8 2.8 3.5 4.4 5.4 6.6 7.9 9.2 10.6 12.3 13.8 15.2 16.7 18.1 19.3 20.6 21.8 22.7 23.6 24];

% Range of specific loudness for the determination of the steepness of the upper slopes in the specific loudness 
% - critical band rate pattern (used to plot the correct USL curve)
RNS = [21.5 18 15.1 11.5 9 6.1 4.4 3.1 2.13 1.36 .82 .42 .30 .22 .15 .10 .035 0];

% This is used to design the right hand slope of the loudness
USL = [13 8.2 6.3 5.5 5.5 5.5 5.5 5.5;
   9   7.5 6   5.1 4.5 4.5 4.5 4.5;
   7.8 6.7 5.6 4.9 4.4 3.9 3.9 3.9;
   6.2 5.4 4.6 4.0 3.5 3.2 3.2 3.2;
   4.5 3.8 3.6 3.2 2.9 2.7 2.7 2.7;
   3.7 3.0 2.8 2.35 2.2 2.2 2.2 2.2;
   2.9 2.3 2.1 1.9 1.8 1.7 1.7 1.7;
   2.4 1.7 1.5 1.35 1.3 1.3 1.3 1.3;
   1.95 1.45 1.3 1.15 1.1 1.1 1.1 1.1;
   1.5 1.2 .94 .86 .82 .82 .82 .82;
   .72 .67 .64 .63 .62 .62 .62 .62;
   .59 .53 .51 .50 .42 .42 .42 .42;
   .40 .33 .26 .24 .24 .22 .22 .22;
   .27 .21 .20 .18 .17 .17 .17 .17;
   .16 .15 .14 .12 .11 .11 .11 .11;
   .12 .11 .10 .08 .08 .08 .08 .08;
   .09 .08 .07 .06 .06 .06 .06 .05;
	.06 .05 .03 .02 .02 .02 .02 .02];

%*************************************************************************************************
% PART 3A: line 
% fprintf('PART 3A: Adds a weighting factor to the first three 1/3 octave bands\n')
%*************************************************************************************************
Xp(1:11)=zeros;
Ti(1:11)=zeros;
for i=1:11;
    j=1;
    while (P(i) > (RAP(j)-DLL(j,i))) & (j < 8);
        j=j+1;
    end
    Xp(i) = P(i) + DLL(j,i);
    Ti(i) = 10^(Xp(i)/10);
end

% Outputs Xp = reduced levels, Ti = reduced third octave intensities

%*************************************************************************************************
% PART 3B: line
% fprintf('PART 3B: Intensity calculated for 1/3 octave bands four to eleven\n')
%*************************************************************************************************

% (see above)
% Output Ti = third octave intensities

%*************************************************************************************************
% PART 4: line
% fprintf('PART 4: Intensity values in first three critical bands calculated\n')
%*************************************************************************************************

Gi(1) = sum(Ti([1:6])); % Gi(1) is the first critical band (sum of two octaves (25Hz to 80Hz))
Gi(2) = sum(Ti([7:9])); % Gi(2) is the second critical band (sum of octave (100Hz to 160Hz))
Gi(3) = sum(Ti([10:11])); % Gi(3) is the third critical band (sum of two third octave bands (200Hz to 250Hz))

FNGi = 10*log10(Gi);

for i=1:3;
    if Gi(i)>0;
        LCB(i) = FNGi(i);
    else
        LCB(i) = 0;
    end
end

%*************************************************************************************************
% PART 5: line
% fprintf('PART 5: Calculates the main loudness in each critical band\n')
%*************************************************************************************************
Le(1:20)=zeros;
Lk(1:20)=zeros;
Nm(1:21)=zeros;
for i = 1:20;
    Le(i) = P(i+8);
    if i <= 3;
        Le(i) = LCB(i);
    end
    Lk(i) = Le(i) - A0(i);
    %Nm(i) = 0;
    if Mod == 1;
        Le(i) = Le(i) + DDF(i);
    end
    if Le(i) > LTQ(i);
        Le(i) = Lk(i) - DCB(i);
        S = 0.25;
        MP1 = 0.0635 * 10^(0.025*LTQ(i));
        MP2 = (1 - S + S*10^(0.1*(Le(i)-LTQ(i))))^0.25 - 1;
        Nm(i) = MP1*MP2;
        if Nm(i)<=0;
            Nm(i)=0;
        end
    end
end
%Nm(21) = 0;

KORRY = .4 + .32*Nm(1)^.2;
if KORRY > 1;
    KORRY=1;
end

Nm(1) = Nm(1)*KORRY;
          
%***************************************************************************************************
% PART 6: line 6060
% fprintf('PART 6: Adds the masking curves to the main loudness in each third octave band\n')
%***************************************************************************************************

N = 0;
z1 = 0; % critical band rate starts at 0
n1 = 0; % loudness level starts at 0
j = 18;
iz = 1;
z = 0.1;

for i = 1:21
    
% Determines where to start on the slope
   ig = i-1;
   if ig >8;
       ig=8;
   end
   control=1;
   while (z1 < ZUP(i)) | (control==1) % ZUP is the upper limit of the approximated critical band
       
% Determines which of the slopes to use
      if n1 < Nm(i),      % Nm is the main loudness level
         j=1;
         while RNS(j) > Nm(i), % the value of j is used below to build a slope
            j=j+1; % j becomes the index at which Nm(i) is first greater than RNS
         end 
      end
      
% The flat portions of the loudness graph
      if n1 <= Nm(i),
	     z2 = ZUP(i); % z2 becomes the upper limit of the critical band
         n2 = Nm(i);
	     N = N + n2*(z2-z1); % Sums the output (N_entire)
	     for k = z:0.1:z2      % k goes from z to upper limit of the critical band in steps of 0.1
	        ns(iz) = n2; % ns is the output, and equals the value of Nm
            if k < (z2-0.05), 
               iz = iz + 1;
            end
         end
         z = k; % z becomes the last value of k
         z = round(z*10)*0.1; 
	  end
      
% The sloped portions of the loudness graph
	  if n1 > Nm(i),
	      n2 = RNS(j);
	      if n2 < Nm(i);
              n2 = Nm(i);
	      end
	      dz = (n1-n2)/USL(j,ig); % USL = slopes
          dz = round(dz*10)*0.1;
          if dz == 0;
              dz = 0.1;
          end
          z2 = z1 + dz;
	      if z2 > ZUP(i),
	         z2 = ZUP(i);
	         dz = z2-z1;
	         n2 = n1 - dz*USL(j,ig); %USL = slopes
          end
          N = N + dz*(n1+n2)/2; % Sums the output (N_entire)
	      for k = z:0.1:z2
            ns(iz) = n1 - (k-z1)*USL(j,ig); % ns is the output, USL = slopes
            if k < (z2-0.05),
               iz = iz + 1;
            end
          end
          z = k;
          z = round(z*10)*0.1;
       end
	   if n2 == RNS(j);
           j=j+1;
	   end
	   if j > 18;
           j = 18;
	   end
	   n1 = n2;
       z1 = z2;
       z1 = round(z1*10)*0.1;
       control = control+1;
   end
end

if N < 0;
    N = 0;
end

if N <= 16;
    N = (N*1000+.5)/1000;
else
    N = (N*100+.5)/100;
end

LN = 40*(N + .0005)^.35;

if LN < 3;
    LN = 3;
end

if N >= 1;
    LN = 10*log10(N)/log10(2) + 40;
end

N_single(1:240) = zeros;
for i=1:240;
	N_single(i) = ns(i);
end

N_entire = N;

%******************************************************************************
% PART 8
%fprintf('PART 7 : Figure\n');
%******************************************************************************

% if (plotFlag==1)
% figure(200);
% x=[.1:.1:24];
% plot(x,N_single,'-');
% grid on
% axis([0 24 0 10]);
% ylabel('NÇ [sone/Bark]')
% xlabel('z [Bark]')
% text(1,0.2,'N [sone] =')
% text(4.5,0.2,num2str(N))
% hold off
% end