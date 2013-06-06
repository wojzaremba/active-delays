 [savefile allStates it updates iterTime G]=trainTestHBCPM(...
    headerAbun,datName,trainSetInd,testSetInd,classesTrain,classesTest,...
    maxIter,numCtrlPts,numBins,myThresh,USE_GLOBAL_U,numCtrlPts,...
    PROFILE,startSamp,logNormHyperParam,mixPriorStrength,mixOutPriorBelief,...
    smoothFrac)

%% hard coded options
USE_CPM2=1; %% =1 means no scale states, use spline instead
extraPercent=0.1;
oneScaleOnlyT=1; %%  not using local scale states
SAMPLER_TYPE='sliceBen'; %'MH' or 'sliceIain' or 'sliceBen';

%%%%%%%%%%%%%%%%%%%%%
%% which parameters to update
initVal=1; %%use all by default
updates = initUpdates(initVal);

%%%%%%%%%%%%%%%%%%%%%
if PROFILE
   profile off;
   profile -detail builtin on;   
end

%%%%%%%%%%%%%%%%%%%%%
%% generate appropriate filenames, etc.
savedir = '/u/jenn/phd/MS/matlabCode/workspaces/thesisInProgress/';

savefile = ['''' savedir 'HBCPM.' datName  '.' 'B' ...
    num2str(numBins) '.P' num2str(numCtrlPts)...
    '.'  filenameStamp  '.mat'''];

errorLogFile = savefile(1:(end-4));
errorLogFile = [errorLogFile(2:end) 'LOG'];

cmd1 = ['save ' savefile ';'];
eval(cmd1);
display(['Will save results to: ' savefile]);


%%%%%%%%%%%%%%%%%%%%%
startSamp=1; %trace from each class to initialize
maxTimeSteps=3; %max time jump in the HMM portion of model

%% convert cell data to mat data temporarily
samplesMat = reshape(cell2mat(headerAbun),...
    [numBins numRealTimes numSamples]);
meanSampVal = mean(samplesMat(:));

%% for the log-normal priors for alpha/rho
% param=3;
% %% child mixture model prior params
% mixPriorStrength=50;
% mixOutPriorBelief=0;%0.01;

%% the parameters trainSetInd and testSetInd
useLoos=1:length(trainSetInd);
numTrain=0; numTest=0;
for loo=useLoos
  testSet{loo} = headerAbun(testSetInd{loo});
  trainSet{loo} = headerAbun(trainSetInd{loo});
  numTrain=numTrain + length(trainSet{loo});
  numTest=numTest + length(testSet{loo});
end

keyboard;

Gtrain = getHMMParamsB(numTrain,numRealTimes,classesTrain,...
    extraPercent,startSamp,maxTimeSteps,oneScaleOnlyT,numBins,...
    maxIter,USE_CPM2,numCtrlPts,updates.D,'',...
    meanSampVal,SAMPLER_TYPE,...
    logNormHyperParam,logNormHyperParam,mixPriorStrength,mixOutPriorBelief,...
    ONE_CLASS,USE_GLOBAL_U);

if numTest>0
    G = getHMMParamsB(numTest,numRealTimes,classesTest,...
        extraPercent,startSamp,maxTimeSteps,oneScaleOnlyT,numBins,...
        maxIter,USE_CPM2,numCtrlPts,updates.D,'',...
        meanSampVal,SAMPLER_TYPE,...
        logNormHyperParam,logNormHyperParam,mixPriorStrength,mixOutPriorBelief,...
        ONE_CLASS,USE_GLOBAL_U);
end

latentTrace = initializeAllLatentTrace(G,headerAbun,'',smoothFrac);
G.z=latentTrace;


initAlpha=1; initRho=1;
initStateTrain = initMCMCCPM(G,samplesMat,headerAbun,initAlpha,initRho);

%% clear whatever we have taken from G - no longer stores state stuff
G=rmfield(G,{'D','S','z','u'});
initState
clear headerAbun;

keyboard;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[allStates it updates iterTime G] = ...
    trainMCCPM(G,samplesMat(:),updates,initStateTrain,FP,savefile);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% CREATE A MARKER FILE WHICH SHOWS THE COMPUTATION IS DONE
savefileFINISHED = savefile(1:(end-4));
savefileFINISHED = [savefileFINISHED 'FINISHED'];
cmd3 = ['save ' savefileFINISHED ''' savefileFINISHED ;'];
display('FINISHED');%% child energy impulses

if PROFILE
    profile off;
    %profile report;
    %% save the profiler information
    profilerInfo = profile('info');
end

%% clear big stuff we don't need to save before saving
keyboard;

display(['Saving results to: ' savefile]);
eval(cmd1);
fclose(FP);

return;
