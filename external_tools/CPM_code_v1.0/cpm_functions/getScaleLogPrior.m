% function scaleLogPrior = getScaleLogPrior(G);
%
% get the log prior for the beginning scale states

function scaleLogPrior = getScaleLogPrior(G);

scaleLogPrior = -Inf*ones(1,G.numScales);

if (~G.oneScaleOnly)
  %% equal prob in any of valid start states, centered around the 
  %% the neutral states
  neutralState = find(G.scales==0);
  scaleOffset = neutralState-1;
  scaleLogPrior((1:G.numStartScaleStates)+scaleOffset) = log(1/G.numStartScaleStates);
else
  %% only start of in first scale (G.u will force it to go neutral)
  neutInd=find(G.scales==0);
  scaleLogPrior(neutInd) = 0;
end
  
return;
