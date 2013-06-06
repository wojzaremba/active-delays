%function oneNewD = updateTimeConst(G,alpha,beta,rho,oneSample,newTrace,sampleNum)
%
% newTimeTrans is 1xnumSamples, and provides the new constant,
% G.D(1) for a single sample
%
% oneNewD is dimension [1 3]

%% calculates the xi on the fly, as we go, for 
%% space/considerations


function oneNewD = updateTimeConst(G,alpha,beta,rhos,oneSample,...
    newTrace,ss)

%LOGSQRT2PI=log(sqrt(2*pi));
%logSigma = log(G.sigmas(ss));
%twoSigma2Inv = (2*G.sigmas(ss)^2)^(-1);

[LOGSQRT2PI, logSigma, twoSigma2Inv]=getGaussConst(G,ss);

if G.USE_CPM2
	%uMatRep = repmat(G.uMat,[1 1 G.numBins]);
	%uMatRep = permute(uMatRep,[1 3 2]);        
    uMatRep = repmat(G.uMat(ss,:),[G.numBins 1])';
end

%tempSum1=0; tempSum3=0; tempSum2=0;
tempSum = zeros(1,G.maxTimeSteps);
r=cell(1,G.maxTimeSteps);
c=cell(1,G.maxTimeSteps);
jump=cell(1,G.maxTimeSteps);

tempStateTrans = G.stateTrans{ss};

%% these are indexes which tell us which states to grab
%% (for a jump of 1 or 2 or 3 ahead)

matSize = size(tempStateTrans);

for ts=1:G.maxTimeSteps
  [r{ts},c{ts}]=find(G.timeJump{ts} & tempStateTrans);
  jump{ts}=sub2ind(matSize,r{ts},c{ts});
end

%myMuTemp = getMyMuTemp(G,ss); %% old way
myMuTemp = getMyMuTemp(G,ss,G.z);

for t=2:G.numRealTimes
    for ts=1:G.maxTimeSteps
        if ~G.USE_CPM2
            emProbsX = traceProb(G,oneSample(:,t),newTrace,c{ts},ss,...
                logSigma,twoSigma2Inv,LOGSQRT2PI,myMuTemp);
        else
            emProbsX = traceProbU(G,oneSample(:,t),newTrace,c{ts},ss,...
                logSigma,twoSigma2Inv,LOGSQRT2PI,myMuTemp,uMatRep);
        end
        xi = (tempStateTrans(jump{ts}).*alpha(r{ts},t-1).*...
        beta(c{ts},t).*emProbsX)/rhos(t);
    tempSum(ts) = tempSum(ts) + sum(sum(xi));
  end
end

oneNewD = (tempSum + G.pseudoT)/(sum(tempSum) +sum(G.pseudoT));
