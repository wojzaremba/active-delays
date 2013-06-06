% function smoothPriorLikTerm = getSmoothLikeU(G,u)
%
% calculate the regularization part of the log likelihood
%     -lambda*sum(diff(trace).^2)
%
% returns one component per class

function likTerm = getSmoothLikeU(G,u)

z=G.z;

%warning('in here now'); keyboard;

%% trace is [numTaus,numClass]
%% Note that diff works along the rows

likTerm = -G.lambda*sum(sum((diff(z).^2),1),3);
%likTerm = squeeze(likTerm);
%keyboard;
likTerm = likTerm.*getUbar2(G,u);

return;