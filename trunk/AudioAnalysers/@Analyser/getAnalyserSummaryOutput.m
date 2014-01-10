function Str = getAnalyserSummaryOutput(obj)
%OUT = GETANALYSERSUMMARYOUTPUT(OBJ) Summary of this function goes here
%   Detailed explanation goes here

Summ = get(obj,'SummaryOutput');

len=length(Summ);

Prop = cell(1,3*len);

for i=1:len
   
    Out = Summ{i};
    Prop{3*i-1} = Out.Data; % Value of the data (char or num)
    Prop{3*i-2} = Out.Name; % Name of the data (char)
    Prop{3*i} = Out.Unit; % Unit of the data (char)
      
    if isnumeric(Prop{i+1})
        Prop{3*i-1} = num2str(Prop{3*i-1});
    end
           
end

Str = sprintf('%s \t: %s %s\n',Prop{:});
%Displays, for example,   'Max SPL : 59 dB' ('Name' : 'Value' 'Unit')

end

