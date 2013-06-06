% function stateLogPrior = getStateLogPrior(G,oneScaleOnly)
%
% get state prior, for all states

function stateLogPrior = getStateLogPrior(G,oneScaleOnly)


timeLogPrior = getTimeLogPrior(G);
% figure, plot(timeLogPrior,'+');

scaleLogPrior = getScaleLogPrior(G);
% figure, plot(scaleLogPrior,'+');

tempA=timeLogPrior(G.stateToScaleTau(:,2));
tempB=scaleLogPrior(G.stateToScaleTau(:,1));

stateLogPrior = tempA(:)' + tempB(:)';

return;

%figure, plot(stateLogPrior,'+');
%temp=find(isinf(stateLogPrior));
%temp(1)
