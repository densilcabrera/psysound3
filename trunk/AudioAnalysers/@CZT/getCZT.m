function [f1,f2,R1,R2] = getCZT(obj)
%GETCZT Summary of this function goes here
%   Detailed explanation goes here

f1 = obj.cztF(1);     % in hertz
f2 = obj.cztF(2);     % in hertz
R1 = obj.cztF(3);     % z-plane radius
R2 = obj.cztF(4);     % z-plane radius


end

