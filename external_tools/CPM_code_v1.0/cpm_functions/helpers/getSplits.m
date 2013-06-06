function splits = getSplits(ind);

% get all possible two way splits of these indexes

if mod(length(ind),2)~=0
    error('expects even sized ind variable');
end

indL = length(ind);
splitSize = indL/2;

%% get all groups of size indL/2
allGp = getUniqueGroups(ind,splitSize);
numSplits = size(allGp,2);

%% these are arranged (?) in such a way that the n'th
%% entry is the complement of the 1st entry, and the 
%% n-1'th entry the complement of the 2nd, etc. so that
%% we need only take the first half, or second half of
%% the group
for sp = 1:numSplits/2 %% otherwise we duplicate
    sp1 = allGp(:,sp)';
    sp2 = setdiff(ind,sp1);
    
    if ~all(sp2==allGp(:,numSplits-sp+1)')
        keyboard;
    end
    
    %[sp1' sp2']'
    splits(:,1,sp) = sp1;
    splits(:,2,sp) = sp2;
end