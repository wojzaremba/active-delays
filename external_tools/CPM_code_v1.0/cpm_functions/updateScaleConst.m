% function newScaleCounts = updateScaleConst(G,alpha,beta,rho,sample,newTrace,sampleNum)
%
% Calculates the new scaleTransition parameter, G.S, but only for one
% sample.  MUST CALL THIS FUNCTION ONE TIME FOR EACH SAMPLE, adding
% together the results, and then normalizing.
%

%% calculates the xi on the fly, as we go, for 
%% space/considerations

function newScaleCounts = updateScaleConst(G,alpha,beta,rhos,oneSample...
    ,newTrace,ss)

%LOGSQRT2PI=log(sqrt(2*pi));
%logSigma = log(G.sigmas(ss));
%twoSigma2Inv = (2*G.sigmas(ss)^2)^(-1);

[LOGSQRT2PI, logSigma, twoSigma2Inv]=getGaussConst(G,ss);

tempSum0=0; tempSum1=0;
tempStateTrans = G.stateTrans{ss};

%% these are indexes which tell us which states to grab
%% (for a jump of 1 or 3 ahead)
jump0=find(G.scaleJump{1} & tempStateTrans);
[r0,c0]=find(G.scaleJump{1} & tempStateTrans);
jump1=find(G.scaleJump{2} & tempStateTrans);
[r1,c1]=find(G.scaleJump{2} & tempStateTrans);

myMuTemp = getMyMuTemp(G,ss,newTrace);

for t=2:G.numRealTimes
    %% jump 1 scale step xi's
    emProbsX = traceProb(G,oneSample(:,t),newTrace,c0,ss,...
        logSigma,twoSigma2Inv,LOGSQRT2PI,myMuTemp);
    xi0 = (tempStateTrans(jump0).*alpha(r0,t-1).*beta(c0,t).*emProbsX)/rhos(t);
    emProbsX = traceProb(G,oneSample(:,t),newTrace,c1,ss,...
        logSigma,twoSigma2Inv,LOGSQRT2PI,myMuTemp);
    xi1 = (tempStateTrans(jump1).*alpha(r1,t-1).*beta(c1,t).*emProbsX)/rhos(t);
    
    tempSum0 = tempSum0 + sum(sum(xi0));
    tempSum1 = tempSum1 + sum(sum(xi1));
end

newScaleCounts = [tempSum0 tempSum1];
