function x = varCell2Vec(d)

%% converts a vector cell array, with each cell having a variable
%% length array, into a single numeric vector

if min(size(d))>1
    error('cell array should be 1d');
end

x=[];
for jj=1:length(d)
    moreVals = d{jj};
    x = [x; moreVals(:)];
end