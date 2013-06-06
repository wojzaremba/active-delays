%function [scaleAndTime, seqProb, alphaslog, betaslog] =
% propagate(G,oneSample,latentTrace)
%
%
% Do viterbi for one sample, and latent trace



function [scaleAndTime,score] = propagate(G,oneSample,trace,...
    sampleNum)

%% check that maxSparseMEX.c has been compiled
checkMaxSparseMEX();

cc = getClass(G,sampleNum);
latentTrace = squeeze(trace(:,cc,:));

[LOGSQRT2PI, logSigma, twoSigma2Inv]=getGaussConst(G,sampleNum);

if G.USE_CPM2
	uMatRep = repmat(G.uMat(sampleNum,:),[G.numBins 1])';	    
end
myMuTemp = getMyMuTemp(G,sampleNum,latentTrace);

if G.USE_CPM2
    %% first time point, all bins
    emProbsLogP = traceLogProbU(G,oneSample(:,1),trace,...
        1:G.numStates,sampleNum,logSigma,twoSigma2Inv,...
        LOGSQRT2PI,myMuTemp,uMatRep);
else
    emProbsLogP = traceLogProb(G,oneSample(:,1),trace,...
        1:G.numStates,sampleNum,logSigma,twoSigma2Inv,...
        LOGSQRT2PI,myMuTemp);
end

%emProbsLogP = traceLogProb(G,oneSample(:,1),squeeze(trace(:,cc,:)),...
%    1:G.numStates,sampleNum,logSigma,twoSigma2Inv,LOGSQRT2PI);

vitlog = zeros(G.numStates,G.numRealTimes);
vitlog(:,1) = (G.stateLogPrior + emProbsLogP)';
vitptr = zeros(G.numStates,G.numRealTimes);

%tic
%profile 
%profile -detail operator on;
%allInf = -Inf*ones(G.numStates);
for t=2:G.numRealTimes
  if (mod(t,10)==0)
    %display(['Working on ' num2str(t) ' of ' num2str(G.numRealTimes)]);
    %toc; tic;
  end

  % emission probability for all states, with observed value, oneSample(t)
  if G.USE_CPM2
      emProbsLogF = traceLogProbU(G,oneSample(:,t),...
          latentTrace,1:G.numStates,sampleNum,logSigma,...
          twoSigma2Inv,LOGSQRT2PI,myMuTemp,uMatRep);
  else
      emProbsLogF = traceLogProb(G,oneSample(:,t),...
          latentTrace,1:G.numStates,sampleNum,logSigma,...
          twoSigma2Inv,LOGSQRT2PI,myMuTemp);
  end
  
  [ii,jj,ss]=find(G.stateTransLog{sampleNum}); 
  % figure, show(full(G.stateTransLog{sampleNum}));
  % figure, show(find(exp(full(G.stateTransLog{sampleNum}))));
  %repvitlog = repmat(vitlog(:,t-1),1,G.numStates);
  
  tempMat = G.stateTransLog{sampleNum};
  %tempMat(find(G.stateTransLog{sampleNum}))=ss + vitlog(ii,t-1);
  tempInd = sub2ind(size(G.stateTransLog{sampleNum}),ii,jj);
  tempMat(tempInd)=ss + vitlog(ii,t-1);
  [maxVitlog,maxIndLog]=maxSparseMEX(tempMat);
  
  newVitlog = maxVitlog + emProbsLogF;
  vitlog(:,t) = newVitlog';
  vitptr(:,t-1)=maxIndLog';
end
%toc
%profile off; profile report;

if any(isnan(vitlog))
    error('Found isnan vitlog');
end

%% Trace back the Viterbi path
furthest=G.numRealTimes;
vitPath = zeros(1,G.numRealTimes-(G.numRealTimes-furthest));
tempMax = max(vitlog(:,furthest));
tempInd=find(vitlog(:,furthest)==tempMax);
% if there is a tie, choose the largest state
%tempInd=tempInd(randperm(length(tempInd)));
if length(tempInd)<1
  tempMax
  furthest
  imstats(vitlog(:,furthest))
  error('(length(tempInd)<1)');
end
tempInd = tempInd(1);
%tempInd = tempInd(end);
vitPath(end)=tempInd(1);
for t=(length(vitPath)-1):-1:1
  prevState = vitPath(t+1);
  vitPath(t) = vitptr(prevState,t);
end

scaleAndTime=G.stateToScaleTau(vitPath,:);
score = vitlog(tempInd,furthest);

return;

%exportCellArray('none',num2cell(scaleAndTime));

%figure,image(vitlog,'CDataMapping','scaled'); colorbar;
%figure,image(vit,'CDataMapping','scaled'); colorbar;



%alphabeta = alphaslog + betaslog;
%lkOS = sum(alphabeta,1);
%seqProb=lkOS(1);  %may have more than one from rounding errors.

%temp=unique(lkOS)';
%whos temp;
%temp
%figure, plot(lkOS,'+');


%gammas = alphaslog.*betaslog;
%check = sum(gammas,1);
%temp=unique(check(1:(end-1)));
%whos temp
%figure, plot(temp,'+');
