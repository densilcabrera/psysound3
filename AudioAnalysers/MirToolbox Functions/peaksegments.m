function y = peaksegments(func,d,p,varargin)

y = cell(1,length(d));
for h = 1:length(d)
    if not(iscell(d{h})) % for histograms
        p{h} = {p{h}(:,:,1)'};
        d{h} = {d{h}'};
    end
    for i = 1:length(d{h})
        %sum(var(p{h}{i},1,2))
        %p{h}{i} = repmat(p{h}{i}(:,1,1),[1,size(p{h}{i},2),size(p{h}{i},3)]);
        d{h}{i} = d{h}{i} + repmat(min(d{h}{i}),[size(d{h}{i},1),1,1]);
        for j = 1:size(d{h}{i},3)
            for k = 1:size(d{h}{i},2)
                yk = [];
                nb = 0;
                f = find(not(isnan(d{h}{i}(1:end,k,j))));
                while not(isempty(f))
                    l = f(1);
                    f = find(isnan(d{h}{i}(l:end,k,j)))+l-1;
                    if isempty(f)
                        f = size(d{h}{i},1)+1;
                    end
                    r = l:f(1)-1;
                    if length(r)>1
                        nb = nb+1;
                        if nargin > 3
                            for g = 1:length(varargin)
                                if g == 1
                                    v{g} = repmat(varargin{g}{h}{i}{1,k,j}(nb),...
                                              [length(r),1,1]);
                                else
                                    v{g} = varargin{g}{h}{i}{1,k,j}(nb);
                                end
                            end
                        else
                            v = {};
                        end
                        yk(nb,1) = func(abs(d{h}{i}(r,k,j)),...
                                        p{h}{i}(r,k,1),...
                                        v{:});
                    end
                    f = find(not(isnan(d{h}{i}(f(1):end,k,j))))+f(1)-1;
                end
                y{h}{i}{1,k,j} = yk;
            end
        end
    end
end