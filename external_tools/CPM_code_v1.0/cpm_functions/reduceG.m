% function newG = reduceG(ind,G)
%
% keeps same G, but alters some entries to only the specified ind
% (to use in showClassTraces)

function newG = reduceG(ind,G)

newG=G;
newG.numSamples=length(ind);
newG.D=G.D(ind,:);
newG.u=G.u(ind);
newG.sigmas=G.sigmas(ind);
