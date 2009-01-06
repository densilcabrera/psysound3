% This file belongs to the roughness algorithm
% contact for the original source code :
% http://home.tm.tue.nl/dhermes/

% Included into psysound by Matt Flax <flatmax @
% http://www.flatmaxstudios.org> : flatmax is Matt Flax
% March 2006 : For the psySoundPro project

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

% end Hweights