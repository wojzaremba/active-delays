clear;
initialize();
load([getenv('data_path'), 'processed08_ica.mat'], 'X', 'Y');
setenv('log_level', '1');

C = 2 * 10^4;
folds = 5;
windowRange = 0:3;
cacheName = 'dependency';
components = [];
intervals = [];
intervalRange = 0:2:4;
dictionary = getConsolidatedDictionary('componentsSeparately');
len = getOffset(2) - getOffset(0) + 1;
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
            interval = intervalRange(intervalIdx);
            writelnLog(0, 'Component %d interval %d', component, interval);
            components = [components; component];
            intervals = [intervals; interval];
        end
    end
end

dictionary = getConsolidatedDictionary('componentsSeparatelySingleFold');
bundle = components*100 + intervals;
bundle = bundle';
while (true)
    idx = getCacheIndex(struct('component1', bundle, 'component2', bundle, 'C', C), cacheName);
    if idx.done, break; end;     
    tmp = retriveCacheValue(struct('component1', idx.component2, 'component2', idx.component1, 'C', C), cacheName);
    if (tmp.cached)
      model_ = reshape(model, [2, len]);
      model_ = [model_(2, :); model_(1, :)];        
      updateCache(idx, struct('model', model_(:), 'H', tmp.H, 'derivative_c1', tmp.derivative_c2, 'derivative_c2', tmp.derivative_c1));         
      continue;
    end        
    if (idx.component1 == idx.component2)
        updateCache(idx, struct('garbage', true));          
        continue;
    end
    key1 = getCacheKeyBareReference(struct('window', 3, 'component', floor(idx.component1/100), 'interval', mod(idx.component1, 100), 'C', C));
    key2 = getCacheKeyBareReference(struct('window', 3, 'component', floor(idx.component2/100), 'interval', mod(idx.component2, 100), 'C', C));
    model_ = cat(1, dictionary(key1).model, dictionary(key2).model);    
    firsts = [getOffset(mod(idx.component1, 100)); getOffset(mod(idx.component2, 100))];
    components = [floor(idx.component1/100); floor(idx.component2/100)];    
    [ model, H ] = latentsvmTrain( X(:, components, :), Y, firsts, len, 3, idx.C, model_ );
	derivative_c1 = getSumOfSquareDerivatives( X, Y, H, floor(idx.component1 / 100), getOffset(mod(idx.component1, 100)), len ); 
	derivative_c2 = getSumOfSquareDerivatives( X, Y, H, floor(idx.component2 / 100), getOffset(mod(idx.component2, 100)), len );     
    writelnLog(0, 'computation for key %s derivative_c1 %f derivative_c2 %f', getCacheKey(idx), derivative_c1, derivative_c2);              
    updateCache(idx, struct('model', model, 'H', H, 'derivative_c1', derivative_c1, 'derivative_c2', derivative_c2));            
end

%1800
%5800
%902
%204

dictionary_dependency = getConsolidatedDictionary('dependency');
for c1 = bundle
    for c2 = bundle
        if c1 <= c2
            continue;
        end
        
        key_separated1 = getCacheKeyBareReference(struct('window', 3, 'component', floor(c1/100), 'interval', mod(c1, 100), 'C', C));
        key_separated2 = getCacheKeyBareReference(struct('window', 3, 'component', floor(c2/100), 'interval', mod(c2, 100), 'C', C));        
        key_bundle = getCacheKeyBareReference(struct('component1', c1, 'component2', c2, 'C', C));                
        s1 = dictionary(key_separated1).derivative;
        s2 = dictionary(key_separated2).derivative;        
        b1 = dictionary_dependency(key_bundle).derivative_c1;
        b2 = dictionary_dependency(key_bundle).derivative_c2;     
        
%         if (b1 > s1*0.85) && (b2 > s2*0.80)
%         if (b1 * b2 > s1* s2 * 0.75)
            writelnLog(0, 'c %d meassure separate %f %f, meassure bundle %f %f', ...
              10^6 * c1 + c2, s1, s2, b1, b2);
%         end
    end
end

