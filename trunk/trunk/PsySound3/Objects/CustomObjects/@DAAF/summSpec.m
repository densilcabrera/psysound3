function obj = summSpec(obj,varargin)
% SUMMSPEC Make summary frame and place multiple copies in OutputFrames.

windowLength = varargin{1};

method = 'random';
if nargin >2
  method = varargin{2};
end

% how far past the last multiple of the window length have we gone?
remainder = mod(length(obj.AudioData),windowLength);

% zero pad to next multiple of windowlength
adata = [obj.AudioData; zeros(windowLength-remainder,1) ];

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
end