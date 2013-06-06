% function xx = last(yy)
%
% This is useful when you are working with cell arrays of vectors 
% and want to index into the cell array and the vector all at
% once.  For eg. last(yy{1});

function xx = last(yy)

if isempty(yy)
    xx=[];
else
    xx=yy(end);
end


return
