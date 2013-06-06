% function dist = getResidual(latentTrace,sample,st,G,sampleNum);
%
% Calculate the residual of sample to latent trace with scaling,
% etc. as prescrbied by st and G, where st is the viterbi alignment

function dist = getResidual(latentTrace,sample,st,G,sampleNum);

tempB=G.u(sampleNum)*2.^(G.scales(st(:,1)));
prediction=sample(:)./tempB(:);
myMu=latentTrace(st(:,2))';
avgSquareResidual = sum((prediction'-myMu).^2)/length(prediction);

dist=avgSquareResidual;
