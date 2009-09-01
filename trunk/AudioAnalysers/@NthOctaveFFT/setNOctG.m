function obj = setNOctG(obj, NOctType)
if NOctType==2
    NOctG = 2;
else
    NOctG = 10^(3/10);
end
obj.NOctG = NOctG;