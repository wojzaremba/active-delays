%function [allGtrain allGtest logLikesTrain logLikesTest]=trainTestEMCPM(...
%    data,trainSetInd,testSetInd,classesTrain,classesTest,...
%    USE_SPLINE,oneScaleOnly,maxIter,numCtrlPts,extraPercent...
%    lambda,nu,myThresh, learnStateTrans,learnGlobalScaleFactor,...
%    learnEmissionNoise,learnLatentTrace,saveDir,saveName,initLatentTrace);
%
% Author: Jennifer Listgarten
% Date: October 3, 2006.
%
%% USE EM-CPM: train on the training data, then do inference on the test data

function [allGtrain allGtest logLikesTrain logLikesTest]=...
    trainTestEMCPM(...
    data,trainSetInd,testSetInd,classesTrain,classesTest,...
    USE_CPM2,oneScaleOnly,maxIter,numCtrlPts,extraPercent,...
    lambda,nu,myThresh, learnStateTrans,learnGlobalScaleFac,...
    learnEmissionNoise,learnLatentTrace,saveDir,saveName,initLatentTrace);

if USE_CPM2 && numCtrlPts<3
    error('If using scaling spline, need at least 3 control points');
end

[numTotalSamples,numRealTimes,numBins] = size(data);

% stipulate which updates to do (index 1 is training, index 2 is testing)
updateT=[learnStateTrans learnStateTrans];  %time state transition probabilities
updateScale= [learnStateTrans learnStateTrans];  %scale state transition probabilities
updateSigma=[learnEmissionNoise learnEmissionNoise];  % HMM emission noise
updateZ =[learnLatentTrace 0];      % latent trace
updateU =[learnGlobalScaleFac learnGlobalScaleFac];    % global scaling factor

%% parameters for initialization of the latent trace
startSamp=1;  %use the 'startSamp' index from each class to initialize latent
              % traces with
smoothFrac=0.5; % and when initializing, smooth it by this much

%% if only specified one class, then make note:
ONE_CLASS=(length(classesTrain)==1);

% I haven't tried changing this, so code may fail if it is changed, but
% it was intended to be able to be modified.  No guarantees though.
maxTimeSteps=3; %% max jumps ahead in HMM time space that are allowed

%% settings for the numerical optimization routines
HessianOn='off'; LargeScaleOn='on'; 
useLogZ=1;  % do optimization in logZ space rather than z (for latent trace)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% where to save stuff and what to call it
%savedir = '/u/jenn/phd/MS/matlabCode/workspaces/thesisInProgress/';
%savevars = getSaveVars();

if ~isempty(saveDir)
    savefile = ['''' saveDir 'EMCPM.' saveName '.S' ...
        num2str(lambda,2) '.N' num2str(nu,2) '.' 'B' ...
        num2str(numBins)];
    if USE_CPM2
        savefile = [savefile '.P' num2str(numCtrlPts)];
    end
    %savefile = [savefile '.'  filenameStamp];
    %% NOTE: filenameStamp is my function which is VERY handy in naming
    %% lots of runs, however I took it out since I thought it might
    %% crash on different systems than what I'm using
    savefile = [savefile '.mat'''];

    errorLogFile = savefile(1:(end-4));
    errorLogFile = [errorLogFile(2:end) 'LOG'];

    cmd1 = ['save ' savefile ';'];
    %cmd2 = ['save ' savefile ' ' savevars ];
    eval(cmd1);
    disp(['Will save results to: ']);
    disp(savefile);
    pause(2);
else
    errorLogFile='';
    cmd1='';
    cmd2='';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set up the train/test data

testData = data(testSetInd,:,:);
trainData = data(trainSetInd,:,:);
clear data; %% to  save memory
numTrain = length(trainSetInd);
numTest = length(testSetInd);

if numTrain<2
    error('Need at least 2 time series to train on');
end

if isinf(nu)
    %% use single class algorithm
    classesTrain=convertToOneClass(classesTrain);
    classesTest=convertToOneClass(classesTest);
    nu=0;
