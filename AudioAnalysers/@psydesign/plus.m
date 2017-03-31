function varargout = plus(a,b)

varargout = mirfunction(@pluscell,{a,b},{},1,struct,@init,@plus);


function [x type] = init(x,option)
type = get(x{1},'Type');