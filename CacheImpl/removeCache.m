function removeCache( cacheName )
    cache_path = [getenv('cache_path'), cacheName];
    files=what(cache_path);
    for i=1:size(files.mat, 1)
        delete([cache_path, '/', files.mat{i}]);
    end
end

