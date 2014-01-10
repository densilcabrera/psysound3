function varargout = mirattacks(orig,varargin)
% Obsolete function, replaced by mironsets(...,'Attacks',...)

        aver.key = 'Smooth';
        aver.type = 'Integer';
        aver.default = 20;
    option.aver = aver;
        
specif.option = option;

varargout = mirfunction(@mirattacks,orig,varargin,nargout,specif,@init,@main);


function [x type] = init(x,option)
x = mironsets(x,'Attack',option.aver);
type = mirtype(x);


function a = main(a,option,postoption)