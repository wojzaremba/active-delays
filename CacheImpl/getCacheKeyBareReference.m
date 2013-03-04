function key = getCacheKeyBareReference ( reference )
    names = fieldnames(reference);
    values = [];
    for i = 1:numel(names)     
        value = eval(sprintf('reference.%s', names{i}));
        values = [values, value];
    end    
    key = getKey_(values, names);
end

