function varargout = mirhcdf(orig,varargin)
%   df = mirhcdf(x) calculates the Harmonic Change Detection Function
%       related to x.
%
% C. A. Harte and M. B. Sandler, Detecting harmonic change in musical
%   audio, in Proceedings of Audio and Music Computing for Multimedia
%   Workshop, Santa Barbara, CA, 2006. 

specif.defaultframelength = .743;
specif.defaultframehop = .1;
varargout = mirfunction(@mirhcdf,orig,varargin,nargout,specif,@init,@main);


function [df type] = init(orig,option)
if isamir(orig,'mirscalar')
    df = orig;
else
    if isframed(orig)
        tc = mirtonalcentroid(orig);
    else
        tc = mirtonalcentroid(orig,'Frame');
    end
    df = mirflux(tc);
end
type = 'mirscalar';


function df = main(df,option,postoption)