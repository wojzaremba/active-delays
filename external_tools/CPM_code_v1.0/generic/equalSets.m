%function x = equalSets(a,b)

function x = equalSets(a,b)

x=1;

if ~isempty(setdiff(a,b))
    x=0;
elseif (~isempty(setdiff(b,a)))
    x=0;
end