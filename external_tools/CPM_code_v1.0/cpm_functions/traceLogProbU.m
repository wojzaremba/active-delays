
% function p = traceLogProbU(G,val,latentTrace, states,sampleNum)
%
% Given the state for the HMM, and the latent trace,
% calculate the emission probability for all 'states'.
%
% p(val|state,latentTrace) = normalpdf(val;mu,sigma)
% where,
% mu = 2^(scale(state)) * latentTrace(tau(state))
% sigma = ??

function p = traceLogProbU(G,val,z,states,sampleNum,...
    logSigma,twoSigma2Inv,LOGSQRT2PI,myMuTemp,uMatRep)

%% want to specify z here because in z2Function, do NOT want G.z

%myMuTemp =  G.traceLogConstant(states,:).*z(G.stateToScaleTau(states,2),:);
%%% uses only some states, as dictated by states

%if G.numBins>1
%    uMatRep2 = permute(uMatRep(sampleNum,:,states),[3 1 2]);
%    myMu = myMu.*uMatRep2;
%else
    myMu = myMuTemp(states,:).*uMatRep(states,:);
%end

%p = lognormpdf(val,myMu,G.sigmas(sampleNum));
%p = lognormpdf(val,myMu,logSigma,twoSigma2Inv,LOGSQRT2PI);

p2=zeros(G.numBins,length(states));

for bb=1:G.numBins
  p2(bb,:) = lognormpdf(val(bb),myMu(:,bb),logSigma(bb),...
      twoSigma2Inv(bb),LOGSQRT2PI,G.numBins)';
end

p=sum(p2,1);

% if abs(p)<1e-50
%     keyboard;
% end

% if any(p>log(realmax))
%   warning('here');
%   keyboard;
% end




