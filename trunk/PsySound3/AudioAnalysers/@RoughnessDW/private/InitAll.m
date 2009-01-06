% This file belongs to the roughness algorithm
% contact for the original source code :
% http://home.tm.tue.nl/dhermes/

% Included into psysound by Matt Flax <flatmax @
% http://www.flatmax.org> : Matt Flax is flatmax
% March 2007 : For the psySoundPro project

% Modified by Farhan Rizwi to use function handles

% Initialize BarkScale and slopes
% Roughness('Prog',1,0);  % removed from the psysound version

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
        10  1270	 1370	10.5
        11  1480	 1600	11.5
        12  1720	 1850	12.5
        13  2000	 2150	13.5
        14  2320	 2500	14.5
        15  2700	 2900	15.5
        16  3150	 3400	16.5
        17  3700	 4000	17.5
        18  4400	 4800	18.5
        19  5300	 5800	19.5
        20  6400	 7000	20.5
        21  7700	 8500	21.5
        22  9500	10500	22.5
        23 12000	13500	23.5
        24 15500	20000	24.5];

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
%Roughness('Prog',5,1);	% removed from the psysound version
%%show progress

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
  
%Roughness('Prog',5,3);	% removed from this version of psysound
%%show progress 

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
    
%Roughness('Prog',5,4);	% removed from this version of psysound
%%show progress 

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

%Roughness('Prog',5,5);	% removed from the psysound version
%%show progress 

% end InitAll
