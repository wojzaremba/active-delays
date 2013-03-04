function updateCache(reference, data)
    cache_name = reference.internal.cache_name;
    cache_path = [getenv('cache_path'), cache_name]; 
    host = getComputerName();
    filepath = [cache_path, '/', host];
    ensureCacheFileindex_(filepath, reference.internal.size_desc);
    load(filepath, 'index', 'size_desc', 'dictionary')
    index(reference.internal.idx) = 1;   
    data.internal.host = host;       
    key = getCacheKey(reference);
    dictionary(key) = data;
    save(filepath, 'index', 'size_desc', 'dictionary');
    writelnLog(1, 'saving key %s', key);
end