end

%% Set up big data structure for running the algorithm.
%% Note that this can have a huge memory imprint as a tradeoff
%% for increased computational speed.

disp('Initializing EM-CPM (can take a little while)...');

%% data structure for training
initGTrain = getHMMParams(numTrain,numRealTimes,classesTrain,...
    extraPercent,startSamp,maxTimeSteps,oneScaleOnly,useLogZ,...
    HessianOn,LargeScaleOn,numBins,lambda,nu,updateScale(1),...
    updateT(1),updateSigma(1),updateU(1),updateZ(1),maxIter,...
    myThresh,USE_CPM2,numCtrlPts);

%% data structure for testing, will be modified after training to
%% incorporate the training results
if numTest>0
    initGTest = getHMMParams(numTest,numRealTimes,classesTest,...
        extraPercent,startSamp,maxTimeSteps,oneScaleOnly,useLogZ,...
        HessianOn,LargeScaleOn,numBins,lambda,nu,updateScale(2),...
        updateT(2),updateSigma(2),updateU(2),updateZ(2),maxIter,...
        myThresh,USE_CPM2,numCtrlPts);
end

disp('Done initialization.');

numClass=initGTrain.numClass;

%%%%%%%%%% RUN CPM on train/test data %%%%%%%%%%%%%%%%%%%%%%
if isempty(initLatentTrace)
    initLatentTrace = ...
        initializeAllLatentTrace(initGTrain,trainData,'',smoothFrac);
else    
    %% check that dimensions are correct:
    [a,b,c]=size(initLatentTrace);
    if any([a b c]~=[initGTrain.numTaus initGTrain.numClass initGTrain.numBins])
        errMsg=sprintf(['Latent trace is not of the correct dimension. \n'...
               'It should be of dimensions [numLatentTime numClass numBins]']);
        error(errMsg);
    end    
end

initGTrain.z=initLatentTrace;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% train the model on training data

HOLD_OUT=0;  % we're not testing here, we're training
[logLikesTrain,allGtrain,didConvergeL_train,errorFlagTrain]=...
    trainFBHMM(initGTrain,trainData,errorLogFile,'',HOLD_OUT,USE_CPM2);

%% get Viterbi alignments of the training data in case we want it
%scaleAndTimesTrain = viterbiAlign(G,trainData);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if errorFlagTrain
    display('Training on training set encountered a problem');
    keyboard;
end

eval(cmd1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do inference on the test cases if appropriate
if  numTest>0    
    %% propagate information to the test parameter structure
    %% for stuff not being learned during testing, or just
    %% to initialize smartly
         
    G=allGtrain{end};
    %G=reviveG(G,0,0); % because we stripped it down of redundant, large memory variables
    
    %% propagate info about scale state transitions (not item-specific)    
    testG = reviseG(initGTest,G.S);

    %% transfer the latent trace
    testG.z=G.z;

    HOLD_OUT=1; %% so that sigmas are not constrained by each other as they are during training  
    [logLikesTest,allGtest,didConvergeL_test,errorFlagTest]=...
    trainFBHMM(testG,testData,errorLogFile,'',HOLD_OUT,USE_CPM2);  

    if errorFlagTest
        display('Training on training set encountered a problem');
        keyboard;    
    end
else
    logLikesTest='';
    allGtest='';
    didConvergeL_test='';   
end

%% clear big stuff that we dont need...then save
if numTest>0
    clear initGTest testG testData;
end
clear initGTrain initLatentTrace G trainData;

eval(cmd1);
    
%% CREATE A MARKER FILE WHICH SHOWS THE COMPUTATION IS DONE
if ~isempty(saveDir)
    savefileFINISHED = savefile(1:(end-4));
    savefileFINISHED = [savefileFINISHED 'FINISHED'];
    cmd3 = ['save ' savefileFINISHED ''' savefileFINISHED ;'];
    eval(cmd3);
end
display('FINISHED');

return;

