% function logprobs = logexppdf(val,mu)
%
%
% Returns the log probability of the exponential function, where
% mu is the mean: p(val) = 1/u * exp(-1/u*val);
%
% mu must be scalar.  if val is a vector, then a vector of
% results is returned

function logprobs = logexppdf(val,mu)

invmu = 1/mu;

logprobs = log(invmu) - invmu*val;
