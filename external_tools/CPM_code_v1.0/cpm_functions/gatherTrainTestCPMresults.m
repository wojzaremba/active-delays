function  [allItUsed,newBounds,all1DScore,normFac,...
    all2DScore,all1DScoreTrain,all2DScoreTrain,...
    mainLikesTest,mainLikesTrain,testSig,trainSig,allLam,...
    timePerItTrain,finalTrace,initTrace,u,D,S,didConvergeL,...
    normFacTrain,newBoundsTrain,numBins,totalLikeTrain,totalLikeTest,...
    alignDatTrain1D]=...
    gatherTrainTestCPMresults(...
    fName,trainSet,testSet,trainQmz,testQmz,classesTestN,classesTrainN);

%% classesTest and classesTrain are optional
%% these are needed if nu=Inf was used, since this collapse
%% the problem in to a single class problem, but we want to measure
%% it as a multi-class problem

%% LOAD THE DATA FILE
cmd = ['load ' fName]
eval(cmd);

if ~exist('didConvergeL','var')
    didConvergeL=NaN;
else
    didConvergeL=double(didConvergeL);
end

timePerItTrain=mean(elapsed);

USE_TEST=numTest>0;

if ~isempty(trainQmz)
    USE_2D=1;
else
    USE_2D=0;
end

%%compensate for not saving something properly:
if USE_TEST
    if ~exist('allTraces2','var')
        allTraces2=garb;
    end
    allItUsed(2)=size(allTraces2,1); %test its
else
    allItUsed(2)=NaN;
end
allItUsed(1)=size(allTraces,1); %train its


for j=1:length(testSet)
    testSetT{j}=testSet{j}';
end
for j=1:length(trainSet)
    trainSetT{j}=trainSet{j}';
end

if USE_TEST
    %%% TEST SET %%%
    %% get 1D alignment score, by first aligning in full 2D
    scaleType=2;
    testG=allGtest{end};
    if exist('classesTestN','var') && ~isempty(classesTestN)
        testG.class=classesTestN;       
        testG.numClass=length(classesTestN);
        testG.numClass=length(classesTestN);
    end
    dat =  alignMS(testSetT,scaleAndTimesTest,testG,scaleType);
    [dat newBounds{1}] = truncateNAN(dat);
    boundLen(1)=diff(newBounds{1});
    numRemove = [0 0];
    [all1DScore dotScore(1,:) normFac(1,:)] = ...
        scoreMS(dat,numRemove, testG.class);
   
    if USE_2D
        %% get 2D alignment score
        dat =  alignMS(testQmz,scaleAndTimesTest,testG,scaleType);
        [dat newBounds{2}] = truncateNAN(dat);
        boundLen(2)=diff(newBounds{2});
        [all2DScore dotScore(2,:) normFac(2,:)] = scoreMS(dat,numRemove, testG.class);
    else
        all2DScore=NaN*zeros(size(all1DScore));
    end
else
    all1DScore=NaN;
    all2DScore=NaN;
    newBounds=NaN;
    normFac=NaN;
end

%%% TRAIN SET %%%
%% get 1D alignment score, by first aligning in full 2D
scaleType=2;
trainG=allGtrain{end};
if exist('classesTrainN','var') && ~isempty(classesTrainN)
    trainG.class=classesTrainN;
    trainG.numClass=length(classesTrainN);
    trainG.numPerClass=length(classesTrainN{1});
    finalTraceT=zeros([size(trainG.z,1) trainG.numClass]);
    %keyboard;
    for c=1:trainG.numClass
        finalTrace(:,c)=trainG.z;
    end
    trainG.z=finalTrace;
else
    finalTrace=trainG.z;
end
initTrace = squeeze(initGTrain.z);
u=trainG.u;
D=trainG.D;
S=trainG.S;
numBins=trainG.numBins;
dat =  alignMS(trainSetT,scaleAndTimesTrain,trainG,scaleType);
alignDatTrain1D=squeeze(cell2matDefault(dat));
[dat newBoundsTrain{1}] = truncateNAN(dat);
boundLenTrain(1)=diff(newBoundsTrain{1});
numRemove = [0 0];
[all1DScoreTrain dotScoreTrain(1,:) normFacTrain(1,:)] = ...
    scoreMS(dat,numRemove, trainG.class);

if USE_2D
    %% get 2D alignment score
    dat =  alignMS(trainQmz,scaleAndTimesTrain,trainG,scaleType);
    [dat newBoundsTrain{2}] = truncateNAN(dat);
    boundLenTrain(2)=diff(newBoundsTrain{2});
    [all2DScoreTrain dotScoreTrain(2,:) normFacTrain(2,:)] = ...
        scoreMS(dat,numRemove, trainG.class);
else
    all2DScoreTrain=NaN*zeros(size(all1DScoreTrain));
end

if ~exist('tmpLikes3')
    %% FORGOT TO INCLUDE THIS IN trainTestCPM (it's now there)
    %% trainFBHMM only provides likelihood of second last
    %iteration, so do FB again to get it now:
    
    %%( used to have some of these indexed by cc for some bizarre
    %% reason)  so if need to, just take {1} and it is correct
    %cc=1;%% one clas only in this data set
    %[tmpLikes3,alphas3,mainLikes3{cc},timePriorTerm3{cc},scalePriorTerm3{cc},...

    [tmpLikes3,alphas3,mainLikes3,timePriorTerm3,scalePriorTerm3,...
        scaleCenterPriorTerm3,nuTerm3,lambdaTerm3,allLikeButLamNu3] = ...
        likelihood(trainSet,reviveG(trainG,1,1));
end


mainLikesTrain=mainLikes3;%mainLikes3{cc};
totalLikeTrain = tmpLikes3;
%% total log likelihood without lam/nu terms
trainLLike=allLikeButLamNu3;
%% noise levels
if trainG.numBins>1 && trainG.numClass>1
    error('might not be right');
end
for c=1:trainG.numClass
    trainSig(c)=mean(trainG.sigmas(trainG.class{c}));
end

%% log likelihoods
%% just FB part
if USE_TEST
    if iscell(mainLikes) %%remnant of old weird code
        mainLikesTest=mainLikes{cc};
    else
        mainLikesTest=mainLikes;
    end
    testLLike=allLikeButLamNu;
    for c=1:testG.numClass
        testSig(c)=mean(testG.sigmas(testG.class{c}));
    end
    totalLikeTest = tmpLikes;
else
    totalLikeTest=NaN;
    mainLikesTest=NaN;
    testLLLike=NaN;
    testSig=NaN;
end

allLam=trainG.lambda;

if 0
    whos u D S finalTrace initTrace u D S didConvergeL...
        allItUsed newBounds all1DScore normFac ...
        all2DScore all1DScoreTrain all2DScoreTrain ...
        mainLikesTest mainLikesTrain testSig trainSig allLam ...
        timePerItTrain
end

