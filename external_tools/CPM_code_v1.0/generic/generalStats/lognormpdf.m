% function logp = lognormpdf(val,myMu,mySigma,twoSigma2Inv,LOGSQRT2PI,numBins)
%
% returns the lognormalpdf, efficiently, in 1D
%
% if val is a vector, then the result is also a vector
% uses log_e

%function logp = lognormpdf(val,myMu,mySigma,LOGSQRT2PI)
function logp = lognormpdf(val,myMu,logSigma,...
    twoSigma2Inv,LOGSQRT2PI,numBins)
%% pass all this junk in an effort to make things faster

%global LOGSQRT2PI;
%logp = -LOGSQRT2PI -log(mySigma) - (val-myMu).^2/(2*mySigma^2);
%logp = -log(sqrt(2*pi)) -log(mySigma) - (val-myMu).^2/(2*mySigma^2);

%logp = 1e2 + -LOGSQRT2PI -logSigma - (val-myMu).^2*twoSigma2Inv;
%numBins=2;


%extraTerm=(numBins>1)*1e2;
%extraTerm=0;
%logp = extraTerm  + -LOGSQRT2PI -logSigma - (val-myMu).^2*twoSigma2Inv;
logp = -LOGSQRT2PI -logSigma - (val-myMu).^2*twoSigma2Inv;


%if isinf(logp)
%  display('inf in lognormpdf');
%  keyboard;
%end

%logp = 1e2  + -LOGSQRT2PI -logSigma - (val-myMu).^2*twoSigma2Inv;
%logp = 0  + -LOGSQRT2PI -logSigma - (val-myMu).^2*twoSigma2Inv;
