function [y,env]=am(sig,fmod,x,option,Fs,start_phase,const)
% [y,env]=am(sig,fmod,x,option,start_phase,const);
% am.m amplitudenmoduliert beliebiges Signal sig mit Modulationsfrequenz fmod.
% option ist entweder m oder d, je nachdem, ob Modulationsgrad m (in %) 
% oder Modulationsmaß d (dB) in 'x' angegeben wird.
% falls sig eine Matrix ist, arbeitet am spaltenweise, y ist dann eine matrix
% optional: Abtastrate (default 44,1 kHz)
% optional: bei start_phase = -pi/2 beginnt Modulation im Minimum (default)
% optional: Maximum konstant halten (beliebigen Wert für const eingeben).

if nargin < 5
    Fs=44100;
end    

if nargin < 6
   start_phase=-pi/2;
end

if nargin < 7
   korr=0;
else
   %Korrektur berechnen, damit Maximalpegel gleich bleibt (wie unmoduliertes Signal)
   if strcmp(option,'d')
      d=x;
   else
      d=20*log10((1+x/100)/(1-x/100));
   end
   korr=20.*log10(2.*10.^(d./20)./(1+10.^(d./20))); %vgl. Diss Schöne S79
end   
   
if strcmp(option,'m')
   m=x/100;
elseif strcmp(option,'d')
   m=(10^(x/20)-1)/(10^(x/20)+1);
else
   error('falsche Parameter! y=am(sig,fmod,x,option); option: ''d'' oder ''m')
end
   
[r,c]=size(sig);
if r*c == 0,
    y = []; return  % falls leere Matrix: austeigen
end
if (r==1),   % convert row vector to column
    sig = sig(:);  len = c;
else
    len = r;
end
   
t = (0:1/Fs:((len-1)/Fs))';   % Zeitvektor
t = t(:,ones(1,size(sig,2))); % scalar expansion, falls sig Matrix ist
env=amp((1 + m * sin(2*pi*fmod*t+start_phase)),-korr);
y = sig .* env; % Modulation beginnt im Minimum

% Anhang: einige Formeln zur Amplitudenmodulation
% Pegelabstand zwischen Träger und Seitenlinien
% deltal=20*log10(2/m);
% d als Funktion von m
% d=20*log10((1+m)/(1-m));
% d bei QFM
% d=10*log10(m^2+1); 