function y = mirevalparallel(a,sr,w,single,ch,export)
% Function in separate M file, because the "parfor" command is not 
% recognized by old versions of Matlab, where this function is not used 
% anyway.

l = length(a);
y = cell(1,l);
parfor i = 1:l
    if l > 1
        fprintf('\n')
        display(['*** File # ',num2str(i),'/',num2str(l),': ',a{i}]);
    end
    tic
    yi = evalaudiofile(d,a{i},sr(i),lg(i),w(:,i),{},0,i,single,'',ch);
    toc
    y{i} = yi;
    if not(isempty(export))
        if strncmpi(export,'Separately',10)
            filename = a{i};
            filename(filename == '/') = '.';
            filename = [filename export(11:end)];
            if i == 1
                mkdir('Backup');
            end
            mirexport(filename,yi);
        elseif i==1
            mirexport(export,yi);
        else
            mirexport(export,yi,'#add');
        end
    end
end