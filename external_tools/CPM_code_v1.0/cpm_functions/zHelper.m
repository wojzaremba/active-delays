% function derivZ=zHelper(G,ubar2,samplesMat,allValidStates,scaleFacs,scaleFacsSq,gammaSum1,gammaSum2,gammaSum5,gammaSum6,scalesExp,scalesExp2,binNum);

function derivZ=zHelper(G,ubar2,samplesMat,allValidStates,scaleFacs,scaleFacsSq,gammaSum1,gammaSum2,gammaSum5,gammaSum6,scalesExp,scalesExp2,binNum);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% this is from getNewZ, where bb has a specific value
binTrace = squeeze(G.z(:,:,binNum)); %start guess in EM
tmpSamples = squeeze(samplesMat(binNum,:,:));
tempSigs = G.sigmas(binNum,:).^(-2);
u2=G.u.^2;

[diagX offDiag b] = getZterms(G,ubar2,samplesMat,allValidStates,scaleFacs,scaleFacsSq,gammaSum1,gammaSum2,binNum,tempSigs,u2);

%% this is from z2Function
derivZ = zFunction(G.z(:),G,offDiag,diagX,b,G.lambda,G.nu,ubar2,binNum);
%% but this was the derivative wrt the log, so we need to undo that:
derivZ = derivZ./G.z(:);
  

