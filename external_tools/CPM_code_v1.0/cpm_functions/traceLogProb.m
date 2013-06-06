
% function p = traceLogProb(G,val,latentTrace, states,sampleNum)
%
% Given the state for the HMM, and the latent trace,
% calculate the emission probability for all 'states'.
%
% p(val|state,latentTrace) = normalpdf(val;mu,sigma)
% where,
% mu = 2^(scale(state)) * latentTrace(tau(state))
% sigma = ??

function p = traceLogProb(G,val,z,states,sampleNum,...
    logSigma,twoSigma2Inv,LOGSQRT2PI,myMuTemp)

%% want to specify z here because in z2Function, do NOT want G.z

%myMu = (2.^G.scales(G.stateToScaleTau(:,1))).*...
%        (G.z(G.stateToScaleTau(:,2)));

%myMuTemp =  G.traceLogConstant(states,:).*z(G.stateToScaleTau(states,2),:);
myMu = myMuTemp(states,:).*G.u(sampleNum);

%p = lognormpdf(val,myMu,G.sigmas(sampleNum));
%p = lognormpdf(val,myMu,logSigma,twoSigma2Inv,LOGSQRT2PI);

p2=zeros(G.numBins,length(states));

for bb=1:G.numBins
  p2(bb,:) = lognormpdf(val(bb),myMu(:,bb),logSigma(bb),...
      twoSigma2Inv(bb),LOGSQRT2PI,G.numBins)';
end

p=sum(p2,1);

if abs(p)<1e-50
    keyboard;
end

% if any(p>log(realmax))
%   warning('here');
%   keyboard;
% end




