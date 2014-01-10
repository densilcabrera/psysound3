function x = exportation(s)

% SCALAR/EXPORTATION exports the values of a scalar object
% Filterbank not taken into consideration yet.

v = get(s,'Data');
t = get(s,'Title');
n = get(s,'Name');
pt = get(s,'PeakPosUnit');
pp = get(s,'PeakPos');
frames = 0;
for i = 1:length(v)
    if iscell(v{i})
        v{i} = v{i}{1}; %% Segmented audio cannot be exported properly now.
    end
    if iscell(v{i})
        v{i} = v{i}{1};
    end
    if size(v{i},2) > 1 || size(v{i},3) > 1
        frames = 1;
    end
end
for i = 1:length(v)
    vi = v{i};
    pti = pt{i};
    ppi = pp{i};
    for j = 1:size(vi,1)
        me = mean(vi(j,:,1),2);
        if frames
            st = std(vi(j,:,1),0,2);
            if not(isempty(pti{1}))
                if i == 1
                    if size(vi,1) > 1
                        x{1,j*4-3} = ['mean',t,num2str(j)];
                        x{1,j*4-2} = ['std',t,num2str(j)];
                        x{1,j*4-1} = ['peakpos',t,num2str(j)];
                        x{1,j*4} = ['peakval',t,num2str(j)];
                    else
                        x{1,j*4-3} = ['mean',t];
                        x{1,j*4-2} = ['std',t];
                        x{1,j*4-1} = ['peakpos',t];
                        x{1,j*4} = ['peakval',t];
                   end
                end
                pep = ppi{1,j,1}{1}; %% only first peak is taken
                pet = pti{1,j,1}{1}; %% only first peak is taken
                pev = vi(j,pep,1);
                x{i+1,j*4-3} = me;
                x{i+1,j*4-2} = st;
                x{i+1,j*4-1} = pet; 
                x{i+1,j*4} = pev;
            else
                if i == 1
                    if size(vi,1) > 1
                        x{1,j*2-1} = ['mean',t,num2str(j)];
                        x{1,j*2} = ['std',t,num2str(j)];
                    else
                        x{1,j*2-1} = ['mean',t];
                        x{1,j*2} = ['std',t];
                    end
                end
                x{i+1,j*2-1} = me;
                x{i+1,j*2} = st;
            end
        else
            if i == 1
                x{1,j} = t;
            end
            x{i+1,j} = me;
        end
    end
end