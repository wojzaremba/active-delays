function [ dictionary_ ] = getConsolidatedDictionary ( cache_name )
    cache_path = [getenv('cache_path'), '/', cache_name, '/']; 
    files=what(cache_path);
    dictionary_ = containers.Map();
    for i=1:size(files.mat, 1)     
        load([cache_path, files.mat{i}], 'dictionary');
        for keyIdx = 1:size(dictionary.keys, 2)
            tmp = dictionary.keys;
            key = tmp{keyIdx};
            dictionary_(key) = dictionary(key);
        end
    end
end

