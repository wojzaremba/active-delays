function [ idxs, all_width ] = getDescriptionSize_( size_desc )
    names = fieldnames(size_desc);
    idxs = [];
    all_width = 1;
    for i = 1:numel(names)
        width = eval(sprintf('size(size_desc.%s, 2)', names{i}));
        idxs = [idxs, width];
        all_width = all_width*width;
    end
end

