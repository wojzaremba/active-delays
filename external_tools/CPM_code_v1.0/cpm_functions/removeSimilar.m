% function newx = removeSimilar(x,numClose);
%
% removes any numbers that are within numClose of each other,
% leaving only one of them

function newx = removeSimilar(x,numClose);

newx = x;
flag=1;
for ii=1:length(x)
  if (ismember(x(ii),newx))
    closeNum = find(abs(newx-x(ii))<=numClose & newx~=x(ii));
    newx = setdiff(newx,newx(closeNum));
  end
end
