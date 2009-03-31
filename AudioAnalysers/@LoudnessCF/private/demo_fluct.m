%demo_fluct
sig = testnoise(70,20,20000,1);
amsig=am(sig,2,40,'d',44100,-pi/2,1); %white noise, 1kHz, d=40dB, fmod=2Hz,peak level=80dB

%calculate loudness time pattern
[N, main_N, spec_N]=dlm(amsig);

%calculate loudness fluctuation
lf=fluct(main_N)

sig = testnoise(70,20,20000,1);
amsig=am(sig,32,40,'d',44100,-pi/2,1); %white noise, 1kHz, d=40dB, fmod=32Hz,peak level=80dB

%calculate loudness time pattern
[N, main_N, spec_N]=dlm(amsig);

%calculate loudness fluctuation
lf=fluct(main_N)

sig = testnoise(70,20,20000,1);
amsig=am(sig,4,4,'d',44100,-pi/2,1); %white noise, 1kHz, d=40dB, fmod=2Hz,peak level=80dB

%calculate loudness time pattern
[N, main_N, spec_N]=dlm(amsig);

%calculate loudness fluctuation
lf=fluct(main_N)
