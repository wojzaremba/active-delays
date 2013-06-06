% function initGTrain = getHMMParams(numTrain,numRealTimes,classesTrain,...
%    latentTraceLength,startSamp,maxTimeSteps,oneScaleOnly,useLogZ,...
%    HessianOn,LargeScaleOn,numBins,lambda,nu,updateScale,...
%    updateT,updateSigma,updateU,updateZ,maxIter,...
%    myThresh,USE_CPM2,numCtrlPts);
%
% set up constants, variables, etc. needed for the EM-CPM
% this can take some time
%
% 'classes' is a cell array specifying which samples belong to
% which class.  For example, if the first 3 samples were class 1,
% and the next four samples, class 2, then:
% classes{1}=[1:3], classes{2}=[4:7]
%
% if 'classes' is provided as the empty string, '', then it only
% sets up the one-class problem.
%
% 'startSamp' tells you which sample to initialize the latent
% trace, for each class.
%
% USE_CPM2 => means not to use HMM scale states, but instead use
% a set u_kt for each trade of scaling pts which form a linear spline

function G =  getHMMParams(numSamples,numRealTimes,classes,...
    extraPercent,startSamp,maxTimeSteps,oneScaleOnly,useLogZ,...
    HessianOn,LargeScaleOn,numBins,lambda,nu,updateScale,...
    updateTime,updateSigma,updateU,updateZ,maxIter,...
    myThresh,USE_CPM2,numCtrlPts);

global LOGSQRT2PI;
LOGSQRT2PI=getLOGSQRT2PI;

G.zInitType=1; %1=smoothed versoin of one trace; 2=DTW init -- need other code for this not provided here

if USE_CPM2
   oneScaleOnly=1;   
end
G.oneScaleOnly=oneScaleOnly;

G.updateZ = updateZ;
G.updateSigma = updateSigma;
G.updateTime=updateTime;
G.updateU = updateU;
G.updateScale = updateScale;
if oneScaleOnly
    G.updateScale=0;
end

G.thresh = myThresh;
G.maxIter = maxIter;

G.nu=nu;
G.lambda=lambda;
G.useBalancedPenalty=1;
%G.uType=1; % no prior on u_k's (not sure if this is still working)
G.uType=2; % log-Normal prior on u_k's
G.useLogZ=useLogZ; %use log(z) in getNewZ rather than z
G.HessianOn=HessianOn;
G.LargeScaleOn=LargeScaleOn;

G.nuType=1; %cauchy
%G.newZSolver='fminunc';  G.fminuncMaxIter=100;
%G.zThresh=1e-6;  % threshold on numerical optimization for latent traces

G.numBins=numBins;
G.startSamp=startSamp;
G.numSamples = numSamples;

if (~isempty(classes))
  G.class = classes;
else
  G.class{1} = 1:G.numSamples;
end
G.numClass = length(G.class);
G.numPerClass = zeros(1,G.numClass);
for cc=1:G.numClass
  G.numPerClass(cc)=length(G.class{cc});
end

%% number of time steps can move ahead
G.maxTimeSteps = maxTimeSteps;

G.scales = getScales(oneScaleOnly); %needed by state/time/scale transition get functs
G.numRealTimes = numRealTimes;

timeRatio=2; %factor by which we upsample
G.timeRatio=timeRatio;

% G.D holds the time state transition for each time series
%(each row for one sample)
if 1
    % ONE WAY --equal weights to each
    fixedProb = 1/G.maxTimeSteps;
    G.D = repmat(fixedProb,[G.numSamples,G.maxTimeSteps]);
else
    %% OTHER WAY gives more emphasis to skipping ahead 2 time steps
    tmpVec = zeros(1, G.maxTimeSteps);
    tmpVec(G.timeRatio)=fixedProb*1.20;
    leftOverProbs = (1-tmpVec(G.timeRatio))/(G.maxTimeSteps-1);
    otherInds = setdiff(1:G.maxTimeSteps,G.timeRatio);
    tmpVec(otherInds) = leftOverProbs;
    if sum(tmpVec)~=1
        error('doesnt add up');
    end
    G.D = repmat(tmpVec,[G.numSamples 1]);
