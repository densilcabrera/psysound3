function varargout = mireventdensity(x,varargin)
%   e = mireventdensity(x) estimate the mean frequency of events (i.e., how
%       many note onsets per second) in the temporal data x.

%   Optional arguments: Option1, Option2
% Tuomas Eerola, 14.08.2008
%
        normal.type = 'String';
        normal.choice = {'Option1','Option2'};
        normal.default = 'Option1';
    option.normal = normal;

        frame.key = 'Frame';
        frame.type = 'Integer';
        frame.number = 2;
        frame.default = [0 0];
        frame.keydefault = [10 1];
    option.frame = frame;
    
specif.option = option;

specif.defaultframelength = 1.00;
specif.defaultframehop = 0.5;

%specif.eachchunk = 'Normal';
specif.combinechunk = {'Average','Concat'};

specif.nochunk = 1;

varargout = mirfunction(@mireventdensity,x,varargin,nargout,specif,@init,@main);


function [x type] = init(x,option)
if not(isamir(x,'mirenvelope'))
    if option.frame.length.val
        x = mironsets(x,'Klapuri99', 'Frame',option.frame.length.val,...
                                              option.frame.length.unit,...
                                              option.frame.hop.val,...
                                              option.frame.hop.unit);
    else
        x = mironsets(x,'Klapuri99');
    end
end
type = 'mirscalar';


function e = main(o,option,postoption)
if iscell(o)
    o = o{1};
end
sr = get(o,'Sampling');
p = mirpeaks(o); %%%%<<<<<<< MORE OPTIONS HERE
pv = get(p,'PeakVal');
v = mircompute(@algo,pv,o,option,sr);
e = mirscalar(o,'Data',v,'Title','Event density','Unit','per second');
e = {e o};


function e = algo(pv,o,option,sr)
nc = size(o,2);
nch = size(o,3);
e = zeros(1,nc,nch);
% for i = 1:nch
%     for j = 1:nc
%         if option.root
%             e(1,j,i) = norm(d(:,j,i));
%         else
%             disp('do the calc...')
%  %           e(1,j,i) = d(:,j,i)'*d(:,j,i);
%             %tmp = mironsets(d,'Filterbank',10,'Contrast',0.1); % Change by TE, was only FB=20, no other params
%             e2 = mirpeaks(e)
%             [o1,o2] = mirgetdata(e);
%             e(1,j,i) = length(o2)/mirgetdata(mirlength(d)); 
%         end
%     end
% end
for i = 1:nch
    for j = 1:nc
        e(1,j,i) = length(pv{1,j,i});
        if strcmpi(option.normal,'Option1')
            e(1,j,i) = e(1,j,i) *sr/size(o,1);
        elseif strcmpi(option.normal,'Option2')
            pvs = pv{1};
            high_pvs = length(find(mean(pvs)>pvs));
            e(1,j,i) = high_pvs(1,j,i) *sr/size(o,1); % only those which are larger than mean
        end
    end
end



%function [y orig] = eachchunk(orig,option,missing,postchunk)
%y = mireventdensity(orig,option);


%function y = combinechunk(old,new)
%do = mirgetdata(old);
%dn = mirgetdata(new);
%y = set(old,'ChunkData',do+dn);
