function obj = summSpec(obj,varargin)
% SUMMSPEC Make summary frame and place multiple copies in OutputFrames.

windowLength = varargin{1};
winsize = windowLength/2;
method = 'random';
if nargin >2
  method = varargin{2};
end

% how far past the last multiple of the window length have we gone?
remainder = mod(length(obj.AudioData),windowLength);

% zero pad to next multiple of windowlength
adata = [obj.AudioData; zeros(windowLength-remainder,1) ];
adata = adata - mean(adata);
% reshape to matrix.
s = reshape(adata,windowLength,[]);
[r,c] = size(s);


duration = 2;

switch method

  case 'random'
    
    copies = floor(duration / (r / obj.FS) / (1 - obj.Overlap));
    
    % take mean across
    for i = 1:copies
      fr =  ceil(rand(1,floor(c/2)) * c);
      obj.OutputFrames{i} = mean(s(:,fr),2) * (10^(6/10)); % Turn up by 6 dB;
    end
    
   case 'randomwind'
   
    winNum=512;
    outdur = 0;
    duration = duration * obj.FS;
    col = 1;
    while outdur < duration
        
       winsizerand = floor(rand * winsize) + winsize/2; % Choose Random Windowsize
       avWindows = zeros(winsizerand,512); % Init
       for i = 1:winNum
         winstart = floor(rand * (length(adata) - winsizerand*2))+1;
         avWindows(:,i) = adata(winstart:winstart+winsizerand-1);
       end

       % sum and concatenate with an overlap
       obj.OutputFrames{col} = sum(avWindows,2)/(sqrt(winNum));  
       outdur = outdur+winsizerand; %in samples
       col = col + 1;
    end
end






