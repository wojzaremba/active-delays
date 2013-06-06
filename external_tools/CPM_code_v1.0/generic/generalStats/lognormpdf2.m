% function logp = lognormpdf2(val,myMu,mySigma)
%
% returns the lognormalpdf, efficiently, in 1D
%
% if val is a vector, then the result is also a vector
% uses log_e

function logp = lognormpdf2(val,myMu,mySigma)

logp = -log(sqrt(2*pi)) -log(mySigma) - (val-myMu).^2/(2*mySigma^2);
