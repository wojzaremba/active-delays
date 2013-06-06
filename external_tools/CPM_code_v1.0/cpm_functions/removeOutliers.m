%function qmzNew = removeOutliers(qmzOld)
%
% takes cell array of qmz (time x M/Z) and set them
% to zero

function qmzNew = removeOutliers(qmzOld)

maxAllowed = 10^8;
qmzNew=cell(size(qmzOld));

for ii=1:length(qmzOld)
  temp=qmzOld{ii};
  temp(find(temp>maxAllowed))=0;
  qmzNew{ii}=temp;
end
