initialize();
load([getenv('data_path'), 'processed08_ica.mat'], 'X', 'Y');
setenv('log_level', '1');
folds = 5;
cacheName = 'componentsSeparately';
C = 2 * 10^4;
windowRange = 0:3;
len = getOffset(4) - getOffset(2) + 1;
while (true)
    idx = getCacheIndex(struct('window', windowRange, 'fold', 1:folds, 'component', 1:size(X, 2), 'interval', 0:2:4, 'C', C), cacheName);
    if idx.done, break; end;
    [ XTrain, YTrain, XTest, YTest ] = drawData(X, Y, idx.fold, folds);
    if (idx.window ~= 0)        
        model_ = retriveCacheValue(struct('window', idx.window - 1, 'fold', idx.fold, 'component', idx.component, 'interval', idx.interval, 'C', idx.C), cacheName);
        if (~model_.cached)
            continue;
        end
        model_ = model_.model;
    else
        model_ = [];
    end
    firsts = getOffset(idx.interval);
	[ model, H ] = latentsvmTrain( XTrain(:, idx.component, :), YTrain, firsts, len, idx.window, idx.C, model_ );
    acc = latentsvmClassify(model, XTest(:, idx.component, :), YTest, firsts, len, idx.window);
    writelnLog(0, [getCacheKey(idx), ' acc = %f'], acc);
    updateCache(idx, struct('model', model, 'H', H, 'acc', acc));
end

intervalRange = 0:2:4;
dictionary = getConsolidatedDictionary(cacheName);
for intervalIdx = 1:size(intervalRange, 2)
    for component = 1:size(X, 2)
        writelnLog(3, 'Analysing component %d over interval %d', component, intervalRange(intervalIdx));
        acc = zeros(folds, size(windowRange, 2));
        for windowIdx = 1:size(windowRange, 2)
            for fold = 1:folds
                key = getCacheKeyBareReference(struct('window', windowRange(windowIdx), 'fold', fold, 'component', component, 'interval', intervalRange(intervalIdx), 'C', C));
                acc(fold, windowIdx) = dictionary(key).acc; 
            end
        end
        macc = mean(acc);
        if (macc(4) > 0.555) && (macc(4) > macc(1) + 0.01)
            writelnLog(0, 'Component %d interval %d', component, intervalRange(intervalIdx));
        end
    end
end