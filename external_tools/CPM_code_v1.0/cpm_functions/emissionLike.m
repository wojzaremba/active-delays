% function ll = emissionLike(G,gammas,trace,oneSample,sampleNum)
%
% Given posterior over states (gammas), calculate the log likelihood
% (of emission probabilitiy term)

function ll = emissionLike(G,gammas,trace,oneSample,sampleNum)

ll = 0;
for ii=1:G.numRealTimes
  emLogProbs = traceLogProb(G,oneSample(ii),trace,1:G.numStates,sampleNum);
  ll = ll + sum(emLogProbs'.*gammas(:,ii));
end
