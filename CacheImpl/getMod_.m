function [ list_idx ] = getMod_( idx, idxs )
    tmpidx = idx - 1;
    list_idx = [];
    for i = size(idxs, 2):-1:1
        list_idx = [mod(tmpidx, idxs(i)) + 1, list_idx];
        tmpidx = floor(tmpidx / idxs(i));
    end
end

