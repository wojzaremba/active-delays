% function xx = first(yy)
%
% This is useful when you are working with cell arrays of vectors 
% and want to index into the cell array and the vector all at
% once.  For eg. first(yy{1});

function xx = first(yy)

if isempty(yy)
    xx=[];
else
    xx=yy(1);
end
return
