initialize();
load([getenv('data_path'), 'processed08_ica.mat'], 'X', 'Y');
setenv('log_level', '1');
folds = 0;
cacheName = 'componentsSeparatelySingleFold';
C = 2 * 10^4;
windowRange = 0:3;
len = getOffset(4) - getOffset(2) + 1;
while (true)
    idx = getCacheIndex(struct('window', windowRange, 'component', 1:size(X, 2), 'interval', 0:2:4, 'C', C), cacheName);
    if idx.done, break; end;
    if (idx.window ~= 0)        
        model_ = retriveCacheValue(struct('window', idx.window - 1, 'component', idx.component, 'interval', idx.interval, 'C', idx.C), cacheName);
        if (~model_.cached)
            continue;
        end
        model_ = model_.model;
    else
        model_ = [];
    end
    firsts = getOffset(idx.interval);
	[ model, H ] = latentsvmTrain( X(:, idx.component, :), Y, firsts, len, idx.window, idx.C, model_ );
    derivative = getSumOfSquareDerivatives( X, Y, H, idx.component, firsts, len );     
    updateCache(idx, struct('model', model, 'H', H, 'derivative', derivative));
end