% function smoothPriorLikTerm = getSmoothLike(G,z,u)
%
% calculate the regularization part of the log likelihood
%     -lambda*sum(diff(trace).^2)
%
% returns one component per class
%
%  see also getSmoothLikeZ, getSmoothLikeU

function likTerm = getSmoothLike(G,z,u)


%% trace is [numTaus,numClass]
%% Note that diff works along the rows

likTerm = -G.lambda*sum(sum((diff(z).^2),1),3);
likTerm = squeeze(likTerm);
likTerm = likTerm.*getUbar2(G,u);

return;