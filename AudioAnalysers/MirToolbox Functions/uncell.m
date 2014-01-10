function x = uncell(x,lvl)
    % lvl >= 0: The recursion level, starting from 0, when observing the 
    %   cell structures of cell structures of etc. of the input data x. 
    % lvl = NaN:
    % lvl = -Inf: used in display of segmented mirscalar
if nargin < 2
    lvl = 0;
end
if iscell(x)
    if isempty(x)
        x = [];
    elseif length(x) == 1
        x = uncell(x{1},lvl+1);
    else
        het = 0;    % Flags different kinds of structures:
                    % - structures with fixed column size but variable nb of columns (het = 1)
                    % - structures with variable column size but fixed nb of columns (het = 2)
                    % - structures with variable column size and variable nb of columns (het = NaN)
        l = length(x(:,:,1));
        nf = size(x,3);
        z = cell(size(x));
        for i1 = 1:size(x,1)
            for i2 = 1:size(x,2)
                for i3 = 1:size(x,3)
                    z{i1,i2,i3} = uncell(x{i1,i2,i3},lvl+1);
                    if i1 == 1 && i2 == 1 && i3 == 1
                        s = size(z{i1,i2,i3});
                    elseif not(isequal(s,size(z{i1,i2,i3})))
                        % A break in the homogeneity has been discovered.
                        if lvl>0
                            if (het == 0 || het == 2) && (s(2) == size(z{i1,i2,i3},2))
                                het = 2;
                                s = max(s,size(z{i1,i2,i3}));
                            elseif (het == 0 || het == 1) && (s(1) == size(z{i1,i2,i3},1))
                                het = 1;
                                s = max(s,size(z{i1,i2,i3}));
                            else
                                het = NaN;
                            end
                        else
                            het = NaN;
                        end
                    end
                end
            end
        end
        if isnan(het)
            x = z;
        else
            if size(s)<3
                s(3) = 1;
            end
            if (s(1)>1 || isnan(lvl)) || lvl == -Inf
                x = NaN([s(1) l*s(2) nf*s(3:end)]);
                for j = 1:nf
                    for i = 1:l
                        if size(z,1)>size(z,2)
                            zij =  z{i,1,j};
                        else
                            zij =  z{1,i,j};
                        end
                        if size(zij,3) == 1
                            x(1:size(z{1,i,j},1),...
                              (i-1)*s(2)+1:(i-1)*s(2)+size(z{1,i,j},2),...
                              j,1:size(z{1,i,j},4)) = z{1,i,j};
                        elseif nf == 1
                            x(1:size(z{1,i,j},1),...
                              (i-1)*s(2)+1:(i-1)*s(2)+size(z{1,i,j},2),...
                              :,1:size(z{1,i,j},4)) = z{1,i,j};
                        end
                    end
                end
            else
                x = NaN([l*s(1) s(2) nf*s(3:end)]);
                for j = 1:nf
                    for i = 1:l
                        if size(z,1)>size(z,2)
                            zij =  z{i,1,j};
                        else
                            zij =  z{1,i,j};
                        end
                        if ischar(zij) && length(zij) == 1 && zij>='A' && zij <= 'G'
                            %zi
                            zij = zij-'A';
                        end
                        x((i-1)*s(1)*size(zij,1)+1:(i-1)*s(1)*size(zij,1)+size(zij,1),...
                          1:size(zij,2),...
                          j,...
                          1:size(zij,4)) = zij;
                    end
                end
            end
        end
    end
elseif ischar(x)
    switch x
        case 'C'
            x = 0;
        case 'C#'
            x = 1;
        case 'D'
            x = 2;
        case 'D#'
            x = 3;
        case 'E'
            x = 4;
        case 'F'
            x = 5;
        case 'F#'
            x = 6;
        case 'G'
            x = 7;
        case 'G#'
            x = 8;
        case 'A'
            x = 9;
        case 'A#'
            x = 10;
        case 'B'
            x = 11;
    end
elseif 0 %scal
    if size(x,1)==1 && size(x,2)==1 && size(x,3)>1
        x = shiftdim(x,2);
    else
        %y = zeros(size(x,2),size(x,1),size(x,3));
        %y = zeros(size(x));
        %for i = 1:size(x,3)
        %    y(:,:,i) = x(:,:,i);
        %end
        %x = y;
    end
elseif 0 %not(isnan(lvl)) && lvl>=0
    %x = squeeze(x);
    if size(x,1) == 1
        x = x(:);
    end
elseif 0 %size(x,3) > 1 && size(x,1) == 1
    x = reshape(x,size(x,2),size(x,3))';
end