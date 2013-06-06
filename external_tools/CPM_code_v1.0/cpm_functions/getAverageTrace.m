% function [avgTrace,posCounts] = getAverageTrace(allSamples,G,scaleAndTimes)
%
% avgTrace averages the traces, and posCounts keeps track of how
% many traces uses each point

function [avgTrace,posCounts] = getAverageTrace(allSamples,G,scaleAndTimes)

N=length(allSamples{1});
posCounts = zeros(G.numTaus,1);
avgTrace = zeros(G.numTaus,1);

for ii=1:G.numSamples
  st = squeeze(scaleAndTimes(ii,:,:));
  
  a=allSamples{ii}; 
  b=G.u(ii)*2.^(G.scales(st(:,1))); 
  myTemp=a(:)./b(:);
  
  avgTrace(st(:,2)) = avgTrace(st(:,2)) + myTemp;
  posCounts(st(:,2)) = posCounts(st(:,2)) + ones(N,1);
end


usedInd=find(posCounts);
avgTrace(usedInd) = avgTrace(usedInd)./posCounts(usedInd);

