% function didConverge = checkConverge(oldG,newG)
%
% Check if every parameters has had a relative change of 
% less than thresh:
%
% (newParam-oldParam)/oldParam < thresh
%
% parameters that 

function didConverge = checkConverge(oldG,newG)

didConverge=1;

myDiff = abs(oldG.sigmas - newG.sigmas)./oldG.sigmas;
if (any(myDiff(:)>newG.thresh))
  didConverge=0;
  return;
end

myDiff = abs(oldG.D - newG.D)./oldG.D;
if (any(myDiff(:)>newG.thresh))
  didConverge=0;
  return;
end

myDiff = abs(oldG.S - newG.S)./oldG.S;
if (any(myDiff(:)>newG.thresh))
  didConverge=0;
  return;
end

myDiff = abs(oldG.u - newG.u)./oldG.u;
if (any(myDiff(:)>newG.thresh))
  didConverge=0;
  return;
end

myDiff = abs(oldG.z(:) - newG.z(:))./oldG.z(:);
if (any(myDiff(:)>newG.thresh))
  didConverge=0;
  return;
end
