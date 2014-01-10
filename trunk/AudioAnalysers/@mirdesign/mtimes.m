function varargout = mtimes(a,b)

varargout = mirfunction(@mtimescell,{a,b},{},1,struct,@init,@mtimescell);


function [x type] = init(x,option)
type = get(x{1},'Type');