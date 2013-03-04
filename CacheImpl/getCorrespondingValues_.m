function [ values ] = getCorrespondingValues_( idx_list, size_desc )
    names = fieldnames(size_desc);
    values = [];
    for i = 1:numel(names)     
        value = eval(sprintf('size_desc.%s(%d)', names{i}, idx_list(i)));        
        values = [values, value];
    end
end

