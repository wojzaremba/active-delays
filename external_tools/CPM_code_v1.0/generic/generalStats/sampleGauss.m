% function x = sampleGauss(m,c)
%
% Generate a random sample from a 1D gaussian with 
% variance c, and mean m.

function g = sampleGauss(m,c)

g = randn(1);
g = g.*sqrt(c) + m;
