function y = testnoise(l,fu,fo,t,option)
% y = testnoise(l,fu,fo,t,option)
% berechnet Wei�es Rauschen mit Pegel l (in dB), unterer Grenzfrequenz fu (in Hz), 
% oberer Grenzfrequenz fo (in Hz)und Dauer t (in s).
% Achtung! mu� ge�ndert werden (s. medavnoise) asymmetrische Filter
% falls 'g' als weiterer Parameter �bergeben wird, wird das Rauschen gau�moduliert (20 ms)
 
Fs= 44100;
Fn= Fs/2;
noise=randn(t*Fs,1);          % gau�verteiltes Rauschen mean=0, std=1 und Dauer t

% Bandbegrenzung
fm=sqrt(fu*fo);
Wpl=fo/Fn;
Wph=fu/Fn;
Rs=60;
Rp=1;

zm=tonheit(fm);
zo=60/27+zm;
zu=zm-60/27;
Wsl=invtonheit(zo)/Fn;
Wsh=invtonheit(zu)/Fn;

%Tiefpa�filterung
[n,Wn]=cheb1ord(Wpl,Wsl,Rp,Rs);
[b,a]=cheby1(n,Rp,Wn);
noise=filter(b,a,noise);

%Hochpa�filterung
[n,Wn]=cheb1ord(Wph,Wsh,Rp,Rs);
[b,a]=cheby1(n,Rp,Wn,'high');
noise=filter(b,a,noise);

rms=true_rms(noise);
x=1;
while (rms<l-0.5) | (rms>l+0.5)   % gew�nschter Pegel wird eingestellt
   if rms<l-0.5
      x=x+x/2;
   else
      x=x-x/2;
   end
   sig=x.*noise;
   rms=true_rms(sig);
end   
y=x*noise;

if (nargin == 5)         % Gau�modulation (falls gew�nscht)
   if strcmp(option,'g')        
      y=gaussmod(y,20);
   else
      error('falscher Parameter!')
   end
end