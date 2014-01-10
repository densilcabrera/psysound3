function varargout = mirsummary(varargin)
%   mirsummary is the same function as mirsum.

vout = '';
for i = 1:max(1,nargout)
    vout = [vout,'y',num2str(i),' '];
end
eval(['[ ',vout,'] = mirsum(varargin{:});'])
eval(['varargout = { ',vout,'};'])