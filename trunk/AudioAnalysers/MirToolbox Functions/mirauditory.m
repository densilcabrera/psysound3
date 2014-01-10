function varargout = mirauditory(x,varargin)
% Produces the output based on an auditory modelling, of the signal x,
% using a gammatone filterbank.
%   Optional argument:
%       mirtempo(...,'Filterbank',b) indicates the number of channels in
%           the filterbank decomposition.
%               Default value: b = 40.

        fb.key = 'Filterbank';
        fb.type = 'Integer';
        fb.default = 40;
    option.fb = fb;

specif.option = option;

varargout = mirfunction(@mirauditory,x,varargin,nargout,specif,@init,@main);


function [x type] = init(x,option)
if isamir(x,'miraudio')
    x = mirfilterbank(x,'NbChannels',option.fb);
    x = mirenvelope(x,'Center','Diff','Halfwave','Center');
end
type = 'mirenvelope';


function x = main(x,option,postoption)