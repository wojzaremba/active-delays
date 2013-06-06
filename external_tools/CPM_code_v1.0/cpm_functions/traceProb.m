% function p = traceProb(state,val,z,mySigma,justTheseStates,sampleNum)
%
% Given the state for the HMM, and the latent trace,
% calculate the emission probability:
%
% p(val|state,latentTrace) = normalpdf(val;mu,sigma)
% where,
% mu = 2^(scale(state)) * latentTrace(tau(state))
% sigma = ??

function p = traceProb(G,val,z,justTheseStates,...
    sampleNum,logSigma,twoSigma2Inv,LOGSQRT2PI,myMuTemp)

%if G.USE_CPM2
%    error('shouldnt be here');
%end

% if exist('uMatRep')
%     p = exp(traceLogProb(G,val,z,justTheseStates,sampleNum,...
%         logSigma,twoSigma2Inv,LOGSQRT2PI,uMatRep))';
% else
    p = exp(traceLogProb(G,val,z,justTheseStates,sampleNum,...
        logSigma,twoSigma2Inv,LOGSQRT2PI,myMuTemp))';
%end

%if isinf(p)
%  display('isinf in traceProb.m');
%  keyboard;
%end
