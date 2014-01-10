function res = mirmap(predics_ref,ratings_ref,dist,alpha,delta)
% mirmap(predictors_file, ratings_file) performs a statistical mapping
%   between ratings associated to a set of audio recordings, and a set of
%   variables computed for the same set of audio recordings. It might be
%   useful in particular when the set of predictors is large and diverse.

if nargin<3
    dist = 'lse';
end
if nargin<4
    alpha = 1;
end
if nargin<5
    delta = .00001;
end

crosscor_thres = .6;

dist = str2func(dist);

predics = import(predics_ref);
ratings = import(ratings_ref);

predics  = normalize(predics,dist,alpha,delta,'predictions',predics_ref);
if isempty(predics.data)
    res = [];
    return
end

ratings = normalize(ratings,dist,alpha,delta,'ratings',ratings_ref);

res = map(predics,ratings,crosscor_thres);


%%
function output = import(ref)
output.data = [];
output.fields = {};
output.normal = [];
if not(iscell(ref))
    ref = {ref};
end
for i = 1:length(ref)
    if not(iscell(ref{i}))
        ref{i} = {ref{i}};
    end
    if ischar(ref{i}{1})
        for j = 1:length(ref{i})
            importj = importdata(ref{i}{j});
            if not(isstruct(importj))
                imp = importj;
                importj = struct;
                importj.data = imp;
                for k = 1:size(imp,2)
                    importj.textdata{k} = [ref{i}{j},'_',num2str(k)];
                end
            end
            if j == 1
                import = importj;
            else
                [c ia ib] = intersect(import.textdata(1,2:end),...
                                      importj.textdata(1,2:end));
                import.textdata = [import.textdata(:,[1 ia+1]);...
                                   importj.textdata(2:end,[1 ib+1])];
                import.data = [import.data(:,ia);importj.data(:,[1 ib+1])];
            end
        end
        output.data = [output.data import.data];
        nbfields = size(import.data,2);
        field = import.textdata(1,:);
        field = field(end-nbfields+1 : end);
        output.fields = [output.fields field];
    else
        output.data = [output.data ref{i}{1}];
        for j = 1:size(ref{i},2)
            output.fields = [output.fields num2str(j)];
        end
    end
end
ndata = size(output.data,2);
output.normal = NaN(1,ndata);
warning('off','stats:lillietest:OutOfRangeP');
for i = 1:ndata
    data = output.data(:,i);
    data = data(~isnan(data));
    if length(data) < 4
        output.normal(i) = 0;
    else
        output.normal(i) = ~lillietest(data);
    end
end


%%
function res = map(predics,ratings,crosscor_thres)
nbrates = size(ratings.data,2);
nbpreds = size(predics.data,2);
res.normal.cor = NaN(nbpreds,nbrates);
res.normal.pval = NaN(nbpreds,nbrates);

res.significant = cell(nbrates,1);
for j = 1:nbrates
    figure
    set(gca,'YDir','reverse')
    hold on
    select = []; % list of selected features
    for i = 1:nbpreds
        if ~predics.normal(i)
            res.normal.cor(i,j) = NaN;
            continue
        end
        [R P] = corrcoef(predics.data(:,i),ratings.data(:,j),...
                            'rows','pairwise');
        res.normal.pval(i,j) = P(2);
        if P(2)<.05 % statistically significant
            select(end+1) = i; % included into the list of selected features
            res.normal.cor(i,j) = R(2);
        else
            res.normal.cor(i,j) = NaN;
        end
    end
    %res.inter(:,:,j) = corrcoef(predics.data,'rows','pairwise');
    
    [unused index] = sort(abs(res.normal.cor(select,j)),'descend');
    index = select(index);
    res.significant{j}.cor = res.normal.cor(index,j);
    res.significant{j}.pval = res.normal.pval(index,j);
    res.significant{j}.inter = corrcoef(predics.data(:,index),'rows','pairwise');
                %res.inter(index,index,j);
    res.significant{j}.fields = {predics.fields{index}};
    res.significant{j}.alpha = predics.alpha(index);
    res.significant{j}.lambda = predics.lambda(index);
    k = 0;
    corfields = {};
    corbest = [];
    for i = 1:length(select)
        inter = max(abs(res.significant{j}.inter(1:i-1,i)));
        if i == 1 || inter < crosscor_thres
            % Features sufficiently independent to the better scoring ones
            % are selected
            k = k+1;
            if i == 1
                own = 1;
            else
                own = 1-inter;
            end
            col = res.significant{j}.pval(i);
            x1 = min(0,res.significant{j}.cor(i));
            y1 = k-own/2;
            x2 = x1+abs(res.significant{j}.cor(i));
            y2 = k+own/2;
            pcolor([x1 x1;x2 x2],[y1 y2;y1 y2],[col col;col col])
            corbest = [corbest i];
            corfields = [corfields res.significant{j}.fields{i}];
            i
            res.significant{j}.fields{i}
            res.significant{j}.cor(i)
            inter
        end
    end

    set(gca,'YTick',1:k,'YTickLabel',corfields)%,...
