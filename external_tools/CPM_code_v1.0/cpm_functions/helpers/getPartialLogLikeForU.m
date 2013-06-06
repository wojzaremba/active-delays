function [partialLogLike uMat]= getPartialLogLikeForU(tmpScales,G,...
        gammaSum5,gammaSum6,tmpU,sig2inv,zPhi)   
       
hmmTerms = zeros(1,G.numBins);
regLike = zeros(1,G.numBins);

%tmpScales = squeeze(scalesExpRep(:,:,binNum))';      

for binNum=1:G.numBins
    %tmpZ = squeeze(G.z(:,:,binNum));    
    
    zPhiT = zPhi(:,:,binNum)';
   
    %% 1) from HMM emissions           
    [hmmLikeForZU uMat] = getHMMlikeForU(tmpU,G,tmpScales,...
        gammaSum5,gammaSum6{binNum},zPhiT,sig2inv(binNum,:),binNum);
	hmmTerms(binNum) = hmmLikeForZU; 
  
    %% 2) regularization term for between-class trace 
    %% no u dependence     
end

%% 3) regularization term for intra-class traces
regLike= getSmoothLikeU(G,tmpU);

%% 4) log normal prior on the u_k
scaleCenterPriorTerm = getScaleLike(G,tmpU);

partialLogLike = sum(hmmTerms) + sum(regLike) + scaleCenterPriorTerm;

return;
