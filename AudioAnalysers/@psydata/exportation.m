function x = exportation(s)

% EXPORTATION exports the peaks of a vectorial dimension

v = get(s,'Data');
n = get(s,'Name');
pt = get(s,'PeakPosUnit');
pp = get(s,'PeakPos');
t = get(s,'Title');
frames = 0;
for i = 1:length(v)
    if iscell(v{i})
        v{i} = v{i}{1}; %% Segmented audio cannot be exported properly now.
    end
    if size(v{i},2) > 1
        frames = 1;
    end
end
for i = 1:length(v)
    if size(v{i},4) == 1
        vi = v{i};
    else
        lvi = size(v{i},1);
        vi = [];
        for j = 1:size(v{i},4)
            vi(lvi*(j-1)+1:lvi*j,:,:) = v{i}(:,:,:,1);
        end
    end
    if i == 1
        x{1,1} = ['mean',t];
        x{1,2} = ['std',t];
    end
    x{i+1,1} = mean(mean(vi));
    x{i+1,2} = mean(std(vi));
    pti = pt{i};
    ppi = pp{i};
    if not(isempty(ppi{1}))
        if iscell(ppi{1})
            ppi = ppi{1}; %% Segmented audio cannot be exported properly now.
            pti = pti{1};
            if iscell(pti{1})
                pti = ppi;
            end
        end
        for j = 1:size(vi,2)
            pep = ppi{1,j,1};
            if isempty(pep)
                pet(j) = NaN;
                pev(j) = NaN;
            else
                pet(j) = pti{1,j,1}(1);
                if size(vi,3) > 1 && size(vi,1) == 1
                    pev(j) = pep(1);
                else
                    pev(j) = vi(pep(1),j,1);
                end
            end
        end
        if frames
            if i == 1
                x{1,3} = ['meanpeakpos',t];
                x{1,4} = ['stdpeakpos',t];
                x{1,5} = ['meanpeakval',t];
                x{1,6} = ['stdpeakval',t];
            end
            x{i+1,3} = mean(pet);
            x{i+1,4} = std(pet);
            x{i+1,5} = mean(pev);
            x{i+1,6} = std(pev);
        else
            if i == 1
                x{1,3} = ['peakpos',t];
                x{1,4} = ['peakval',t];
            end
            x{i+1,3} = pet;
            x{i+1,4} = pev;
        end
    end
end