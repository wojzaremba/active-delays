% function logLike = jointLikelihood(G,st,headerAbun);
% 
% Calculate the joint log likelihood of the data and the
% hidden state paths

function logLike = jointLikelihood(G,st,headerAbun);

logLike=zeros(1,G.numSamples);

for kk=1:G.numSamples
  sampleNum=kk;
  tmpSt = squeeze(st(kk,:,:));
  %states=G.stMap(sub2ind(size(G.stMap),tmpSt(:,1),tmpSt(:,2)));
  states=tmpSt;
  
  tmpTrace = G.z(:,getClass(G,kk))';
  oneSample=headerAbun{kk};
  
  [LOGSQRT2PI, logSigma, twoSigma2Inv]=getGaussConst(G,kk);

  if G.USE_CPM2
      uMatRep = repmat(G.uMat(sampleNum,:),[G.numBins 1])';
  end

  thisTrans = G.stateTrans{kk};
  thisTrans2 = thisTrans';
  latentTrace=G.z;
  myMuTemp = getMyMuTemp(G,kk,latentTrace);
  
  for ii=1:G.numRealTimes 
      thisState=states(ii);
      if G.USE_CPM2
          %% first time point, all bins
          emProbs = traceProbU(G,oneSample(:,ii),latentTrace,...
              thisState,sampleNum,logSigma,twoSigma2Inv,...
              LOGSQRT2PI,myMuTemp,uMatRep);
      else
          emProbs = traceProb(G,oneSample(:,ii),latentTrace,...
              thisState,sampleNum,logSigma,twoSigma2Inv,...
              LOGSQRT2PI,myMuTemp);
      end
      logLike(kk)=logLike(kk)+emProbs;
      if ii>1
          pastState=states(ii-1);
          transLogProb=log(thisTrans(pastState,thisState));
          logLike(kk)=logLike(kk)+transLogProb;
      else
          %% initial state
          transLogProb=log(G.statePrior(thisState));
          logLike(kk)=logLike(kk)+transLogProb;
      end
  end

end


