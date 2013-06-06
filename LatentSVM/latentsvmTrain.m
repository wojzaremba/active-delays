function [ model, H ] = latentsvmTrain( X, Y, firsts, len, windowSize, C, model_ )
    if (size(X, 1) ~= size(Y, 1))
       writelnLog(-1, 'incorrect input size. It should size(X, 1) == size(Y, 1) == nr samples');
       return;
    end
    rng('default');
    last = firsts + len - 1;
    nrChannels = size(X, 2);
    nrSamples = size(X, 1);
    Xcache_ = zeros(2*windowSize + 1, nrSamples, nrChannels, len);
    for i = 1:size(X, 2)
        for h = 1:(2*windowSize + 1)
            h_ = h - windowSize - 1;
            Xcache_(h, :, i, :) = reshape(X(:, i, (firsts(i) + h_):(last(i)  + h_)), nrSamples, len);
        end       
    end
    Xcache = reshape(Xcache_, (2*windowSize + 1) * nrSamples, nrChannels * len);
    writeLog(1, 'Generated cache of size %d %d %d %d\n', size(Xcache_, 1), size(Xcache_, 2), size(Xcache_, 3), size(Xcache_, 4));
    eps = 0.00005 * C;
    diff = Inf;
    H = zeros(nrSamples, 1);    
    iter = 0;
    while (diff > 0)
        iter = iter + 1;
        if (exist('model_', 'var') && ~isempty(model_) && ~exist('model', 'var'))
            model = model_;
            primalobj = Inf;
        else
            [ model, primalobj ] = latentsvmQP( X, Y, firsts, len, windowSize, C, H, Xcache, eps);
        end
        Hold = H;
        
        g = zeros(2 * windowSize + 1, size(X, 1));
        for h = 1:(2 * windowSize + 1)
            h_ = h - windowSize - 1;
            data = [];
            for i = 1:size(X, 2)
                tmp = X(:, i, (firsts(i) + h_):(last(i) + h_));
                data = cat(2, data, tmp);
            end            
            g(h, :) = data(:, :) * model(:);
        end
        H = ones(nrSamples, 1) * NaN;
        writeLog(2, 'H = ');
        for i = 1:size(X, 1)
            [~, h] = max(Y(i) * squeeze(g(:, i)));
            H(i) = h - windowSize - 1;
            writeLogDataFree(2, '%d, ', H(i));
        end   
        writeLogDataFree(2, '\n');
        diff = sum(Hold ~= H);
        writelnLog(0, 'diff = %d primalobj = %f eps = %f', diff, primalobj, eps);
        if (mod(iter, 10) == 9)
            eps = eps / 2;
        end
    end
end

