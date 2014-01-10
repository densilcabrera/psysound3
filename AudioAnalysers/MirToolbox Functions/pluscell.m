function varargout = pluscell(x,varargin)

specif.combinechunk = 'Average';

varargout = mirfunction(@pluscell,x,varargin,nargout,specif,@init,@main);


function [x type] = init(x,option)
type = mirtype(a{1});


function y = main(x,option,postoption)
y = plus(x{1},x{2});