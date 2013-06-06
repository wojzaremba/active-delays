% function timeLogPrior = getTimeLogPrior(G);
%
% get the log prior for the beginning time states

function timeLogPrior = getTimeLogPrior(G);

timeLogPrior = -Inf*ones(1,G.numTaus);

%% equal prob in any of valid start states
timeLogPrior(1:G.numStartTimeStates) = log(1/G.numStartTimeStates);

return;

