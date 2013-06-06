% function likTerm = getSmoothLikeInd(G,z,u)
%
% calculate the regularization part of the log likelihood
%     -lambda*sum(diff(z).^2)
%
% returns one component per class

function likTerm = getSmoothLikeInd(G,z,u)

if G.USE_CPM2
    warning('use getSmoothLike instead');
    keyboard;
end

%% need this for uFunction (when updating u)
if ~exist('u')
    u=G.u;
end

%% need z here because we do NOT want G.z

%% z is [numTaus,numClass]
%% Note that diff works along the rows

likTerm = sum((diff(z).^2),1);
likTerm = squeeze(likTerm);
likTerm = -G.lambda*(likTerm.*getUbar2(G,u));

%warning('h'); keyboard;

return;

