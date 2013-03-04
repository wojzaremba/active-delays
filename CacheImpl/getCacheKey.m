function key = getCacheKey ( reference )
    size_desc = reference.internal.size_desc;    
    names = fieldnames(size_desc);
    key = getKey_(reference.internal.values, names);
end

