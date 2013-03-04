function [ XTrain, YTrain, XTest, YTest ] = drawData ( X, Y, fold, folds )
    if(nargin<4)
        folds = 5;    
    end
    Ys = {};  
    u = unique(Y);    
    single = Inf;
    for i = 1:size(u, 1)
        Ys{i} = find(Y==u(i));
        single = min(single, floor(size(Ys{i},1)/folds));
    end    
    
    span = [];
    rest = [];
    for j = 1:size(u,1)
        span = [span;Ys{j}(horzcat(1:((fold-1)*single), (fold*single + 1):(folds*single)))];
        rest = [rest;Ys{j}(((fold-1)*single + 1):(fold*single))];
    end
    switch ndims(X)
        case 2 
            XTrain = X(span, :);
            XTest= X(rest, :);
        case 3
            XTrain = X(span, :, :);
            XTest= X(rest, :, :);
    end
    
    YTrain = Y(span);
    YTest = Y(rest);          
end

