% function newDD = truncate(dd,keepScans,scaleFacs)
%
% keepScans tells us which parts of dd to use (endpoints)
% dd is a cell array, one per experiment.
% keepScans is either a 1D array, valid for all of dd
% or, a cell array of the same length as dd, applied to
% each experiment in dd, in turn
%
% if dd{ii} is not long enough, it just takes more from the beginning.

function newDD = truncate(dd,keepScans,scaleFacs)
 
numTotal = length(dd);

useSingleRange=1;

if iscell(keepScans)
  useSingleRange=0;
  if length(keepScans)~=numTotal
    [length(keepScans) numTotal]
    error('keepScans should be same length as dd');
  end
  numScans=diff(keepScans{1})+1;
else
  numScans=diff(keepScans)+1;
end

temp=dd{1};
if (min(size(temp))==1)
  isVec=1;
elseif (length(size(temp))==2)
  isVec=0;
else
  error('Only for 1d and 2d data');
end

for ii=1:numTotal 
  temp=dd{ii};
  if isVec
    numTempScans = length(temp);
  else
    numTempScans = size(temp,1);
  end
  if useSingleRange
    ks=keepScans;
  else
    ks=keepScans{ii};
  end
  if ks(2)>numTempScans
    thisRange=(numTempScans-numScans+1):numTempScans;
  else
    thisRange=ks(1):ks(2);
  end
  %[thisRange(1) thisRange(end)]
  if (isVec)
    newDD{ii}=temp(thisRange);
  else
    newDD{ii}=temp(thisRange,:);
  end
  if exist('scaleFacs')==1
      newDD{ii}=newDD{ii}*scaleFacs(ii);
  end
end
