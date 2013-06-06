% function p = traceProbU(state,val,z,mySigma,justTheseStates,sampleNum)
%
% Given the state for the HMM, and the latent trace,
% calculate the emission probability:
%
% p(val|state,latentTrace) = normalpdf(val;mu,sigma)
% where,
% mu = 2^(scale(state)) * latentTrace(tau(state))
% sigma = ??

function p = traceProbU(G,val,z,justTheseStates,...
    sampleNum,logSigma,twoSigma2Inv,LOGSQRT2PI,myMuTemp,uMatRep)

%if exist('uMatRep')
%keyboard;

p2 = (traceLogProbU(G,val,z,justTheseStates,sampleNum,...
       logSigma,twoSigma2Inv,LOGSQRT2PI,myMuTemp,uMatRep))';

%% above can go very small, so add some positive number so that when
%% when exponentiate, it is ok.  As long as this is the same number
%% always for a given run, it is fine, however, we cannot compare
%% likelihoods across runs (but variance and dot product are fine)

magick = 0;%12;
p3 = p2 + G.numBins*(magick);
p = exp(p3);
    
%p = exp(p2);

%else
%    p = exp(traceLogProb(G,val,z,justTheseStates,sampleNum,...
%        logSigma,twoSigma2Inv,LOGSQRT2PI))';
%end

%if isinf(p)
%  display('isinf in traceProb.m');
%  keyboard;
%end
