% function headerAbun = getHeaderAbun(scans)
%
% Tallys the total abundance of mz generated at
% each scan.

function headerAbun = getHeaderAbun(scans)

headerAbun=zeros(size(scans));
for s=1:length(scans)
    temp=scans{s};
    headerAbun(s)=sum(temp(:,3));
end