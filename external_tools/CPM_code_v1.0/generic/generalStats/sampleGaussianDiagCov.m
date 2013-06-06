% function x = sampleGaussianDiagCov(m,c)
%
% Generate a random sample from a multi-d gaussian, with diagonal
% covariance c, and mean m.

function g = sampleGaussianDiagCov(m,c)

n = length(m);
if n~=length(c)
    warning('error');
    keyboard;
end

g = randn(n,1);
g = g.*sqrt(c);
g = g + m;