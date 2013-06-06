%function [ll,mainLikes,timePriorTerm,scalePriorTerm,nuTerm,lambdaTerm] = likelihood(samples,G)
%
% Calculate the likelihood of the the samples
% i.e. integrating out over hidden states

function [ll,alphas,mainLikes,timePriorTerm,scalePriorTerm,...
    scaleCenterPriorTerm,nuTerm,lambdaTerm,allLikeButLamNu] = ...
    likelihood(samples,G)

if length(samples)~=G.numSamples
    [length(samples) G.numSamples]
    error('doesnt match up');
end

for ii=1:G.numSamples
  %display(['FB for sample: ' num2str(ii)]);
  tmpTrace = squeeze(G.z(:,getClass(G,ii),:))';
  if iscell(samples)
    tmpDat=samples{ii};
  else
    tmpDat=squeeze(samples(:,:,ii));
  end
  %tic;

  doBack=0;
  [mainLikes(ii),alphas{ii},beta,rho,FBerrorFlag] = ...
      FB(G,tmpDat,ii,tmpTrace',doBack);
  %toc;
  if FBerrorFlag
    warning('FBerrorFlag returned 1'); keyboard;
  end    
end

[timePriorTerm, scalePriorTerm] = getDirichletLike(G);
nuTerm = getNuTerm(G);
%ubar = getUbar2(G);
lambdaTerm = getSmoothLike(G,G.z,G.u);
scaleCenterPriorTerm = getScaleLike(G,G.u);

allLikeButLamNu = sum(mainLikes) + sum(timePriorTerm) + ...
    scalePriorTerm + scaleCenterPriorTerm;

ll =  allLikeButLamNu + nuTerm + sum(lambdaTerm);

return;


