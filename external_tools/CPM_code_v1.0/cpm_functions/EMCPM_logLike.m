% function logLike = EMCPM_logLike(G,samplesMat)
%
% Compute the log likelihood of the data for the
% EM-CPM used parameters stored in structure G, and
% observed data stored in samplesMat

function logLike = EMCPM_logLike(G,samplesMat)

smoothLikes=getSmoothLike(G,G.z,G.u);
[timePriorTerm, scalePriorTerm] = getDirichletLike(G);
nuTerm = getNuTerm(G);
scaleCenterPriorTerm = getScaleLike(G,G.u);

for kk=1:G.numSamples
    %% E-step (obtaining gammas), using forward-backward in
    %% standard way, with scaling tricks (not in log space)
    myClass = getClass(G,kk);
    doback=0;  %% do backward pass
    tmpZ = permute(G.z(:,myClass,:),[1 3 2]);
    [mainL(kk)]=FB(G,samplesMat(:,:,kk),kk,tmpZ,doback);
end

logLike = sum(mainL) + scalePriorTerm + sum(timePriorTerm) + ...
    sum(smoothLikes) + scaleCenterPriorTerm + nuTerm;
