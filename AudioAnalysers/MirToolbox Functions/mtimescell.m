function varargout = mtimescell(x,varargin)

specif.combinechunk = 'Average';

varargout = mirfunction(@mtimescell,x,varargin,nargout,specif,@init,@main);


function [x type] = init(x,option)
type = mirtype(x{1});


function y = main(x,option,postoption)
y = mtimes(x{1},x{2});