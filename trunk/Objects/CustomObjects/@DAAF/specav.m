
function output =specav(winsize,overlap,s,newLen)
winNum=512;
%s = s(1:480000); % Take only first ten seconds
fs = 44100;

output = zeros(winsize*2,1);
while length(output) < fs*newLen
  winsizerand = floor(rand * winsize) + winsize/2; % Choose Random Windowsize
  avWindows = zeros(winsizerand,512); % Init
  for i = 1:winNum
    winstart = floor(rand * (length(s) - winsizerand*2))+1;
    avWindows(:,i) = s(winstart:winstart+winsizerand-1);
  end

  % sum and concatenate with an overlap
  newWindow = sum(avWindows,2)/(sqrt(winNum));
  output     = concat(output,newWindow,round(overlap*winsizerand)); 
end

function out = concat(s1,s2,samp)
%samp = samp- mod(length(samp),2); % No odd lengths
win = hann(samp*2); % building window
s1end= s1(end-samp+1:end) .* win(samp+1:end); 
s2start = s2(1:samp) .* win(1:samp);
out = [s1(1:end - samp); s1end+s2start; s2(samp+1:end)];
