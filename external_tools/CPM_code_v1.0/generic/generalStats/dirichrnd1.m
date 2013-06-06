% function r = dirichrnd1(alpha)
%
% Obtain a single random sample from a Dirichlet distribution
% with k-dimensional parameter vector alpha.
%
% The single sample obtained is the same dimension as alpha
%
% See dirichrnd to sample from more than one at a time

function r = dirichrnd1(alpha)

%% independent sample each dimension from a gamma distribution
r = gamrnd(alpha,1,size(alpha));

%% then normalize them
r = r /sum(r);
