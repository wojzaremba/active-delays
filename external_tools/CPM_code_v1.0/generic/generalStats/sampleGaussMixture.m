function [r mixFlags numVal] = sampleGaussMixture(...
    mixMeans,mixVars,mixProp,N,mixFlags)

% sample  [N 1] times from a mixture of gaussians with
% means given by mixMeans and variances by mixVars
% (each of these should have one value for each component)
%
% assumes scalar gaussians for now... not hard to change, use
% cholesky decomp, or mvrnd
%
% mixFlags tells which component the item was drawn from

mixProp= mixProp/sum(mixProp);

r = Inf*ones(N,1);

if ~exist('mixFlags','var')
    mixFlags = Inf*ones(N,1);
    % sample N from a multinomial
    for j=1:N
        mixFlags(j) = find(sample_hist(mixProp',1));
    end
end

for c=1:length(mixProp)
    ind = find(mixFlags==c);
    numVal(c) = length(ind);
    theseVals = randn(1,numVal(c))*sqrt(mixVars(c)) + mixMeans(c);
    r(ind)=theseVals; 
end

if any(isinf(r))
    error('missing some entries');
end


return;