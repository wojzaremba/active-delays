% function logp = lognormpdfVar(val,myMu,var)
%
% returns the log(normalpdf), efficiently, in 1D, given the variance
%
% **NOT THE LOG-NORMAL, but log(N(val|myMu,var))
%
% if val is a vector, then the result is also a vector
% see also lognormpdf

function logp = lognormpdfVar(val,myMu,myVar)


LOGSQRT2PI=0.91893853320467266954;
logp = -LOGSQRT2PI -0.5*log(myVar) - 0.5*(val-myMu).^2/myVar;

