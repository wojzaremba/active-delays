function [ ret ] = getCacheIndex( size_desc, cache_name )
    [ idxs, allwidth ] = getDescriptionSize_( size_desc );
    join_index = zeros(allwidth, 1); 
    cache_path = [getenv('cache_path'), '/', cache_name, '/'];
    if (~exist(cache_path, 'dir'))
        mkdir(cache_path);
    end
    files=what(cache_path);
    for i=1:size(files.mat, 1)     
        index = ensureCacheFileindex_([cache_path, files.mat{i}], size_desc);
        join_index = min(join_index + index, ones(size(join_index)));
    end
    not_computed = find(join_index == 0);
    writeLog(1, 'Number of iterations left %d out of %d\n', length(not_computed(:)), length(join_index(:)));
    if (size(not_computed, 1) == 0)
        ret = struct('done', true);
        return;
    end
    rng('default');
    rng(mod(java.lang.System.currentTimeMillis, 1000))
    idx = randi(size(not_computed, 1), 1);
    idx = not_computed(idx);
    rng('default');
    ret = struct('done', false, 'internal', struct('idx', idx, 'size_desc', size_desc));
    idx_list = getMod_(idx, idxs);
    names = fieldnames(size_desc);
    values = [];
    for i = 1:numel(names)     
        value = eval(sprintf('size_desc.%s(%d)', names{i}, idx_list(i)));
        eval(sprintf('ret.%s = %d;', names{i}, value));
        values = [values, value];
    end
    ret.internal.values = values;
    ret.internal.cache_name = cache_name;
end

