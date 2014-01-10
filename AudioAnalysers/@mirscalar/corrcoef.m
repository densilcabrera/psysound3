function r = corrcoef(x,y)

dx = get(x,'Data');
dy = get(y,'Data');
fx = get(x,'FramePos');
fy = get(y,'FramePos');
dr = cell(1,length(fx));
for h = 1:length(fx)
    dr{h} = cell(1,length(fx{h}));
    for i = 1:length(fx{h})
        [f,ix,iy] = intersect(fx{h}{i}',fy{h}{i}','rows');
        dxi = dx{h}{i}(:,ix,:,:);
        dyi = dy{h}{i}(:,iy,:,:);
        dr{h}{i} = corrcoef(dxi,dyi);
    end
end
r = mirmatrix(x,'Data',dr,'Title','Correlation coefficients','Unit','');