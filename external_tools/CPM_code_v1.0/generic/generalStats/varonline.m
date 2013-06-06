% function y = varonline(x)
%
% Compute the variance in an on-line fashion, to save
% memory usage.
%
% Always takes it along the first dimension, so that
% varonline(x) = var(x) (if first dimension is non-singleton)
%

% NOTES, for a vector X = (x_1, x_2, ... x_N):
% var(X) = 1\(N-1) [\sum_i (x_i - xbar)^2]
%        = 1\(N-1) [\sum_i (x_i^2 - 2*x_i*xbar + xbar^2)]
%        = 1\(N-1) [\sum_i x_i^2  -\sum_i 2*x_i*xbar + \sum_i xbar^2]
%        = 1\(N-1) [\sum_i x_i^2  -2*xbar * \sum x_i + N*xbar^2]
%
% (letting xbar = 1/N sum_j x_j)
% let S = sum_j x_j
% then xbar = S/N
%        = 1\(N-1) [\sum_i x_i^2  -2*S^2/N + N*(S/N)^2]
%        = 1\(N-1) [\sum_i x_i^2  -2*S^2/N + S^2/N]
%        = 1\(N-1) [\sum_i x_i^2  - S^2/N]

function v = varonline(x)

%% operate along the first dimension
dims = size(x);
v = zeros(dims(2:end));
N = dims(1);

%% iterate on-line
xiTally2 = zeros(size(v));
S= zeros(size(v));
for n=1:N
    oneX = permute(x(n,:,:),[2 3 1]);
    xiTally2 = xiTally2 + oneX.^2;
    S =  S + oneX;
end

v = 1/(N-1) * (xiTally2 - S.^2/N);

return;

%% sanity check
x = rand(5,6,7);
b=squeeze(var(x));
myV = varonline(x);
imstats(myV-b);