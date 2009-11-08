function obj = xfade(obj)
% XFADE Frames of DAAF Object Frame by Frame
%

overlap = floor(obj.Overlap * obj.WindowLength);
if isnan(overlap)
  overlap = obj.Overlap * 2048;
end

if (overlap<128)
  overlap = 256;
end


[r,c] = size(obj.OutputFrames);
if r<c, 
 obj.OutputFrames = obj.OutputFrames'; 
end

[r,c] = size(obj.OutputFrames);  

for clm = 1:c 

%figure
for i = 1:length(obj.OutputFrames)-1
  frame = obj.OutputFrames{i,clm}';
  frame2 = obj.OutputFrames{i+1,clm}';
  [r,c] = size(frame);
  if r<c
    frame = frame';
    frame2 = frame2';
  end  
  plateau = frame((overlap+1):(end-overlap));  
	windAB = eval([obj.WindowFunction '(' num2str(overlap*2) ')']);
	windA = windAB(overlap+1:end); 
  windB = windAB(1:overlap);
  
  xfadedPartA = frame((end-overlap+1):end);
  xfadedPartB = frame2(1:overlap);
  
  xfadedPartA =   xfadedPartA .* windA;
  
  xfadedPartB =   xfadedPartB .* windB;
  obj.OutputFrames{i,clm} = [plateau; (xfadedPartA + xfadedPartB)];
 % plot([plateau (xfadedPartA + xfadedPartB) ] );
 % hold on
 % pause
end
obj.OutputFrames{i+1,clm} =  frame2((overlap+1):end);
end