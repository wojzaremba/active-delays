function [ index ] = ensureCacheFileindex_( filepath, size_desc_ )
    try
        load(filepath, 'index', 'size_desc', 'dictionary')
        if (isequal(size_desc, size_desc_))
            return;
        end
    catch
    end
    if (~exist('dictionary', 'var'))
        dictionary = containers.Map();
    end
    [ idxs, allwidth ] = getDescriptionSize_(size_desc_);
    index = zeros(allwidth, 1);
    for idx = 1:allwidth
        names = fieldnames(size_desc_);
        idx_list = getMod_(idx, idxs); 
        corresponding_values = getCorrespondingValues_( idx_list, size_desc_ );
        key = getKey_(corresponding_values, names);
        try
            dictionary(key);
            index(idx) = true;
        catch
        end
    end
    size_desc = size_desc_;
    save(filepath, 'index', 'size_desc', 'dictionary'); 
end

