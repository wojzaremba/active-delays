initialize();
load([getenv('data_path'), 'processed08_ica.mat'], 'X', 'Y');
setenv('log_level', '1');

len = getOffset(2) - getOffset(0) + 1;

intervalRange = 0:2:4;
dictionary = getConsolidatedDictionary('componentsSeparatelySingleFold');
for intervalIdx = 1:size(intervalRange, 2)
    for component = 1:size(X, 2)
        key = getCacheKeyBareReference(struct('window', 3, 'component', component, 'interval', intervalRange(intervalIdx), 'C', C));
        noalign = getSumOfSquareDerivatives( X, Y, zeros(size(X, 1), 1), component, getOffset(intervalRange(intervalIdx)), len ); 
        align = getSumOfSquareDerivatives( X, Y, dictionary(key).H, component, getOffset(intervalRange(intervalIdx)), len ); 
        writelnLog(0, '%s meassure without alignment = %f, with alignment = %f', key, noalign, align);
    end
end