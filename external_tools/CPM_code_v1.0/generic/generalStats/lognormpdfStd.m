% function logp = lognormpdfStd(val,myMu,std)
%
% returns the lognormalpdf, efficiently, in 1D, given the st. dev.
%
% if val is a vector, then the result is also a vector
% see also lognormpdf

function logp = lognormpdfStd(val,myMu,myStd)


LOGSQRT2PI=0.91893853320467266954;
logp = -LOGSQRT2PI -log(myStd) - 0.5*(val-myMu).^2/myStd^2;

