function b = isframed(d)

dat = get(d,'Data');
b = 0;
i = 0;
while not(b) && i < length(dat)
    i = i+1;
    j = 0;
    while not(b) && j < length(dat{i})
        j = j+1;
        if size(dat{i}{j},2) > 1
            b = 1;
        end
    end
end