function [ acc ] = latentsvmClassify(model, X, Y, first, len, window)
    Yfinal = zeros(size(X, 1), 1);
    g = zeros(2 * window + 1, size(X, 1));
    last = first + len - 1;
    for h = 1:(2*window + 1)
        h_ = h - window - 1;
        data = [];
        for i = 1:size(X, 2)
            tmp = X(:, i, (first + h_):(last + h_));
            data = cat(2, data, tmp);
        end
        g(h, :) = data(:, :) * model;
    end
    for i = 1:size(X, 1)
        [~, h] = max(abs(g(:, i)));
        Yfinal(i) = sign(g(h, i)); 
    end
    Yfinal(Yfinal == 0) = 1;  
    acc = mean(Yfinal == Y);
end

