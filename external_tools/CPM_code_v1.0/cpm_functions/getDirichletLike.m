% function [timeTerm scaleTerm] = getDirichletLike(G)
% 
% Calculate the part of the log likelihood arising from 
% the dirichlet prior on the scale and time transitions

function [timeTerms,scaleTerm] = getDirichletLike(G)

timeTerms = zeros(1,G.numSamples);

%% time priors
for ii=1:G.numSamples
  timeTerms(ii) = sum(log(G.D(ii,:)).*G.pseudoT);
end

%% scale priors
scaleTerm = 0;

if (any(G.pseudoS~=0))
  for cc=1:G.numClass
    scaleTerm = scaleTerm + sum(log([G.S(cc) 1-G.S(cc)]).*G.pseudoS);
  end
end

