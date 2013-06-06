function result = logsumSparse(xx)
%function result = logsumSparse(xx,dim)

% Wrapper for MEX function which computes logsum of a sparse
% matrix, ignoring the entries which are not present (rather
% than treating them as zeros).
%
% NOTE: ONLY WORKS FOR DIM=1

global LOGREALMAXDIV2
global TWOLOGNUMSTATES

%alpha = max(xx,[],1) - log(realmax)/2 + 2*log(G.numStates);
alpha = max(xx,[],1) - LOGREALMAXDIV2 + TWOLOGNUMSTATES;
result=logsumSparseMEX(xx,alpha);   



