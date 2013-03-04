function dictionary_value = retriveCacheValue ( reference, cache_name )
    cache_path = [getenv('cache_path'), '/', cache_name, '/'];
    key = getCacheKeyBareReference(reference);
    files=what(cache_path);
    for i=1:size(files.mat, 1)     
        load([cache_path, files.mat{i}], 'dictionary');
        try
            dictionary_value = dictionary(key);
            dictionary_value.cached = true;
            return;
        catch
        end
    end
    dictionary_value = struct('acc', NaN, 'cached', false);
end

