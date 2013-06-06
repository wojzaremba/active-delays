%function newD=adjustD(oldD,minTimeTrans)
%
% if any values went too small, then the small
% values are set to minTimeTrans, and everything
% renormalized

function newD=adjustD(oldD,minTimeTrans)

newD=oldD;
newD(find(oldD<minTimeTrans))=minTimeTrans;
for ii=1:size(newD,1)
  newD(ii,:)= newD(ii,:)/sum(newD(ii,:));
end