end

G.extraPercent=extraPercent;
%disp(['Extra Percent: ' num2str(G.extraPercent)]);
G.numTaus = (G.timeRatio*G.numRealTimes + 2*ceil(G.extraPercent*G.numRealTimes));
G.taus = 1:G.numTaus;

G.numScales = length(G.scales);

G.maxScaleSteps = 1;
G.scaleConst = 1;
G.numStartTimeStates  = ceil(G.numRealTimes/3); % must overlap by at least 2/3

G.numStartScaleStates = 1; %because G.u can account for the rest

%pseudo counts for dirichlet prior on scale and time transition
%probabilties (ie the Dirichlet distribution parameters, where in
%this  formulation, we ignor the standard -1 part of the counts.
G.numStates  = G.numScales*G.numTaus;
if (G.oneScaleOnly)
    S=1;
else
    initProbSameScale=0.90;
    S = initProbSameScale;
end
for cc=1:G.numClass
    G.S(cc)=S;
end

G.stMap = reshape([1:G.numStates]',G.numScales,G.numTaus);

%% Mapping from state to tau and scale
G.stateToScaleTau = zeros(G.numStates,2);
for st=1:G.numStates
    [temp1,temp2]= find(G.stMap==st);
    G.stateToScaleTau(st,:) = [temp1, temp2];
end
G.prec = getAllStateTransIn(G);
dirichletStrength=5;
G.pseudoT = dirichletStrength*ones(1,G.maxTimeSteps);
if G.oneScaleOnly
    G.pseudoS = zeros(1,2);
else
    G.pseudoS = dirichletStrength*ones(1,2);
end

if updateTime
    G.timeJump = getTimeJump(G);
end
if updateScale
    G.scaleJump = getScaleJump(G);
end

temp=2.^G.scales(G.stateToScaleTau(:,1));
G.traceLogConstant = repmat(temp(:),[1 G.numBins]);

G.stateLogPrior = getStateLogPrior(G);
G.statePrior = exp(G.stateLogPrior);


G.scaleTransLog = getLogScaleTrans(G); 
G.timeTransLog  = getLogTimeTrans(G);
%G.timeTrans  = getTimeTrans(G);

G.stateTransLog = getStateTransLog(G);
G.stateTrans = getStateTrans(G);

%% scale-centering parameter
%G.u = ones(1,G.numSamples);

%% this will determine the number of control points which 
%% make up the scaling set in the case where CPM2 is being used
%% roughtly, controlPointProp*.G.numTaus will be used.
G.controlPointProp = 0.005;
if USE_CPM2    
    minNum=3;
    G.cntrlPts = getControlPtLoc(G,minNum,numCtrlPts);
    G.numCtrlPts = length(G.cntrlPts);    
    %% value at each pt starts off at 1    
    %% same for each bin
    G.u = ones(G.numSamples,length(G.cntrlPts));
    %% add noise to debug 
    %G.u = G.u + abs(randn(size(G.u)));
    %G.u
    [timePts sMinus sPlus] = getCntrlPtTimeMap(G);
    G.timePts = timePts;
    G.sMinus = sMinus;
    G.sPlus = sPlus;
    G.uMat = getUMat(G,G.u);
    [c1s c2s] = getCpts(G);
    
    %% need c_1s and c_2s to update G.u according to the equations
    %c1s = 
    %c2s = 
    G.c1s = c1s;
    G.c2s = c2s;
    
else
    G.u = ones(1,numSamples);
end

% this is for when we have a log-normal prior on the u_k's
%G.w = (G.scales(end)-G.scales(1))*0.05;
%% this is the standard deviation of the log-normal prior
G.w = log(1.5);  %%i.e. 68% of log(u_k) fall between -log(1.5) and log(1.5)
     %%i.e. 68% of u_k fall between 0.667 and 1.5;

G.sigmaFac=4;  %% factor by which all the sigmas must be within each other

G.USE_CPM2=USE_CPM2;

% OBSOLETE
%G.SHARE_TRANS = SHARE_TRANS;
%G.USE_BP = USE_BP;

