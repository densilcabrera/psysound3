function varargout = nthoutput(orig,varargin)

        nth.type = 'Integer';
        nth.default = 1;
        nth.position = 2;
    option.nth = nth;
specif.option = option;

varargout = mirfunction(@nthoutput,orig,varargin,nargout,specif,@init,@main);


function [x type] = init(x,option)
type = mirtype(x);
type = type{option.nth};


function y = main(x,option,postoption)
y = x{option.nth};
%y = x{1}{option.nth};