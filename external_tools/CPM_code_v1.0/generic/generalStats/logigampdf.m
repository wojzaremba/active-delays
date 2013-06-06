function logp=logigampdf(x,a,b)

% evaluates the log of the pdf of a inverse gamma distribution,
% using the scale factor (b)
% as matlab uses it for the gamma distribution
%
% ADAPTED BY Jennifer Listgarten from igampdf.m by
% Vasco Curdia and Daria Finocchiaro
% Created on March 10, 2004

logp= log(b.^(-a)) + (-(a+1))*log(x) ...
      + (-1./(b*x)) - gammaln(a);