%            'Position',[.4 .11 .5 .815])
    colorbar
    grid on
    title(['Correlation with rating ',ratings.fields{j}])
    
    predata = standardize(predics.data(:,index(corbest))); %% to be put out of the loop
    res.best{j}.index = corbest;
    res.best{j}.fields = {res.significant{j}.fields{corbest}};
    res.best{j}.alpha = res.significant{j}.alpha(corbest);
    res.best{j}.lambda = res.significant{j}.lambda(corbest);
    if isempty(select)
        close
    elseif length(corbest)>1
        display('****************************************')
        display(['Regression for rating ',ratings.fields{j}])
        ratej = standardize(ratings.data(:,j));
        stepwisefit(predata,ratej,'maxiter',10);
        [b,se,pval,inmodel,stats,nextstep,history] ...
            = stepwisefit(predata,ratej,'maxiter',10,'scale','on');
        res.best{j}.fields{find(inmodel)}
        %stepwise(predata,ratej,[]);%,.001,.001);
        pause
    end
end

function x = standardize(x)
%mx = mean(x);
%x = x-repmat(mx,[size(x,1) 1]);
%sx = std(x);
%sx(sx==0) = 1;
%x = x./repmat(sx,[size(x,1) 1]);


%%
function output = normalize(input,dist,alpha,delta,txt,filename)
fields = input.fields;
nbfields = length(fields);
output = input;
h = waitbar(0,['Normalizing ',txt]);
for i = 1:nbfields
    waitbar((i-1)/nbfields,h,['Normalizing ',txt,fields{i}]);
    d = input.data(:,i);
    if length(d(~isnan(d)))>3 && ~input.normal(i)
        %figure(1)
        %hist(d,round(7.5*log(size(d,1))));
        %figure(2)
        %normplot(d)
        
        [output.data(:,i) output.alpha(i) output.lambda(i)] = ...
                                        boxcox_search(d,dist,alpha,delta);
        %figure(3)
        %hist(output.data(:,i),round(7.5*log(size(d,1))));
        output.normal(i) = ~lillietest(output.data(:,i),.01);
        %figure(4)
        %normplot(data(:,i))
    end
end
display('Excluded:')
output.fields{~output.normal}
display('..')
output.data(:,~output.normal) = [];
output.fields(~output.normal) = [];
output.normal(~output.normal) = [];
if max(~output.normal)
    output.alpha(~output.normal) = [];
    output.lambda(~output.normal) = [];
end
 %if strcmpi(filename(end-3:end),'.txt')
 %    filename = filename(1:end-4);
 %end
 %filename = [filename '.mir.txt'];
 %mirexport(filename,output);
close(h);


function [y resalpha lambda] = boxcox_search(x,dist,alpha,delta)
if nargin<2
    dist = @lse;
end
if nargin<3
    alpha = 0;
end
lambda = -10:.01:10;
if min(x)<0
    x = x-min(x);
    resalpha = -min(x);
else
    resalpha = 0;
end
y = boxcox_transf(x,lambda);
[y lambda d] = optimize(y,lambda,dist,x);
%y = y(~isnan(y));
while lillietest(y,.01) && alpha > delta
    yp = boxcox_transf(x+alpha,lambda);
    %plot(alpha,lse(yp,lambda,x))
    if dist(yp,lambda,x)<d
        x = x+alpha;
        resalpha = resalpha + alpha;
        y = yp;
        alpha = alpha*.999;
        d = dist(y,lambda,x);
    else
        minalpha = min(alpha,min(x)); % to avoid negative values
        yn = boxcox_transf(x - minalpha,lambda);
        %plot(alpha,lse(yn,lambda,x))
        if dist(yn,lambda,x)<d
            x = minalpha;
            resalpha = resalpha - minalpha;
            y = yn;
            alpha = alpha*.999;
            d = dist(y,lambda,x);
        else
            alpha = alpha/2;
        end
    end
end
%plot(lambda,dist(y,lambda,x),'.r')


function y = boxcox_transf(x,lambda)
lambda0 = find(~lambda);
if min(x)<0
    x = x-min(x);
end
x = repmat(x,[1 length(lambda)]);
lambda = repmat(lambda,[size(x,1) 1]);
y = (x.^lambda-1)./lambda;
y(:,lambda0) = log(x(:,lambda0));


function [z,lambda,d] = optimize(y,lambda,dist,x)
[d index] = min(dist(y,lambda,x));
lambda = lambda(index);
z = y(:,index);


function d = lse(y,lambda,x)
d = skewness(y).^2 + (kurtosis(y)-3).^2/4; % equation used in Jarque-Bera test
%plot(lambda,d,'.')


function d = mle(y,lambda,x)
d = -size(y,1)/2*log(var(y))+(lambda-1)*sum(log(x));