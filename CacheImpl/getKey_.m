function [ key ] = getKey_( idx_list, names )
    key = '';
    [names, order] = sort(names);
    idx_list = idx_list(order);
    for i = numel(names):-1:1
        key = sprintf('%s=%d %s', names{i}, idx_list(i), key);
    end
end

