clear;
initialize();
load([getenv('data_path'), 'processed08_ica.mat'], 'X', 'Y');
setenv('log_level', '1');

C = 2 * 10^4;

% low scores for 5800000204, 5800001800, 5800000902, 1800000204, 902000204
componentPairs = [1800000902, 5800000204, 5800001800, 5800000902, 1800000204, 902000204];
len = getOffset(2) - getOffset(0) + 1;
cacheName = 'permutationTest';
dictionary = getConsolidatedDictionary('componentsSeparatelySingleFold');
seedRange = 1:10000;
while (true)
    idx = getCacheIndex(struct('componentPairs', componentPairs, 'seed', seedRange, 'C', C), cacheName);    
    if idx.done, break; end;     
    component1_bundle = floor(idx.componentPairs / 10^6);
    component1 = floor(component1_bundle / 100);
    interval1 = mod(component1_bundle, 100);
    component2_bundle = mod(idx.componentPairs, 10^6);    
    component2 = floor(component2_bundle / 100);
    interval2 = mod(component2_bundle, 100);    
    
    components = [component1, component2];
    firsts = [getOffset(interval1), getOffset(interval2)];  
    rng('default');
    rng(idx.seed);
    y1 = find(Y == 1);     
    Xmodif = zeros(size(X));
    Xmodif(:, component1, :) = X(:, component1, :); 
    Xmodif(y1, component2, :) = X(y1(randperm(sum(Y == 1))), component2, :); 
    y2 = find(Y == -1);        
    rng(idx.seed);    
    Xmodif(y2, component2, :) = X(y2(randperm(sum(Y == -1))), component2, :);    

    key1 = getCacheKeyBareReference(struct('window', 3, 'component', component1, 'interval', interval1, 'C', C));
    key2 = getCacheKeyBareReference(struct('window', 3, 'component', component2, 'interval', interval2, 'C', C));
    model_ = cat(1, dictionary(key1).model, dictionary(key2).model);      
    [ model, H ] = latentsvmTrain( Xmodif(:, components, :), Y, firsts, len, 3, idx.C, model_ );
	derivative_c1 = getSumOfSquareDerivatives( Xmodif, Y, H, component1, getOffset(interval1), len ); 
	derivative_c2 = getSumOfSquareDerivatives( Xmodif, Y, H, component2, getOffset(interval2), len );     
    writelnLog(0, 'computation for key %s derivative_c1 %f derivative_c2 %f', getCacheKey(idx), derivative_c1, derivative_c2);              
    updateCache(idx, struct('model', model, 'H', H, 'derivative_c1', derivative_c1, 'derivative_c2', derivative_c2));     
end

dictionary_perm = getConsolidatedDictionary('permutationTest');
dictionary_dependency = getConsolidatedDictionary('dependency');
for componentPair = componentPairs
    component1_bundle = floor(componentPair / 10^6);
    component2_bundle = mod(componentPair, 10^6);    
    possitive = 0;
    all = 0;
    minDiff = Inf;
    key_bundle = getCacheKeyBareReference(struct('component1', component1_bundle, 'component2', component2_bundle, 'C', C));     
    b1_bundle = dictionary_dependency(key_bundle).derivative_c1;
    b2_bundle = dictionary_dependency(key_bundle).derivative_c2;     
    for seed = seedRange
        key_perm = getCacheKeyBareReference(struct('componentPairs', componentPair, 'seed', seed, 'C', C));                            
        try
            b1_perm = dictionary_perm(key_perm).derivative_c1;
            b2_perm = dictionary_perm(key_perm).derivative_c2;
             
            minDiff = min(minDiff, b1_bundle * b2_bundle - b1_perm * b2_perm);
%              writelnLog(0, 'score %f', b1_bundle * b2_bundle - b1_perm * b2_perm);
            if (b1_bundle * b2_bundle > b1_perm * b2_perm)
                possitive = possitive + 1;
            end
            all = all + 1;
        catch
            continue;
        end
    end
    writelnLog(0, 'Component pair %d score %d out of %d, minDiff = %f', componentPair, possitive, all, minDiff);
end