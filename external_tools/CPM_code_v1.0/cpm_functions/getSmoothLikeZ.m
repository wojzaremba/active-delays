% function smoothPriorLikTerm = getSmoothLikeZ(G,z,ubar2)
%
% calculate the regularization part of the log likelihood
%     -lambda*sum(diff(trace).^2)
%
% returns one component per class
% assumes that z is provided, but u is not
%
% assumes that ubar2 is provided as well

function likTerm = getSmoothLikeZ(G,z,ubar2)

%warning('in here now'); keyboard;

%% trace is [numTaus,numClass]
%% Note that diff works along the rows

likTerm = -G.lambda*sum(sum((diff(z).^2),1),3);
%keyboard;
%likTerm = squeeze(likTerm);
%whos likTerm ubar2
likTerm = likTerm.*ubar2;


return;